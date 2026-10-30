import { Router } from 'express';
import { requireAuth } from '../middleware/auth';

const router = Router();

/**
 * تنبيه الطوارئ غير مفعّل في الإصدار الأول: لا يوجد فريق أمان يعمل 24/7
 * يستقبل التنبيهات، وإظهار رسالة "تم إبلاغ فريق الأمان" بلا فريق فعلي
 * مخالفة صريحة (App Store 1.4 / 2.3.1، Google Play Misrepresentation).
 * فعّله فقط بعد ربط قناة استقبال حقيقية (SOS_WEBHOOK_URL).
 */
const enabled = () => Boolean(process.env.SOS_WEBHOOK_URL);

router.post('/', requireAuth, (_req, res) => {
  if (!enabled()) {
    res.status(503).json({
      code: 'sos_unavailable',
      message: 'تنبيه الطوارئ غير متاح. اتصل برقم الطوارئ في بلدك.',
    });
    return;
  }
  res.status(501).json({ message: 'Not implemented' });
});

export default router;
