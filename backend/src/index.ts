import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import authRoutes from './routes/auth';
import bookingRoutes from './routes/bookings';
import paymentRoutes, { stripeWebhookHandler } from './routes/payments';
import workerRoutes from './routes/workers';

dotenv.config();

const app = express();

app.use(
  cors({
    origin: true,
    credentials: true,
  }),
);

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'smart-maid-backend' });
});

app.post(
  '/api/v1/payments/webhook/stripe',
  express.raw({ type: 'application/json' }),
  stripeWebhookHandler,
);

app.use(express.json());

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/workers', workerRoutes);
app.use('/api/v1/bookings', bookingRoutes);
app.use('/api/v1/payments', paymentRoutes);

const port = Number(process.env.PORT ?? 4000);
app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`API listening on http://localhost:${port}`);
});
