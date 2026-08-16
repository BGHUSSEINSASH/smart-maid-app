import { NextFunction, Request, Response } from 'express';
import { parseUserFromToken, User } from '../store';

export interface AuthedRequest extends Request {
  user?: User;
}

export function requireAuth(req: AuthedRequest, res: Response, next: NextFunction): void {
  const authorization = req.header('authorization') ?? '';
  const token = authorization.startsWith('Bearer ') ? authorization.slice(7) : undefined;
  const user = parseUserFromToken(token);

  if (!user) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }

  req.user = user;
  next();
}
