import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, requireRole, AuthedRequest } from '../middleware/auth';
import { walletTransactions, getWalletBalance } from '../store';

const router = Router();

router.get('/', requireAuth, (req: AuthedRequest, res) => {
  const userId = req.user!.id;
  const txs = walletTransactions
    .filter((t) => t.userId === userId)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  const balance = getWalletBalance(userId);
  res.json({ balance, transactions: txs });
});

router.post('/topup', requireAuth, (req: AuthedRequest, res) => {
  const schema = z.object({ amount: z.number().positive().max(5000) });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'مبلغ غير صالح' });
    return;
  }
  walletTransactions.push({
    id: `t_${Date.now()}`,
    userId: req.user!.id,
    title: 'شحن المحفظة',
    amount: parsed.data.amount,
    type: 'topup',
    createdAt: new Date().toISOString(),
  });
  res.status(201).json({
    message: 'تم شحن المحفظة',
    newBalance: getWalletBalance(req.user!.id),
  });
});

router.post(
  '/withdraw',
  requireAuth,
  requireRole('worker', 'admin'),
  (req: AuthedRequest, res) => {
    const schema = z.object({ amount: z.number().positive() });
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ message: 'مبلغ غير صالح' });
      return;
    }
    const balance = getWalletBalance(req.user!.id);
    if (parsed.data.amount > balance) {
      res.status(400).json({ message: 'الرصيد غير كافٍ', available: balance });
      return;
    }
    walletTransactions.push({
      id: `t_${Date.now()}`,
      userId: req.user!.id,
      title: 'طلب سحب أرباح',
      amount: -parsed.data.amount,
      type: 'withdrawal',
      createdAt: new Date().toISOString(),
    });
    res.status(201).json({
      message: 'تم تقديم طلب السحب',
      newBalance: getWalletBalance(req.user!.id),
    });
  },
);

export default router;
