import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthedRequest } from '../middleware/auth';
import { addresses, makeId, persist } from '../store';

const router = Router();

router.get('/', requireAuth, (req: AuthedRequest, res) => {
  res.json({
    addresses: addresses.filter((a) => a.userId === req.user!.id),
  });
});

const upsertSchema = z.object({
  id: z.string().optional(),
  label: z.string().min(1).max(40),
  city: z.string().min(1).max(60),
  details: z.string().min(1).max(300),
  isDefault: z.boolean().optional(),
});

router.post('/', requireAuth, (req: AuthedRequest, res) => {
  const parsed = upsertSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }
  const data = parsed.data;
  if (data.isDefault) {
    for (const a of addresses.filter((a) => a.userId === req.user!.id)) {
      a.isDefault = false;
    }
  }
  if (data.id) {
    const existing = addresses.find(
      (a) => a.id === data.id && a.userId === req.user!.id,
    );
    if (!existing) {
      res.status(404).json({ message: 'Not found' });
      return;
    }
    Object.assign(existing, data);
    persist();
    res.json(existing);
    return;
  }
  const address = {
    id: makeId('a'),
    userId: req.user!.id,
    label: data.label,
    city: data.city,
    details: data.details,
    isDefault: data.isDefault ?? addresses.filter((a) => a.userId === req.user!.id).length === 0,
  };
  addresses.push(address);
  persist();
  res.status(201).json(address);
});

router.delete('/:id', requireAuth, (req: AuthedRequest, res) => {
  const idx = addresses.findIndex(
    (a) => a.id === req.params.id && a.userId === req.user!.id,
  );
  if (idx < 0) {
    res.status(404).json({ message: 'Not found' });
    return;
  }
  addresses.splice(idx, 1);
  persist();
  res.json({ message: 'Deleted' });
});

export default router;
