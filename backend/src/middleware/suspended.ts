import { Request, Response, NextFunction } from 'express';
import { users } from '../store';

const alwaysAllowed = [
  '/api/v1/auth/login',
  '/api/v1/auth/logout',
  '/api/v1/auth/forgot-password',
  '/api/v1/auth/reset-password',
  '/api/v1/platform/maintenance',
  '/health',
];

export function suspendedMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  const isAlwaysAllowed = alwaysAllowed.some((p) => req.path.startsWith(p));
  if (isAlwaysAllowed) {
    next();
    return;
  }

  const authHeader = req.headers['authorization'];
  const token = typeof authHeader === 'string' && authHeader.startsWith('Bearer ')
    ? authHeader.slice(7)
    : null;

  if (!token) {
    next();
    return;
  }

  // استخراج userId من token
  let userId: string | undefined;
  if (token.startsWith('demo-token-')) {
    userId = token.replace('demo-token-', '');
  }

  if (!userId) {
    next();
    return;
  }

  const user = users.find((u) => u.id === userId);
  if (user && (user as any).isActive === false) {
    res.status(403).json({
      error: 'account_suspended',
      message: (user as any).suspendReason || 'تم تعليق حسابك. تواصل مع الدعم.',
      support_url: '/api/v1/support',
    });
    return;
  }

  next();
}
