import { Router, Request, Response, NextFunction } from 'express';

const router = Router();

// ── مخزن الـ flags في الذاكرة (سيُستبدل بـ DB لاحقاً)
let platformFlags: Record<string, unknown> = {
  // عامة
  offersEnabled: true,
  loyaltyEnabled: true,
  referralEnabled: true,
  walletEnabled: true,
  subscriptionsEnabled: true,
  compareEnabled: true,
  sosEnabled: true,
  chatEnabled: true,
  tipsEnabled: true,
  // ميزات متقدمة
  aiChatEnabled: true,
  voiceSearchEnabled: true,
  annualBookingEnabled: true,
  promoCodesEnabled: true,
  cashPaymentEnabled: false,
  reviewsEnabled: true,
  requireReviewAfterBooking: false,
  // عاملات
  workerSectionVisible: false,
  workerSearchVisible: false,
  workerProfilesVisible: false,
  workerRegistrationOpen: false,
  workerScheduleTabVisible: true,
  workerRequestsTabVisible: true,
  workerEarningsVisible: true,
  workerCanSetOwnRate: true,
  workerNightShiftEnabled: false,
  workerMaxDailyBookings: 5,
  // عميل
  customerSearchTabVisible: true,
  customerBookingsTabVisible: true,
  customerWalletVisible: true,
  customerOffersVisible: true,
  customerLoyaltyVisible: true,
  // شركة
  companyBookingsTabVisible: true,
  companyWorkersTabVisible: true,
  companyServicesVisible: true,
  companyAnalyticsVisible: true,
  companyBillingVisible: true,
  // تسجيل
  customerSignupEnabled: true,
  workerSignupEnabled: true,
  companySignupEnabled: true,
  allSignupsBlocked: false,
  signupBlockedMessage: 'التسجيل مغلق مؤقتاً.',
  // دفع
  googleSignInEnabled: true,
  appleSignInEnabled: true,
  walletPaymentEnabled: true,
  cardPaymentEnabled: true,
  minimumWalletTopup: 10.0,
  maximumBookingAmount: 2000.0,
  // أمان
  requireKycBeforeBooking: false,
  requireWorkerKycPublic: false,
  requireCompanyKyc: true,
  twoFactorEnabled: false,
  maxLoginAttempts: 5,
  accountSuspensionMessage: 'تم تعليق حسابك مؤقتاً. تواصل مع الدعم.',
  // مكافآت
  referralBonusAmount: 15.0,
  loyaltyPointsPerBooking: 10,
  loyaltyRedemptionRate: 0.01,
  minRatingToAppear: 3.0,
  // صيانة
  maintenanceMode: false,
  maintenanceMessage: 'التطبيق في وضع الصيانة. سنعود قريباً!',
  maintenanceEndTime: '',
};

// ── مخزن الاشتراكات لكل مستخدم
const userSubscriptions: Map<string, {
  userId: string;
  tier: string;
  expiresAt: string | null;
  grantedBy?: string;
  grantedAt?: string;
}> = new Map();

function getValue(input: string | string[] | undefined): string | undefined {
  return Array.isArray(input) ? input[0] : input;
}

// ── Middleware: فحص admin
function requireAdmin(req: Request, res: Response, next: NextFunction): void {
  const role = getValue(req.headers['x-user-role']);
  if (role !== 'admin') {
    res.status(403).json({ error: 'Admin access required' });
    return;
  }
  next();
}

// ══════════════════════════════════════════════════════════════
// Platform Flags Routes
// ══════════════════════════════════════════════════════════════

/** GET /platform/flags — يُعيد الـ flags الحالية (متاح للكل) */
router.get('/flags', (_req: Request, res: Response) => {
  res.json({ flags: platformFlags, updatedAt: new Date().toISOString() });
});

/** GET /platform/maintenance — للتطبيق عند الفتح */
router.get('/maintenance', (_req: Request, res: Response) => {
  res.json({
    maintenanceMode: platformFlags.maintenanceMode,
    message: platformFlags.maintenanceMessage,
    endTime: platformFlags.maintenanceEndTime,
  });
});

/** PUT /platform/flags — تحديث (admin فقط) */
router.put('/flags', requireAdmin, (req: Request, res: Response) => {
  const updates = req.body as Record<string, unknown>;
  platformFlags = { ...platformFlags, ...updates };
  res.json({
    success: true,
    flags: platformFlags,
    updatedAt: new Date().toISOString(),
  });
});

/** PUT /platform/maintenance — تفعيل/إيقاف الصيانة سريعاً */
router.put('/maintenance', requireAdmin, (req: Request, res: Response) => {
  const { enabled, message, endTime } = req.body as {
    enabled: boolean; message?: string; endTime?: string;
  };
  platformFlags.maintenanceMode = enabled;
  if (message) platformFlags.maintenanceMessage = message;
  if (endTime !== undefined) platformFlags.maintenanceEndTime = endTime;
  res.json({ success: true, maintenanceMode: enabled });
});

/** POST /platform/flags/reset — إعادة الافتراضيات */
router.post('/flags/reset', requireAdmin, (_req: Request, res: Response) => {
  platformFlags = { ...platformFlags, maintenanceMode: false };
  res.json({ success: true, message: 'Flags reset to defaults' });
});

