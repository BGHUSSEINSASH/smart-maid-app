import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, requireRole, type AuthedRequest } from '../middleware/auth';
import { bookings } from '../store';

const router = Router();

const escrowHolds: Map<
  string,
  {
    bookingId: string;
    amount: number;
    status: 'held' | 'released' | 'refunded';
    heldAt: Date;
    releasedAt?: Date;
  }
> = new Map();

const holdSchema = z.object({
  bookingId: z.string().min(1),
});

/** الحجز الضامن يُدار من الخادم فقط: المبلغ يأتي من الحجز لا من العميل. */
router.post(
  '/hold',
  requireAuth,
  requireRole('admin'),
  (req: AuthedRequest, res) => {
    const parsed = holdSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: 'بيانات غير صحيحة' });
      return;
    }
    const booking = bookings.find((b) => b.id === parsed.data.bookingId);
    if (!booking) {
      res.status(404).json({ error: 'حجز غير موجود' });
      return;
    }
    if (escrowHolds.has(booking.id)) {
      res.status(409).json({ error: 'الحجز محجوز بالفعل' });
      return;
    }
    escrowHolds.set(booking.id, {
      bookingId: booking.id,
      amount: booking.total,
      status: 'held',
      heldAt: new Date(),
    });
    res.json({
      ok: true,
      message: `تم حفظ ${booking.total} للحجز ${booking.id}`,
    });
  },
);

router.post(
  '/release',
  requireAuth,
  requireRole('admin'),
  (req: AuthedRequest, res) => {
    const parsed = holdSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: 'بيانات غير صحيحة' });
      return;
    }
    const hold = escrowHolds.get(parsed.data.bookingId);
    if (!hold) {
      res.status(404).json({ error: 'لا يوجد حجز محجوز' });
      return;
    }
    if (hold.status !== 'held') {
      res.status(400).json({ error: 'الحجز غير محجوز حالياً' });
      return;
    }
    hold.status = 'released';
    hold.releasedAt = new Date();
    res.json({ ok: true, message: `تم تحرير ${hold.amount}` });
  },
);

router.get('/booking/:id', requireAuth, (req: AuthedRequest, res) => {
  const booking = bookings.find((b) => b.id === String(req.params.id));
  if (!booking) {
    res.status(404).json({ error: 'حجز غير موجود' });
    return;
  }
  const isOwner = booking.userId === req.user!.id;
  if (!isOwner && req.user!.role !== 'admin') {
    res.status(403).json({ error: 'Forbidden' });
    return;
  }
  const hold = escrowHolds.get(String(req.params.id));
  if (!hold) {
    res.json({ status: 'none' });
    return;
  }
  res.json({ status: hold.status, amount: hold.amount });
});

export default router;
