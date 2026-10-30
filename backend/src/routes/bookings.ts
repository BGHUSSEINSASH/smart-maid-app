import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, requireRole, type AuthedRequest } from '../middleware/auth';
import {
  MAX_BOOKING_AMOUNT,
  bookings,
  loyaltyByUser,
  makeId,
  notifications,
  persist,
  workers,
  type Booking,
} from '../store';
import { computePrice } from '../services/pricing';

const router = Router();

/** إلغاء مجاني حتى 24 ساعة قبل الموعد. */
export const FREE_CANCEL_HOURS = 24;

const bookingSchema = z.object({
  workerId: z.string().min(1),
  contractType: z.enum(['hourly', 'daily', 'weekly', 'monthly']),
  hours: z.number().int().positive().max(24),
  scheduledFor: z.string().min(10),
  addressId: z.string().optional(),
  notes: z.string().max(500).optional(),
  paymentMethod: z.enum(['cash', 'card']).default('cash'),
});

router.post('/', requireAuth, requireRole('customer'), (req: AuthedRequest, res) => {
  const parsed = bookingSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }

  const worker = workers.find((item) => item.id === parsed.data.workerId);
  if (!worker || !worker.available) {
    res.status(404).json({ message: 'Worker not found or unavailable' });
    return;
  }
  if (worker.userId === req.user!.id) {
    res.status(400).json({ message: 'You cannot book yourself' });
    return;
  }

  const scheduled = new Date(parsed.data.scheduledFor);
  if (Number.isNaN(scheduled.getTime()) || scheduled.getTime() < Date.now()) {
    res.status(400).json({ message: 'Pick a future date' });
    return;
  }

  const total = computePrice(
    worker.hourlyRate,
    parsed.data.contractType,
    parsed.data.hours,
  );
  if (total <= 0) {
    res.status(400).json({ message: 'Invalid amount' });
    return;
  }
  // سقف المبلغ يُفرض على الخادم، لا في التطبيق فقط.
  if (total > MAX_BOOKING_AMOUNT) {
    res.status(400).json({
      message: `Maximum booking amount is ${MAX_BOOKING_AMOUNT}`,
      max: MAX_BOOKING_AMOUNT,
    });
    return;
  }

  const booking: Booking = {
    id: makeId('b'),
    userId: req.user!.id,
    workerId: worker.id,
    contractType: parsed.data.contractType,
    hours: parsed.data.hours,
    scheduledFor: scheduled.toISOString(),
    addressId: parsed.data.addressId,
    notes: parsed.data.notes,
    total,
    paymentMethod: parsed.data.paymentMethod,
    status: 'pending',
    paymentStatus: 'unpaid',
    createdAt: new Date().toISOString(),
  };

  bookings.unshift(booking);

  // إشعار للعاملة صاحبة الملف.
  if (worker.userId) {
    notifications.unshift({
      id: makeId('n'),
      userId: worker.userId,
      title: 'طلب حجز جديد',
      body: `لديك طلب حجز جديد بقيمة ${total}`,
      icon: '📌',
      read: false,
      createdAt: new Date().toISOString(),
    });
  }
  persist();
  res.status(201).json(booking);
});

router.get('/', requireAuth, (req: AuthedRequest, res) => {
  const list = bookings
    .filter((b) => b.userId === req.user!.id)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  res.json({ bookings: list, count: list.length });
});

/** طلبات العاملات الواردة عبر ملف العاملة الخاص بالحساب. */
router.get(
  '/worker/incoming',
  requireAuth,
  requireRole('worker'),
  (req: AuthedRequest, res) => {
    const profile = workers.find((w) => w.userId === req.user!.id);
    if (!profile) {
      res.json({ bookings: [], count: 0 });
      return;
    }
    const list = bookings
      .filter((b) => b.workerId === profile.id)
      .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
    res.json({ bookings: list, count: list.length });
  },
);

router.get('/:id', requireAuth, (req: AuthedRequest, res) => {
  const booking = ownedBooking(req, String(req.params.id));
  if (!booking) {
    res.status(404).json({ message: 'Booking not found' });
    return;
  }
  res.json(booking);
});

