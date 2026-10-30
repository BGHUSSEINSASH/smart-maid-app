import { Router } from 'express';
import { requireAuth, type AuthedRequest } from '../middleware/auth';
import { notifications, persist } from '../store';

const router = Router();

router.get('/', requireAuth, (req: AuthedRequest, res) => {
  const list = notifications
    .filter((n) => n.userId === req.user!.id)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  res.json({ notifications: list, unread: list.filter((n) => !n.read).length });
});

router.post('/:id/read', requireAuth, (req: AuthedRequest, res) => {
  const notification = notifications.find(
    (x) => x.id === req.params.id && x.userId === req.user!.id,
  );
  if (!notification) {
    res.status(404).json({ message: 'Not found' });
    return;
  }
  notification.read = true;
  persist();
  res.json(notification);
});

router.post('/read-all', requireAuth, (req: AuthedRequest, res) => {
  for (const notification of notifications) {
    if (notification.userId === req.user!.id) notification.read = true;
  }
  persist();
  res.json({ message: 'All marked read' });
});

export default router;
