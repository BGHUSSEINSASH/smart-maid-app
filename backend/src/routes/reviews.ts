import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthedRequest } from '../middleware/auth';
import {
  bookings,
  loyaltyByUser,
  makeId,
  persist,
  reviews,
  workerRating,
} from '../store';

const router = Router();

router.get('/worker/:workerId', (req, res) => {
  const list = reviews
    .filter((r) => r.workerId === req.params.workerId)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  const { rating, count } = workerRating(req.params.workerId);
  res.json({
    reviews: list.map((r) => ({
      id: r.id,
      rating: r.rating,
      comment: r.comment,
      createdAt: r.createdAt,
    })),
    average: rating,
    count,
  });
});

const reviewSchema = z.object({
  bookingId: z.string().min(1),
  rating: z.number().int().min(1).max(5),
  comment: z.string().max(1000).optional(),
});

router.post('/', requireAuth, (req: AuthedRequest, res) => {
  const parsed = reviewSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }

  const booking = bookings.find(
    (b) => b.id === parsed.data.bookingId && b.userId === req.user!.id,
  );
  if (!booking) {
    res.status(404).json({ message: 'Booking not found' });
    return;
  }
  if (booking.status !== 'completed') {
    res.status(400).json({ message: 'You can review only completed bookings' });
    return;
  }
  if (reviews.some((r) => r.bookingId === booking.id)) {
    res.status(409).json({ message: 'Booking already reviewed' });
    return;
  }

  const review = {
    id: makeId('r'),
    workerId: booking.workerId,
    userId: req.user!.id,
    bookingId: booking.id,
    rating: parsed.data.rating,
    comment: parsed.data.comment?.trim() ?? '',
    createdAt: new Date().toISOString(),
  };
  reviews.push(review);

  // نقاط على أي تقييم صادق — لا مكافأة على خمس نجوم فقط (Apple 5.6).
  const record = loyaltyByUser.get(req.user!.id) ?? { points: 0, history: [] };
  record.points += 10;
  record.history.unshift({
    title: 'تقييم الخدمة',
    points: 10,
    at: new Date().toISOString(),
  });
  loyaltyByUser.set(req.user!.id, record);

  persist();
  res.status(201).json(review);
});

export default router;