const statusSchema = z.object({
  status: z.enum(['accepted', 'rejected', 'completed']),
});

/** تغيير حالة الحجز — للعاملة صاحبة الطلب أو للمدير فقط. */
router.patch(
  '/:id/status',
  requireAuth,
  requireRole('worker', 'admin'),
  (req: AuthedRequest, res) => {
    const parsed = statusSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ message: 'Invalid payload' });
      return;
    }
    const booking = bookings.find((b) => b.id === String(req.params.id));
    if (!booking) {
      res.status(404).json({ message: 'Booking not found' });
      return;
    }
    if (req.user!.role !== 'admin') {
      const profile = workers.find((w) => w.userId === req.user!.id);
      if (!profile || profile.id !== booking.workerId) {
        res.status(403).json({ message: 'Forbidden' });
        return;
      }
    }
    if (booking.status === 'cancelled') {
      res.status(400).json({ message: 'Booking is cancelled' });
      return;
    }
    booking.status = parsed.data.status;
    if (parsed.data.status === 'completed' && booking.paymentMethod === 'cash') {
      booking.paymentStatus = 'paid';
      // النقاط تُمنح على الخادم فقط بعد إتمام الخدمة.
      const record = loyaltyByUser.get(booking.userId) ?? {
        points: 0,
        history: [],
      };
      const earned = Math.round(booking.total);
      record.points += earned;
      record.history.unshift({
        title: 'إتمام حجز',
        points: earned,
        at: new Date().toISOString(),
      });
      loyaltyByUser.set(booking.userId, record);
    }
    notifications.unshift({
      id: makeId('n'),
      userId: booking.userId,
      title: 'تحديث حالة الحجز',
      body: `حجزك أصبح: ${parsed.data.status}`,
      icon: '📌',
      read: false,
      createdAt: new Date().toISOString(),
    });
    persist();
    res.json(booking);
  },
);

/** إلغاء الحجز — الزبون صاحب الحجز أو المدير. */
router.patch('/:id/cancel', requireAuth, (req: AuthedRequest, res) => {
  const booking = bookings.find((b) => b.id === String(req.params.id));
  if (!booking) {
    res.status(404).json({ message: 'Booking not found' });
    return;
  }
  if (booking.userId !== req.user!.id && req.user!.role !== 'admin') {
    res.status(403).json({ message: 'Forbidden' });
    return;
  }
  if (booking.status === 'completed') {
    res.status(400).json({ message: 'Cannot cancel a completed booking' });
    return;
  }
  if (booking.status === 'cancelled') {
    res.json(booking);
    return;
  }

  const hoursUntil = (new Date(booking.scheduledFor).getTime() - Date.now()) / 36e5;
  if (hoursUntil < FREE_CANCEL_HOURS && booking.paymentStatus === 'paid') {
    // بعد نافذة الإلغاء المجاني: تُحوَّل للمراجعة لاسترجاع جزئي.
    res.status(409).json({
      message: `Cancelling within ${FREE_CANCEL_HOURS}h of the appointment requires support review`,
      code: 'late_cancellation',
    });
    return;
  }

  booking.status = 'cancelled';
  if (booking.paymentStatus === 'paid' && booking.paymentMethod === 'card') {
    booking.paymentStatus = 'refunded';
  }
  notifications.unshift({
    id: makeId('n'),
    userId: booking.userId,
    title: 'تم إلغاء الحجز',
    body: `أُلغي الحجز ${booking.id}`,
    icon: '📌',
    read: false,
    createdAt: new Date().toISOString(),
  });
  persist();
  res.json(booking);
});

function ownedBooking(req: AuthedRequest, id: string): Booking | undefined {
  const booking = bookings.find((b) => b.id === id);
  if (!booking) return undefined;
  if (booking.userId === req.user!.id) return booking;
  if (req.user!.role === 'admin') return booking;
  const profile = workers.find((w) => w.userId === req.user!.id);
  if (profile && profile.id === booking.workerId) return booking;
  return undefined;
}

export default router;
