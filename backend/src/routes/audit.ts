import { Router } from 'express';
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

interface AuditEntry {
  id: string;
  action: string;
  description: string;
  userId?: string;
  timestamp: Date;
}

const auditLog: AuditEntry[] = [];

export function logAudit(action: string, description: string, userId?: string) {
  auditLog.unshift({
    id: `al_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`,
    action,
    description,
    userId,
    timestamp: new Date(),
  });
  if (auditLog.length > 500) auditLog.length = 500;
}

// سجل التدقيق يحتوي بيانات مستخدمين — للإدارة فقط.
router.get('/', requireAuth, requireRole('admin'), (req, res) => {
  const page = Number(req.query.page ?? '1');
  const limit = Math.min(200, Number(req.query.limit ?? '50'));
  const start = (Math.max(1, page) - 1) * limit;
  const sliced = auditLog.slice(start, start + limit);
  res.json({ entries: sliced, total: auditLog.length });
});

router.get('/action/:action', requireAuth, requireRole('admin'), (req, res) => {
  const filtered = auditLog.filter((e) => e.action === req.params.action);
  res.json({ entries: filtered, total: filtered.length });
});

export default router;