// ══════════════════════════════════════════════════════════════
// Subscription Management Routes
// ══════════════════════════════════════════════════════════════

/** GET /platform/subscriptions — قائمة كل اشتراكات المستخدمين */
router.get('/subscriptions', requireAdmin, (_req: Request, res: Response) => {
  const list = Array.from(userSubscriptions.values());
  const active = list.filter(s => s.tier !== 'free' && s.expiresAt && new Date(s.expiresAt) > new Date());
  res.json({
    total: list.length,
    active: active.length,
    subscriptions: list,
  });
});

/** GET /platform/subscriptions/:userId — اشتراك مستخدم محدد */
router.get('/subscriptions/:userId', requireAdmin, (req: Request, res: Response) => {
  const userId = getValue(req.params.userId);
  if (!userId) {
    res.status(400).json({ error: 'Missing userId' });
    return;
  }
  const sub = userSubscriptions.get(userId) ?? { userId, tier: 'free', expiresAt: null };
  res.json(sub);
});

/** POST /platform/subscriptions/purchase — شراء (يتحقق من المحفظة) */
router.post('/subscriptions/purchase', (req: Request, res: Response) => {
  const { userId, tier, walletBalance } = req.body as {
    userId: string; tier: string; walletBalance: number;
  };
  const prices: Record<string, number> = { gold: 9.99, platinum: 19.99 };
  const price = prices[tier];
  if (!price) { res.status(400).json({ error: 'Invalid tier' }); return; }
  if (walletBalance < price) {
    res.status(402).json({
      error: 'Insufficient wallet balance',
      required: price,
      available: walletBalance,
      shortage: price - walletBalance,
    });
    return;
  }
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);
  userSubscriptions.set(userId, {
    userId, tier, expiresAt: expiresAt.toISOString(), grantedAt: new Date().toISOString(),
  });
  res.json({ success: true, tier, expiresAt: expiresAt.toISOString(), amountDeducted: price });
});

/** PUT /platform/subscriptions/admin/grant — منح من الإدارة */
router.put('/subscriptions/admin/grant', requireAdmin, (req: Request, res: Response) => {
  const { userId, tier, days, adminName } = req.body as {
    userId: string; tier: string; days: number; adminName?: string;
  };
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + (days || 30));
  userSubscriptions.set(userId, {
    userId, tier, expiresAt: expiresAt.toISOString(),
    grantedBy: adminName ?? 'admin',
    grantedAt: new Date().toISOString(),
  });
  res.json({ success: true, userId, tier, expiresAt: expiresAt.toISOString() });
});

/** DELETE /platform/subscriptions/:userId — إلغاء */
router.delete('/subscriptions/:userId', requireAdmin, (req: Request, res: Response) => {
  const userId = getValue(req.params.userId);
  if (!userId) {
    res.status(400).json({ error: 'Missing userId' });
    return;
  }
  userSubscriptions.set(userId, { userId, tier: 'free', expiresAt: null });
  res.json({ success: true, userId, tier: 'free' });
});

// ══════════════════════════════════════════════════════════════
// Account Suspension Routes
// ══════════════════════════════════════════════════════════════

// مخزن التعليقات
const suspendedAccounts: Map<string, { reason: string; suspendedAt: string; suspendedBy: string }> = new Map();

/** POST /platform/accounts/:userId/suspend — تعليق حساب */
router.post('/accounts/:userId/suspend', requireAdmin, (req: Request, res: Response) => {
  const userId = getValue(req.params.userId);
  if (!userId) {
    res.status(400).json({ error: 'Missing userId' });
    return;
  }
  const { reason, adminName } = req.body as { reason?: string; adminName?: string };
  suspendedAccounts.set(userId, {
    reason: reason ?? 'مخالفة سياسة المنصة',
    suspendedAt: new Date().toISOString(),
    suspendedBy: adminName ?? 'admin',
  });
  res.json({ success: true, userId, suspended: true });
});

/** POST /platform/accounts/:userId/unsuspend — رفع التعليق */
router.post('/accounts/:userId/unsuspend', requireAdmin, (req: Request, res: Response) => {
  const userId = getValue(req.params.userId);
  if (!userId) {
    res.status(400).json({ error: 'Missing userId' });
    return;
  }
  suspendedAccounts.delete(userId);
  res.json({ success: true, userId, suspended: false });
});

/** GET /platform/accounts/:userId/status — حالة الحساب */
router.get('/accounts/:userId/status', (req: Request, res: Response) => {
  const userId = getValue(req.params.userId);
  if (!userId) {
    res.status(400).json({ error: 'Missing userId' });
    return;
  }
  const suspended = suspendedAccounts.get(userId);
  res.json({
    userId,
    suspended: !!suspended,
    ...(suspended ?? {}),
    suspensionMessage: platformFlags.accountSuspensionMessage,
  });
});

/** GET /platform/accounts/suspended — قائمة المعلّقين */
router.get('/accounts/suspended', requireAdmin, (_req: Request, res: Response) => {
  const list = Array.from(suspendedAccounts.entries()).map(([userId, data]) => ({
    userId, ...data,
  }));
  res.json({ count: list.length, accounts: list });
});

export default router;
