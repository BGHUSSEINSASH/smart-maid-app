import cors from 'cors';
import express from 'express';
import authRoutes from './routes/auth';
import bookingRoutes from './routes/bookings';
import paymentRoutes, { stripeWebhookHandler } from './routes/payments';
import workerRoutes from './routes/workers';
import walletRoutes from './routes/wallet';
import loyaltyRoutes from './routes/loyalty';
import offersRoutes from './routes/offers';
import reviewsRoutes from './routes/reviews';
import notificationsRoutes from './routes/notifications';
import addressesRoutes from './routes/addresses';
import referralsRoutes from './routes/referrals';
import kycRoutes from './routes/kyc';
import escrowRoutes from './routes/escrow';
import settlementsRoutes from './routes/settlements';
import articlesRoutes from './routes/articles';
import sosRoutes from './routes/sos';
import auditRoutes from './routes/audit';
import aiRoutes from './routes/ai';
import disputesRoutes from './routes/disputes';
import adminRoutes from './routes/admin';
import platformRoutes from './routes/platform';
import { suspendedMiddleware } from './middleware/suspended';

const allowedOrigins = (
  process.env.ALLOWED_ORIGINS ??
  'http://localhost:3000,http://localhost:8080,https://smartmaid-website.vercel.app'
)
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

const isAllowedOrigin = (origin?: string) => {
  if (!origin) return true;
  if (allowedOrigins.includes(origin)) return true;
  return /(^|\.)vercel\.app$/i.test(origin);
};

export function createServer(): express.Express {
  const app = express();

  app.use(
    cors({
      origin: (origin, callback) => {
        if (isAllowedOrigin(origin)) {
          callback(null, true);
          return;
        }

        callback(new Error(`Origin ${origin} is not allowed by CORS`));
      },
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    }),
  );

  app.options(
    '*',
    cors({
      origin: (origin, callback) => {
        if (isAllowedOrigin(origin)) {
          callback(null, true);
          return;
        }

        callback(new Error(`Origin ${origin} is not allowed by CORS`));
      },
      credentials: true,
    }),
  );

  const sendHealth = (
    _req: express.Request,
    res: express.Response,
  ): void => {
    res.json({
      status: 'ok',
      service: 'smart-maid-backend',
      timestamp: new Date().toISOString(),
    });
  };

  app.get('/health', sendHealth);
  app.get('/api/v1/health', sendHealth);

  app.post(
    '/api/v1/payments/webhook/stripe',
    express.raw({ type: 'application/json' }),
    stripeWebhookHandler,
  );

  app.use(express.json());

  // ── Suspended Account Middleware (بعد JSON parsing)
  app.use(suspendedMiddleware);

  app.use('/api/v1/auth', authRoutes);
  app.use('/api/v1/workers', workerRoutes);
  app.use('/api/v1/bookings', bookingRoutes);
  app.use('/api/v1/payments', paymentRoutes);
  app.use('/api/v1/wallet', walletRoutes);
  app.use('/api/v1/loyalty', loyaltyRoutes);
  app.use('/api/v1/offers', offersRoutes);
  app.use('/api/v1/reviews', reviewsRoutes);
  app.use('/api/v1/notifications', notificationsRoutes);
  app.use('/api/v1/addresses', addressesRoutes);
  app.use('/api/v1/referrals', referralsRoutes);
  app.use('/api/v1/kyc', kycRoutes);
  app.use('/api/v1/escrow', escrowRoutes);
  app.use('/api/v1/settlements', settlementsRoutes);
  app.use('/api/v1/articles', articlesRoutes);
  app.use('/api/v1/sos', sosRoutes);
  app.use('/api/v1/audit', auditRoutes);
  app.use('/api/v1/ai', aiRoutes);
  app.use('/api/v1/disputes', disputesRoutes);
  app.use('/api/v1/admin', adminRoutes);
  app.use('/api/v1/platform', platformRoutes);

  return app;
}

export default createServer;
