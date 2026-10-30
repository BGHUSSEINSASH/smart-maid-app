import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import {
  createUser,
  deleteUserData,
  findUserByEmail,
  findUserById,
  persist,
  users,
  type AppRole,
} from '../store';
import {
  rateLimitLogin,
  requireAuth,
  signToken,
  type AuthedRequest,
} from '../middleware/auth';

const router = Router();

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

router.post('/login', rateLimitLogin, async (req, res) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }

  const user = findUserByEmail(parsed.data.email);
  if (!user) {
    res.status(401).json({ message: 'Invalid credentials' });
    return;
  }

  const ok = await bcrypt.compare(parsed.data.password, user.passwordHash);
  if (!ok) {
    res.status(401).json({ message: 'Invalid credentials' });
    return;
  }
  if (user.suspended) {
    res.status(403).json({
      error: 'account_suspended',
      message: user.suspendReason || 'تم تعليق حسابك. تواصل مع الدعم.',
    });
    return;
  }

  let token: string;
  try {
    token = signToken(user);
  } catch {
    res.status(500).json({ message: 'Server misconfigured: JWT_SECRET missing' });
    return;
  }

  res.json({
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      phone: user.phone ?? null,
    },
  });
});

const registerSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(8),
  role: z.enum(['customer', 'worker', 'company']).optional(),
  phone: z.string().min(6).max(20).optional(),
});

router.post('/register', async (req, res) => {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }

  if (findUserByEmail(parsed.data.email)) {
    res.status(409).json({ message: 'Email already registered' });
    return;
  }

  const user = await createUser({
    name: parsed.data.name,
    email: parsed.data.email,
    password: parsed.data.password,
    role: (parsed.data.role ?? 'customer') as AppRole,
  });
  if (parsed.data.phone) {
    user.phone = parsed.data.phone;
    persist();
  }

  res.status(201).json({
    token: signToken(user),
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      phone: user.phone ?? null,
    },
  });
});

router.get('/me', requireAuth, (req: AuthedRequest, res) => {
  const user = req.user!;
  res.json({
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    phone: user.phone ?? null,
  });
});

const profileSchema = z.object({
  name: z.string().min(2).optional(),
  phone: z.string().min(6).max(20).optional(),
});

router.patch('/me', requireAuth, (req: AuthedRequest, res) => {
  const parsed = profileSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }
  const user = req.user!;
  if (parsed.data.name) user.name = parsed.data.name;
  if (parsed.data.phone !== undefined) user.phone = parsed.data.phone;
  persist();
  res.json({
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    phone: user.phone ?? null,
  });
});

// حذف الحساب نهائياً — يزيل المستخدم وكل بياناته المرتبطة.
// متطلب App Store 5.1.1(v) و Google Play لسياسة حذف الحساب.
router.delete('/me', requireAuth, (req: AuthedRequest, res) => {
  const user = req.user!;
  deleteUserData(user.id);
  res.json({ message: 'Account deleted' });
});

// حالة الحساب (للتعليق) — لا تُكشف بيانات لغيره.
router.get('/me/status', requireAuth, (req: AuthedRequest, res) => {
  const user = findUserById(req.user!.id);
  res.json({
    userId: req.user!.id,
    suspended: !!user?.suspended,
    reason: user?.suspendReason ?? null,
  });
});

export { users };
export default router;
