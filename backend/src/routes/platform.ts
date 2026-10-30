import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, requireRole, type AuthedRequest } from '../middleware/auth';
import { findUserById, persist } from '../store';

const router = Router();

/**
 * إعدادات المنصة — تُقرأ علناً (لتفعيل/تعطيل أقسام في التطبيق) ولا
 * تُعدَّل إلا بحساب إدارة موثّق. لا اعتماد على ترويسة x-user-role.
 */
const platformFlags: Record<string, unknown> = {
  offersEnabled: true,
  loyaltyEnabled: true,
  referralEnabled: true,
  walletEnabled: false, // المحفظة للعرض فقط حتى يُهيّأ مزوّد الدفع
  sosEnabled: false, // أُزيلت من الإصدار الأول
  chatEnabled: true,
  aiChatEnabled: Boolean(process.env.AI_MODEL_ENDPOINT),
  voiceSearchEnabled: false,
  annualBookingEnabled: false,
  cardPaymentEnabled: Boolean(process.env.STRIPE_SECRET_KEY),
  cashPaymentEnabled: true,
  maintenanceMode: false,
  maintenanceMessage: 'التطبيق في وضع الصيانة. سنعود قريباً!',
  maintenanceEndTime: '',
  minimumBookingAmount: 10,
  maximumBookingAmount: Number(process.env.MAX_BOOKING_AMOUNT ?? 2000),
};

router.get('/flags', (_req, res) => {
  res.json({ flags: platformFlags, updatedAt: new Date().toISOString() });
});

router.get('/maintenance', (_req, res) => {
  res.json({
    maintenanceMode: platformFlags.maintenanceMode,
    message: platformFlags.maintenanceMessage,
    endTime: platformFlags.maintenanceEndTime,
  });
});

const flagsSchema = z.record(z.string(), z.unknown());

router.put(
  '/flags',
  requireAuth,
  requireRole('admin'),
  (req: AuthedRequest, res) => {
    const parsed = flagsSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: 'Invalid payload' });
      return;
    }
    Object.assign(platformFlags, parsed.data);
    res.json({
      success: true,
      flags: platformFlags,
      updatedAt: new Date().toISOString(),
    });
  },
);

const maintenanceSchema = z.object({
  enabled: z.boolean(),
  message: z.string().optional(),
  endTime: z.string().optional(),
});

router.put(
  '/maintenance',
  requireAuth,
  requireRole('admin'),
  (req: AuthedRequest, res) => {
    const parsed = maintenanceSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: 'Invalid payload' });
      return;
    }
    platformFlags.maintenanceMode = parsed.data.enabled;
    if (parsed.data.message) platformFlags.maintenanceMessage = parsed.data.message;
    if (parsed.data.endTime !== undefined) {
      platformFlags.maintenanceEndTime = parsed.data.endTime;
    }
    res.json({ success: true, maintenanceMode: parsed.data.enabled });
  },
);

/** تعليق حساب / رفعه — إدارة فقط. */
const suspendSchema = z.object({ reason: z.string().min(3).max(300).optional() });

router.post(
  '/accounts/:userId/suspend',
  requireAuth,
  requireRole('admin'),
  (req: AuthedRequest, res) => {
    const parsed = suspendSchema.safeParse(req.body ?? {});
    const user = findUserById(String(req.params.userId));
    if (!user) {
      res.status(404).json({ error: 'User not found' });
      return;
    }
    user.suspended = true;
    user.suspendReason = parsed.success ? parsed.data.reason : undefined;
    persist();
    res.json({ success: true, userId: user.id, suspended: true });
  },
);

router.post(
  '/accounts/:userId/unsuspend',
  requireAuth,
  requireRole('admin'),
  (req: AuthedRequest, res) => {
    const user = findUserById(String(req.params.userId));
    if (!user) {
      res.status(404).json({ error: 'User not found' });
      return;
    }
    user.suspended = false;
    user.suspendReason = undefined;
    persist();
    res.json({ success: true, userId: user.id, suspended: false });
  },
);

/** حالة الحساب — للمستخدم نفسه أو للإدارة. */
router.get('/accounts/:userId/status', requireAuth, (req: AuthedRequest, res) => {
  if (req.user!.role !== 'admin' && req.user!.id !== String(req.params.userId)) {
    res.status(403).json({ error: 'Forbidden' });
    return;
  }
  const user = findUserById(String(req.params.userId));
  if (!user) {
    res.status(404).json({ error: 'User not found' });
    return;
  }
  res.json({
    userId: user.id,
    suspended: !!user.suspended,
    reason: user.suspendReason ?? null,
  });
});

export default router;
