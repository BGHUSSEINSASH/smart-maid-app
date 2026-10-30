import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthedRequest } from '../middleware/auth';
import {
  bookings,
  findUserById,
  loyaltyByUser,
  persist,
  users,
} from '../store';

const router = Router();

/** كود الإحالة ثابت ومشتق من معرّف المستخدم. */
function codeFor(userId: string): string {
  return `SMART-${userId.slice(-6).toUpperCase()}`;
}

function userByCode(code: string) {
  const normalized = code.trim().toUpperCase();
  return users.find((u) => codeFor(u.id) === normalized);
}

router.get('/me', requireAuth, (req: AuthedRequest, res) => {
  res.json({ code: codeFor(req.user!.id) });
});

const applySchema = z.object({ code: z.string().min(4) });

router.post('/apply', requireAuth, (req: AuthedRequest, res) => {
  const parsed = applySchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }
  const owner = userByCode(parsed.data.code);
  if (!owner) {
    res.status(404).json({ message: 'كود الإحالة غير صحيح' });
    return;
  }
  if (owner.id === req.user!.id) {
    res.status(400).json({ message: 'لا يمكنك استخدام كودك الخاص' });
    return;
  }
  // الإحالة متاحة قبل أي حجز فقط، ولمرة واحدة.
  const alreadyBooked = bookings.some(
    (b) => b.userId === req.user!.id && b.status !== 'cancelled',
  );
  if (alreadyBooked) {
    res.status(400).json({ message: 'الإحالة متاحة قبل أول حجز فقط' });
    return;
  }
  const mine = loyaltyByUser.get(req.user!.id) ?? { points: 0, history: [] };
  if (mine.history.some((h) => h.title === 'إحالة صديق')) {
    res.status(409).json({ message: 'تم استخدام كود إحالة مسبقاً' });
    return;
  }

  mine.points += 100;
  mine.history.unshift({
    title: 'إحالة صديق',
    points: 100,
    at: new Date().toISOString(),
  });
  loyaltyByUser.set(req.user!.id, mine);

  const ownerRecord = loyaltyByUser.get(owner.id) ?? { points: 0, history: [] };
  ownerRecord.points += 100;
  ownerRecord.history.unshift({
    title: 'مكافأة إحالة',
    points: 100,
    at: new Date().toISOString(),
  });
  loyaltyByUser.set(owner.id, ownerRecord);

  persist();
  res.json({ message: 'Referral applied', points: mine.points });
});

router.get('/:code', (req, res) => {
  const owner = userByCode(req.params.code);
  if (!owner) {
    res.status(404).json({ message: 'كود الإحالة غير صحيح' });
    return;
  }
  res.json({ ownerName: owner.name.split(' ')[0], valid: !!findUserById(owner.id) });
});

export default router;
