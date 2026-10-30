import { Router } from 'express';
import { z } from 'zod';
import {
  persist,
  reviews,
  workerRating,
  workers,
  makeId,
  type Worker,
} from '../store';
import { requireAuth, requireRole, type AuthedRequest } from '../middleware/auth';

const router = Router();

function publicWorker(worker: Worker) {
  const { rating, count } = workerRating(worker.id);
  return {
    id: worker.id,
    name: worker.name,
    city: worker.city,
    category: worker.category,
    experienceYears: worker.experienceYears,
    hourlyRate: worker.hourlyRate,
    bio: worker.bio,
    available: worker.available,
    rating,
    reviewsCount: count,
  };
}

/** كتالوج العاملات — عام ليتمكن الزائر من التصفح قبل التسجيل. */
router.get('/search', (req, res) => {
  const q = String(req.query.q ?? '').trim().toLowerCase();
  const city = String(req.query.city ?? '').trim();
  const list = workers
    .filter((w) => w.available)
    .filter((w) => (city ? w.city === city : true))
    .filter((w) =>
      q
        ? `${w.name} ${w.category} ${w.bio} ${w.city}`.toLowerCase().includes(q)
        : true,
    )
    .map(publicWorker);
  res.json(list);
});

router.get('/cities', (_req, res) => {
  res.json({ cities: [...new Set(workers.map((w) => w.city))] });
});

router.get('/me', requireAuth, requireRole('worker'), (req: AuthedRequest, res) => {
  let profile = workers.find((w) => w.userId === req.user!.id);
  if (!profile) {
    profile = {
      id: makeId('w'),
      userId: req.user!.id,
      name: req.user!.name,
      city: '',
      category: '',
      experienceYears: 0,
      hourlyRate: 0,
      bio: '',
      available: false,
    };
    workers.push(profile);
    persist();
  }
  res.json(publicWorker(profile));
});

const profileSchema = z.object({
  city: z.string().min(2).optional(),
  category: z.string().min(2).optional(),
  experienceYears: z.number().int().min(0).max(60).optional(),
  hourlyRate: z.number().min(0).max(1000).optional(),
  bio: z.string().max(600).optional(),
  available: z.boolean().optional(),
});

router.patch('/me', requireAuth, requireRole('worker'), (req: AuthedRequest, res) => {
  const parsed = profileSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }
  let profile = workers.find((w) => w.userId === req.user!.id);
  if (!profile) {
    profile = {
      id: makeId('w'),
      userId: req.user!.id,
      name: req.user!.name,
      city: '',
      category: '',
      experienceYears: 0,
      hourlyRate: 0,
      bio: '',
      available: false,
    };
    workers.push(profile);
  }
  Object.assign(profile, parsed.data);
  persist();
  res.json(publicWorker(profile));
});

/** الملف العام — متاح للزائر. */
router.get('/:id', (req, res) => {
  const worker = workers.find((w) => w.id === req.params.id);
  if (!worker) {
    res.status(404).json({ message: 'Worker not found' });
    return;
  }
  res.json({
    ...publicWorker(worker),
    reviews: reviews
      .filter((r) => r.workerId === worker.id)
      .map((r) => ({
        id: r.id,
        rating: r.rating,
        comment: r.comment,
        createdAt: r.createdAt,
      })),
  });
});

export default router;
