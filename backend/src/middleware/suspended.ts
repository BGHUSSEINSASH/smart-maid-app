import { Request, Response, NextFunction } from 'express';
import { resolveTokenUser, tokenFromRequest } from './auth';

const alwaysAllowed = [
  '/api/v1/auth/login',
  '/api/v1/auth/register',
  '/api/v1/platform/maintenance',
  '/health',
];

/**
 * يمنع الحسابات المعلّقة من استخدام الـ API. يتحقق من رمز JWT الحقيقي
 * (لا من رمز تجريبي)، ويترك القرار لـ requireAuth في بقية المسارات.
 */
export function suspendedMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  if (alwaysAllowed.some((p) => req.path.startsWith(p))) {
    next();
    return;
  }

  const user = resolveTokenUser(tokenFromRequest(req));
  if (user?.suspended) {
    res.status(403).json({
      error: 'account_suspended',
      message: user.suspendReason || 'تم تعليق حسابك. تواصل مع الدعم.',
    });
    return;
  }

  next();
}
