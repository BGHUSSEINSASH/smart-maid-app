import { Router } from 'express';
import { z } from 'zod';
import { users, updateUserPassword, type AppRole } from '../store';
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

// كل مسارات /admin تتطلب مصادقة ودور admin
router.use(requireAuth);
router.use(requireRole('admin'));

// ── إدارة المستخدمين ─────────────────────────────────────────────

router.get('/users', (_req, res) => {
  res.json({
    users: users.map(u => ({
      id: u.id, name: u.name, email: u.email, role: u.role,
      isActive: (u as any).isActive !== false,
    })),
  });
});

const suspendSchema = z.object({ reason: z.string().optional() });

router.patch('/users/:id/suspend', (req, res) => {
  const user = users.find(u => u.id === req.params.id);
  if (!user) { res.status(404).json({ message: 'User not found' }); return; }
  (user as any).isActive = false;
  (user as any).suspendReason = req.body?.reason ?? '';
  res.json({ message: 'User suspended', userId: user.id });
});

router.patch('/users/:id/activate', (req, res) => {
  const user = users.find(u => u.id === req.params.id);
  if (!user) { res.status(404).json({ message: 'User not found' }); return; }
  (user as any).isActive = true;
  (user as any).suspendReason = '';
  res.json({ message: 'User activated', userId: user.id });
});

router.delete('/users/:id', (req, res) => {
  const idx = users.findIndex(u => u.id === req.params.id);
  if (idx === -1) { res.status(404).json({ message: 'User not found' }); return; }
  users.splice(idx, 1);
  res.json({ message: 'User deleted' });
});

// ── إدارة العمولات ────────────────────────────────────────────────

// عمولة كل شركة (مخزّنة في الذاكرة)
const companyCommissions = new Map<string, number>();

router.get('/commissions', (_req, res) => {
  res.json({
    commissions: Object.fromEntries(companyCommissions),
    default: 0.20,
  });
});

const commissionSchema = z.object({
  companyId: z.string(),
  rate: z.number().min(0.01).max(0.50),
});

router.post('/commissions', (req, res) => {
  const parsed = commissionSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    return;
  }
  companyCommissions.set(parsed.data.companyId, parsed.data.rate);
  res.json({ message: 'Commission updated', ...parsed.data });
});

// ── إدارة الخصومات ────────────────────────────────────────────────

interface Discount {
  id: string;
  code: string;
  title: string;
  discountPercent: number;
  minTotal: number;
  maxUses: number;
  usedCount: number;
  isActive: boolean;
}

const discounts: Discount[] = [
  { id: 'd1', code: 'SMART50', title: 'خصم النصف', discountPercent: 50,
    minTotal: 50, maxUses: 500, usedCount: 128, isActive: true },
  { id: 'd2', code: 'SAVE15', title: 'وفّر 15%', discountPercent: 15,
    minTotal: 30, maxUses: 1000, usedCount: 344, isActive: true },
];

router.get('/discounts', (_req, res) => { res.json({ discounts }); });

const discountSchema = z.object({
  code: z.string().min(2).toUpperCase(),
  title: z.string().min(2),
  discountPercent: z.number().min(1).max(100),
  minTotal: z.number().min(0).default(0),
  maxUses: z.number().min(1).default(1000),
});

router.post('/discounts', (req, res) => {
  const parsed = discountSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    return;
  }
  const existing = discounts.find(d => d.code === parsed.data.code);
  if (existing) {
    res.status(409).json({ message: 'Discount code already exists' });
    return;
  }
  const discount: Discount = {
    id: `d_${Date.now()}`,
    ...parsed.data,
    usedCount: 0,
    isActive: true,
  };
  discounts.push(discount);
  res.status(201).json({ discount });
});

router.patch('/discounts/:id/toggle', (req, res) => {
  const d = discounts.find(x => x.id === req.params.id);
  if (!d) { res.status(404).json({ message: 'Not found' }); return; }
  d.isActive = !d.isActive;
  res.json({ discount: d });
});

router.delete('/discounts/:id', (req, res) => {
  const idx = discounts.findIndex(x => x.id === req.params.id);
  if (idx === -1) { res.status(404).json({ message: 'Not found' }); return; }
  discounts.splice(idx, 1);
  res.json({ message: 'Discount deleted' });
});

// ── إعدادات النظام ────────────────────────────────────────────────

const systemSettings = {
  defaultCommissionRate: 0.20,
  minWithdrawal: 50,
  maxCouponDiscount: 0.50,
  maintenanceMode: false,
  maintenanceMessage: 'التطبيق تحت الصيانة، نعود قريباً',
  loyaltyEnabled: true,
  referralEnabled: true,
};

router.get('/settings', (_req, res) => { res.json({ settings: systemSettings }); });

router.patch('/settings', (req, res) => {
  Object.assign(systemSettings, req.body);
  res.json({ settings: systemSettings });
});

// ── إدارة الشركات (إنشاء كامل من الإدارة) ─────────────────────────

interface AdminCompany {
  id: string;
  name: string;
  commercialRegNo: string;
  contactPerson: string;
  contactPhone: string;
  email: string;
  city: string;
  commissionRate: number;
  maxWorkers: number;
  plan: string;
  isPro: boolean;
  isActive: boolean;
}

const adminCompanies: AdminCompany[] = [];

router.get('/companies', (_req, res) => {
  res.json({ companies: adminCompanies });
});

const createCompanySchema = z.object({
  name: z.string().min(2),
  commercialRegNo: z.string().min(1),
  contactPerson: z.string().optional().default(''),
  contactPhone: z.string().optional().default(''),
  email: z.string().email().optional().or(z.literal('')),
  city: z.string().optional().default(''),
  commissionRate: z.number().min(0.01).max(0.50).default(0.20),
  maxWorkers: z.number().min(1).max(500).default(5),
  plan: z.enum(['basic', 'pro', 'enterprise']).default('basic'),
  isPro: z.boolean().default(false),
});

router.post('/companies', (req, res) => {
  const parsed = createCompanySchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    return;
  }
  const company: AdminCompany = {
    id: `co_${Date.now()}`,
    ...parsed.data,
    email: parsed.data.email || '',
    isActive: true,
  };
  adminCompanies.push(company);
  res.status(201).json({ company });
});

router.patch('/companies/:id', (req, res) => {
  const c = adminCompanies.find(x => x.id === req.params.id);
  if (!c) { res.status(404).json({ message: 'Not found' }); return; }
  Object.assign(c, req.body);
  res.json({ company: c });
});

router.delete('/companies/:id', (req, res) => {
  const idx = adminCompanies.findIndex(x => x.id === req.params.id);
  if (idx === -1) { res.status(404).json({ message: 'Not found' }); return; }
  adminCompanies.splice(idx, 1);
  res.json({ message: 'Company deleted' });
});

// ── أعلام الميزات (Feature Flags) ─────────────────────────────────

const featureFlags: Record<string, boolean> = {
  offers: true, loyalty: true, referral: true, wallet: true,
  subscriptions: true, compare: true, sos: true, chat: true, tips: true,
  customerSignup: true, workerSignup: true, companySignup: true,
  googleSignIn: true, appleSignIn: true,
  walletPayment: true, cardPayment: true,
};

router.get('/feature-flags', (_req, res) => {
  res.json({ flags: featureFlags });
});

router.patch('/feature-flags', (req, res) => {
  Object.assign(featureFlags, req.body);
  res.json({ flags: featureFlags });
});

export default router;
