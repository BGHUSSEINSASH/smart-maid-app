import { Router } from 'express';
import { workers } from '../store';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.get('/search', (_req, res) => {
  const list = workers.map(w => ({
    id: w.id,
    name: w.name,
    image: w.image,
    rating: w.rating,
    experienceYears: w.experienceYears,
    hourlyRate: w.hourlyRate,
  }));
  res.json(list);
});

router.get('/:id', requireAuth, (req, res) => {
  const worker = workers.find(w => w.id === req.params.id);
  if (!worker) {
    res.status(404).json({ message: 'Worker not found' });
    return;
  }
  res.json(worker);
});

export default router;
