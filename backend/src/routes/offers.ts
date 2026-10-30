import { Router } from 'express';
import { bookings } from '../store';
import {
  coupons,
  loyaltyCoupons,
  persist,
  type Coupon,
} from '../store';
import { tokenFromRequest, resolveTokenUser } from '../middleware/auth';

const router = Router();

router.get('/', (_req, res) => {
  res.json({ coupons });
});

/**
 * التحقق من الكوبون على الخادم — يشمل كوبونات المنصة وكوبونات النقاط.
 * الشروط (حد أدنى، حجز أول، ملكية الكوبون) تُفرض هنا لا في الواجهة.
 */
router.post('/apply', (req, res) => {
  const code = String(req.body?.code ?? '').trim().toUpperCase();
  const total = Number(req.body?.total ?? 0);
  if (!code || !Number.isFinite(total) || total <= 0) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }

  const user = resolveTokenUser(tokenFromRequest(req));

  let applied: Coupon | undefined = coupons.find((c) => c.code === code);
  if (!applied) {
    const loyalty = loyaltyCoupons.find(
      (c) => c.code === code && !c.used && (!user || c.userId === user.id),
    );
    if (loyalty) {
      applied = {
        code: loyalty.code,
        title: 'خصم من النقاط',
        discountPercent: loyalty.discountPercent,
        minTotal: loyalty.minTotal,
      };
    }
  }

  if (!applied) {
    res.status(404).json({ message: 'Coupon not found or expired' });
    return;
  }
  if (applied.firstBookingOnly && user) {
    const hasBookings = bookings.some(
      (b) => b.userId === user.id && b.status !== 'cancelled',
    );
    if (hasBookings) {
      res.status(400).json({ message: 'هذا العرض للحجز الأول فقط' });
      return;
    }
  }
  if (total < applied.minTotal) {
    res.status(400).json({ message: `Minimum total is ${applied.minTotal}` });
    return;
  }
  res.json({
    ...applied,
    discount: Math.round(((total * applied.discountPercent) / 100) * 100) / 100,
  });
});

router.post('/consume', (req, res) => {
  const code = String(req.body?.code ?? '').trim().toUpperCase();
  const user = resolveTokenUser(tokenFromRequest(req));
  const loyalty = loyaltyCoupons.find(
    (c) => c.code === code && !c.used && (!user || c.userId === user.id),
  );
  if (loyalty) {
    loyalty.used = true;
    persist();
  }
  res.json({ ok: true });
});

export default router;
