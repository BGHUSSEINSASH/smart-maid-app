import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, requireRole, type AuthedRequest } from '../middleware/auth';
import {
  getWalletBalance,
  makeId,
  persist,
  walletTransactions,
} from '../store';

const router = Router();

router.get('/', requireAuth, (req: AuthedRequest, res) => {
  const userId = req.user!.id;
  const txs = walletTransactions
    .filter((t) => t.userId === userId)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  res.json({ balance: getWalletBalance(userId), transactions: txs });
});

/**
 * الشحن والسحب يحتاجان مزوّد دفع/تحويل مُهيّأ. بدونهما لا نُنشئ رصيداً
 * من الهواء — نُعيد رفضاً صريحاً.
 */
function payoutsConfigured(): boolean {
  return process.env.PAYOUTS_ENABLED === 'true';
}

router.post('/topup', requireAuth, (req: AuthedRequest, res) => {
  const schema = z.object({ amount: z.number().positive().max(5000) });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'مبلغ غير صالح' });
    return;
  }
  if (!payoutsConfigured()) {
    res.status(503).json({
      message: 'شحن المحفظة غير متاح حالياً',
      code: 'payments_not_configured',
    });
    return;
  }
  walletTransactions.push({
    id: makeId('t'),
    userId: req.user!.id,
    title: 'شحن المحفظة',
    amount: parsed.data.amount,
    type: 'topup',
    createdAt: new Date().toISOString(),
  });
  persist();
  res.status(201).json({
    message: 'تم شحن المحفظة',
    newBalance: getWalletBalance(req.user!.id),
  });
});

router.post(
  '/withdraw',
  requireAuth,
  requireRole('worker'),
  (req: AuthedRequest, res) => {
    const schema = z.object({ amount: z.number().positive() });
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ message: 'مبلغ غير صالح' });
      return;
    }
    if (!payoutsConfigured()) {
      res.status(503).json({
        message: 'طلبات السحب غير متاحة حالياً',
        code: 'payouts_not_configured',
      });
      return;
    }
    const balance = getWalletBalance(req.user!.id);
    if (parsed.data.amount > balance) {
      res.status(400).json({ message: 'الرصيد غير كافٍ', available: balance });
      return;
    }
    walletTransactions.push({
      id: makeId('t'),
      userId: req.user!.id,
      title: 'طلب سحب أرباح',
      amount: -parsed.data.amount,
      type: 'withdrawal',
      createdAt: new Date().toISOString(),
    });
    persist();
    res.status(201).json({
      message: 'تم تقديم طلب السحب',
      newBalance: getWalletBalance(req.user!.id),
    });
  },
);

export default router;
