import { Router } from 'express';
import { requireAuth, requireRole, type AuthedRequest } from '../middleware/auth';
import { bookings, workers } from '../store';

const router = Router();

/**
 * المستحقات تُحسب من الحجوزات المكتملة الفعلية للعاملة — لا بيانات مُختلقة.
 * عمولة المنصة قابلة للضبط من متغيرات البيئة.
 */
const PLATFORM_FEE_RATE = Number(process.env.PLATFORM_FEE_RATE ?? 0.2);

function settlementFor(userId: string, month: string) {
  const profile = workers.find((w) => w.userId === userId);
  if (!profile) {
    return {
      month,
      totalEarnings: 0,
      platformFee: 0,
      netPayout: 0,
      bookingsCount: 0,
      settled: false,
    };
  }
  const monthBookings = bookings.filter(
    (b) =>
      b.workerId === profile.id &&
      b.status === 'completed' &&
      b.scheduledFor.startsWith(month),
  );
  const total = monthBookings.reduce((sum, b) => sum + b.total, 0);
  const fee = Math.round(total * PLATFORM_FEE_RATE * 100) / 100;
  return {
    month,
    totalEarnings: total,
    platformFee: fee,
    netPayout: Math.round((total - fee) * 100) / 100,
    bookingsCount: monthBookings.length,
    settled: monthBookings.length > 0,
  };
}

router.get('/history', requireAuth, requireRole('worker'), (req: AuthedRequest, res) => {
  const months = new Set(
    bookings.map((b) => b.scheduledFor.slice(0, 7)).filter(Boolean),
  );
  const current = new Date().toISOString().slice(0, 7);
  months.add(current);
  const records = [...months]
    .sort((a, b) => b.localeCompare(a))
    .map((month) => settlementFor(req.user!.id, month))
    .filter((r) => r.bookingsCount > 0);
  res.json({ records, total: records.length });
});

router.get('/:month', requireAuth, requireRole('worker'), (req: AuthedRequest, res) => {
  res.json(settlementFor(req.user!.id, String(req.params.month)));
});

export default router;
