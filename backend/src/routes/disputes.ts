import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, requireRole, type AuthedRequest } from '../middleware/auth';
import { bookings, makeId, notifications, persist } from '../store';

const router = Router();

export interface Dispute {
  id: string;
  bookingId: string;
  userId: string;
  category: string;
  subject: string;
  detail: string;
  status: 'open' | 'reviewing' | 'resolved';
  createdAt: string;
}

const disputes: Dispute[] = [];

const disputeSchema = z.object({
  bookingId: z.string().min(1),
  category: z.string().min(2).max(40),
  subject: z.string().min(3).max(120),
  detail: z.string().min(10).max(2000),
});

/** المستخدم يرى نزاعاته فقط، والإدارة ترى الكل. */
router.get('/', requireAuth, (req: AuthedRequest, res) => {
  const list =
    req.user!.role === 'admin'
      ? disputes
      : disputes.filter((d) => d.userId === req.user!.id);
  res.json({ disputes: list, total: list.length });
});

router.post('/', requireAuth, (req: AuthedRequest, res) => {
  const parsed = disputeSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: 'بيانات غير صحيحة' });
    return;
  }
  const booking = bookings.find(
    (b) => b.id === parsed.data.bookingId && b.userId === req.user!.id,
  );
  if (!booking) {
    res.status(404).json({ error: 'حجز غير موجود' });
    return;
  }
  const dispute: Dispute = {
    id: makeId('d'),
    bookingId: booking.id,
    userId: req.user!.id,
    category: parsed.data.category,
    subject: parsed.data.subject,
    detail: parsed.data.detail,
    status: 'open',
    createdAt: new Date().toISOString(),
  };
  disputes.unshift(dispute);
  res.status(201).json({ ok: true, dispute });
});

const statusSchema = z.object({
  status: z.enum(['open', 'reviewing', 'resolved']),
});

/** تغيير حالة النزاع — إدارة فقط. */
router.post(
  '/:id/status',
  requireAuth,
  requireRole('admin'),
  (req: AuthedRequest, res) => {
    const parsed = statusSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: 'حالة غير صحيحة' });
      return;
    }
    const dispute = disputes.find((d) => d.id === req.params.id);
    if (!dispute) {
      res.status(404).json({ error: 'نزاع غير موجود' });
      return;
    }
    dispute.status = parsed.data.status;
    notifications.unshift({
      id: makeId('n'),
      userId: dispute.userId,
      title: 'تحديث النزاع',
      body: `حالة نزاعك الآن: ${parsed.data.status}`,
      icon: '⚖️',
      read: false,
      createdAt: new Date().toISOString(),
    });
    persist();
    res.json({ ok: true, dispute });
  },
);

export default router;
