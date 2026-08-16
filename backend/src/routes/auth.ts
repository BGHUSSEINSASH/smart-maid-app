import { Router } from 'express';
import { z } from 'zod';
import { makeToken, users } from '../store';

const router = Router();

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

router.post('/login', (req, res) => {
  const parsed = loginSchema.safeParse(req.body);

  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    return;
  }

  const user = users.find(
    (candidate) =>
      candidate.email.toLowerCase() === parsed.data.email.toLowerCase() &&
      candidate.password === parsed.data.password,
  );

  if (!user) {
    res.status(401).json({ message: 'Invalid credentials' });
    return;
  }

  res.json({
    token: makeToken(user),
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
  });
});

export default router;
