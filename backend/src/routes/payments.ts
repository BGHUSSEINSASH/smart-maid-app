import { Request, Response, Router } from 'express';
import Stripe from 'stripe';
import { z } from 'zod';
import { requireAuth, requireRole, type AuthedRequest } from '../middleware/auth';
import { bookings, persist } from '../store';

const router = Router();

const stripeSecret = process.env.STRIPE_SECRET_KEY;
const stripeWebhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

const stripe = stripeSecret
  ? new Stripe(stripeSecret, { apiVersion: '2024-06-20' as never })
  : null;

const intentSchema = z.object({
  bookingId: z.string().min(1),
});

/** هل الدفع بالبطاقة مُهيّأ فعلاً على الخادم؟ */
const cardPaymentsEnabled = () => stripe !== null;

router.get('/capabilities', (_req: Request, res: Response) => {
  res.json({
    cash: true,
    card: cardPaymentsEnabled(),
    currency: process.env.PAYMENT_CURRENCY ?? 'sar',
  });
});

router.post('/intent', requireAuth, async (req: AuthedRequest, res) => {
  const parsed = intentSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }

  const booking = bookings.find(
    (item) => item.id === parsed.data.bookingId && item.userId === req.user!.id,
  );
  if (!booking) {
    res.status(404).json({ message: 'Booking not found' });
    return;
  }
  if (booking.paymentStatus === 'paid') {
    res.status(409).json({ message: 'Booking already paid' });
    return;
  }

  // لا بطاقة بلا مزوّد دفع حقيقي — لا نُصدر نوايا دفع وهمية.
  if (!stripe) {
    res.status(503).json({
      message: 'Card payments are not configured',
      code: 'card_payments_disabled',
    });
    return;
  }

  try {
    const intent = await stripe.paymentIntents.create({
      amount: Math.round(booking.total * 100),
      currency: process.env.PAYMENT_CURRENCY ?? 'sar',
      automatic_payment_methods: { enabled: true },
      metadata: { bookingId: booking.id, userId: req.user!.id },
    });
    booking.paymentIntentId = intent.id;
    booking.paymentMethod = 'card';
    persist();
    res.json({
      paymentIntentId: intent.id,
      clientSecret: intent.client_secret,
      amount: booking.total,
      currency: intent.currency,
      bookingId: booking.id,
    });
  } catch (error) {
    res.status(502).json({
      message: 'Payment provider error',
      detail: error instanceof Error ? error.message : 'unknown',
    });
  }
});

const refundSchema = z.object({
  bookingId: z.string().min(1),
});

/** استرجاع دفعة بطاقة عبر المزوّد — يُستخدم عند الإلغاء وفق السياسة. */
router.post(
  '/refund',
  requireAuth,
  requireRole('admin'),
  async (req: AuthedRequest, res) => {
    const parsed = refundSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ message: 'Invalid payload' });
      return;
    }
    const booking = bookings.find((item) => item.id === parsed.data.bookingId);
    if (!booking) {
      res.status(404).json({ message: 'Booking not found' });
      return;
    }
    if (booking.paymentStatus !== 'paid' || !booking.paymentIntentId) {
      res.status(400).json({ message: 'Nothing to refund' });
      return;
    }
    if (!stripe) {
      res.status(503).json({ message: 'Card payments are not configured' });
      return;
    }
    try {
      await stripe.refunds.create({ payment_intent: booking.paymentIntentId });
      booking.paymentStatus = 'refunded';
      persist();
      res.json({ bookingId: booking.id, paymentStatus: booking.paymentStatus });
    } catch (error) {
      res.status(502).json({
        message: 'Refund failed',
        detail: error instanceof Error ? error.message : 'unknown',
      });
    }
  },
);

export function stripeWebhookHandler(req: Request, res: Response): void {
  // لا نقبل أي حدث بلا توقيع موثّق — وإلا استطاع أي طرف تعليم حجز كمدفوع.
  if (!stripe || !stripeWebhookSecret) {
    res.status(503).json({ message: 'Stripe webhook is not configured' });
    return;
  }

  const signature = req.header('stripe-signature');
  if (!signature) {
    res.status(400).json({ message: 'Missing Stripe signature' });
    return;
  }

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      signature,
      stripeWebhookSecret,
    );
  } catch (error) {
    res.status(400).json({
      message: 'Webhook validation failed',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
    return;
  }

  if (event.type === 'payment_intent.succeeded') {
    const intent = event.data.object as Stripe.PaymentIntent;
    const booking = bookings.find(
      (item) => item.paymentIntentId === intent.id,
    );
    if (booking) {
      booking.paymentStatus = 'paid';
      booking.status = 'accepted';
      persist();
    }
  }

  if (event.type === 'payment_intent.payment_failed') {
    const intent = event.data.object as Stripe.PaymentIntent;
    const booking = bookings.find(
      (item) => item.paymentIntentId === intent.id,
    );
    if (booking) {
      booking.paymentStatus = 'unpaid';
      persist();
    }
  }

  res.json({ received: true });
}

export default router;
