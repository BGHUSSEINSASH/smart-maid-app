import jwt from 'jsonwebtoken';
import { NextFunction, Request, Response } from 'express';
import { AppRole, findUserById, User } from '../store';

export interface AuthedRequest extends Request {
  user?: User;
}

export function signToken(user: Pick<User, 'id' | 'role'>): string {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error(
      'JWT_SECRET is not set — refusing to issue an insecure token.',
    );
  }
  return jwt.sign({ sub: user.id, role: user.role }, secret, {
    expiresIn: '7d',
  });
}

export function resolveTokenUser(token?: string): User | undefined {
  if (!token) return undefined;
  const secret = process.env.JWT_SECRET;
  // بدون سرّ موقّع لا نقبل أي رمز — رفض صريح بدل قبول tokens قابلة للتزوير.
  if (!secret) return undefined;
  try {
    const payload = jwt.verify(token, secret) as { sub?: string };
    if (!payload.sub) return undefined;
    return findUserById(payload.sub);
  } catch {
    return undefined;
  }
}

export function tokenFromRequest(req: Request): string | undefined {
  const authorization = req.header('authorization') ?? '';
  return authorization.startsWith('Bearer ')
    ? authorization.slice(7)
    : undefined;
}

export function requireAuth(
  req: AuthedRequest,
  res: Response,
  next: NextFunction,
): void {
  const user = resolveTokenUser(tokenFromRequest(req));

  if (!user) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }
  if (user.suspended) {
    res.status(403).json({
      error: 'account_suspended',
      message: user.suspendReason || 'تم تعليق حسابك. تواصل مع الدعم.',
    });
    return;
  }

  req.user = user;
  next();
}

export function requireRole(...roles: AppRole[]) {
  return (req: AuthedRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }
    if (roles.length > 0 && !roles.includes(req.user.role)) {
      res.status(403).json({ message: 'Forbidden' });
      return;
    }
    next();
  };
}

const loginAttempts = new Map<string, number[]>();
const WINDOW_MS = 15 * 60 * 1000;
const MAX_ATTEMPTS = 20;

export function rateLimitLogin(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  const key = req.ip ?? 'unknown';
  const now = Date.now();
  const attempts = (loginAttempts.get(key) ?? []).filter(
    (t) => now - t < WINDOW_MS,
  );
  if (attempts.length >= MAX_ATTEMPTS) {
    res.status(429).json({ message: 'Too many attempts, try later' });
    return;
  }
  attempts.push(now);
  loginAttempts.set(key, attempts);
  next();
}
