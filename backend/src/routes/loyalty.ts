import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthedRequest } from '../middleware/auth';
import { loyaltyByUser, loyaltyCoupons, persist } from '../store';

const router = Router();

const POINTS_PER_UNIT = 20;

router.get('/', requireAuth, (req: AuthedRequest, res) => {
  const record = loyaltyByUser.get(req.user!.id) ?? { points: 0, history: [] };
  const tier =
    record.points >= 1500 ? 'gold' : record.points >= 500 ? 'silver' : 'bronze';
  res.json({
    ...record,
    tier,
    pointsPerUnit: POINTS_PER_UNIT,
    coupons: loyaltyCoupons.filter((c) => c.userId === req.user!.id && !c.used),
  });
});

const redeemSchema = z.object({
  discount: z.number().positive().max(200),
});

/**
 * استبدال النقاط بكوبون حقيقي يُقبل عند الدفع. لا تُمنح النقاط من التطبيق:
 * تُضاف فقط على الخادم بعد حجز مكتمل.
 */
router.post('/redeem', requireAuth, (req: AuthedRequest, res) => {
  const parsed = redeemSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }
  const cost = Math.round(parsed.data.discount * POINTS_PER_UNIT);
  const record = loyaltyByUser.get(req.user!.id);
  if (!record || cost > record.points) {
    res.status(400).json({ message: 'Not enough points' });
    return;
  }
  record.points -= cost;
  record.history.unshift({
    title: `استبدال بخصم ${parsed.data.discount}`,
    points: -cost,
    at: new Date().toISOString(),
  });

  const code = `LOYAL${Math.random().toString(36).slice(2, 7).toUpperCase()}`;
  const coupon = {
    code,
    userId: req.user!.id,
    // كل 20 نقطة = وحدة خصم واحدة، بحد أقصى 50%.
    discountPercent: Math.min(50, Math.round(parsed.data.discount)),
    minTotal: 0,
    used: false,
    createdAt: new Date().toISOString(),
  };
  loyaltyCoupons.push(coupon);
  persist();
  res.json({ coupon, points: record.points });
});

export default router;
