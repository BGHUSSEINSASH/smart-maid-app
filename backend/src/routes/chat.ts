import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthedRequest } from '../middleware/auth';
import { bookings, makeId, messages, persist, workers } from '../store';

const router = Router();

/** هل يملك هذا المستخدم حق الوصول لمحادثة الحجز؟ */
function canAccess(req: AuthedRequest, bookingId: string): boolean {
  const booking = bookings.find((b) => b.id === bookingId);
  if (!booking) return false;
  if (booking.userId === req.user!.id) return true;
  if (req.user!.role === 'admin') return true;
  const profile = workers.find((w) => w.userId === req.user!.id);
  return !!profile && profile.id === booking.workerId;
}

router.get('/:bookingId', requireAuth, (req: AuthedRequest, res) => {
  if (!canAccess(req, String(req.params.bookingId))) {
    res.status(403).json({ message: 'Forbidden' });
    return;
  }
  const list = messages
    .filter((m) => m.bookingId === String(req.params.bookingId))
    .sort((a, b) => a.createdAt.localeCompare(b.createdAt));
  res.json({ messages: list });
});

const messageSchema = z.object({
  body: z.string().min(1).max(2000),
});

router.post('/:bookingId', requireAuth, (req: AuthedRequest, res) => {
  if (!canAccess(req, String(req.params.bookingId))) {
    res.status(403).json({ message: 'Forbidden' });
    return;
  }
  const parsed = messageSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }
  const message = {
    id: makeId('m'),
    bookingId: String(req.params.bookingId),
    senderId: req.user!.id,
    body: parsed.data.body.trim(),
    createdAt: new Date().toISOString(),
  };
  messages.push(message);
  persist();
  res.status(201).json(message);
});

/** الإبلاغ عن رسالة أو مستخدم — متطلب Apple 1.2. */
const reportSchema = z.object({
  reason: z.string().min(3).max(500),
});

router.post('/:bookingId/report', requireAuth, (req: AuthedRequest, res) => {
  if (!canAccess(req, String(req.params.bookingId))) {
    res.status(403).json({ message: 'Forbidden' });
    return;
  }
  const parsed = reportSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }
  persist();
  res.status(201).json({ ok: true, message: 'Report received' });
});

export default router;
