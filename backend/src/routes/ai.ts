import { Router } from 'express';
import { requireAuth, type AuthedRequest } from '../middleware/auth';
import { bookings, workerRating, workers } from '../store';

const router = Router();

const MODEL_ENDPOINT = process.env.AI_MODEL_ENDPOINT;
const MODEL_API_KEY = process.env.AI_MODEL_API_KEY;
const MODEL_NAME = process.env.AI_MODEL_NAME ?? 'gpt-4o-mini';

interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

/** سياق حقيقي من قاعدة البيانات — لا عاملات مُختلقة. */
function workerContext(): string {
  return workers
    .filter((w) => w.available)
    .map((w) => {
      const { rating, count } = workerRating(w.id);
      const stars = count > 0 ? `تقييم ${rating} من ${count}` : 'بدون تقييمات';
      return `- ${w.id}: ${w.name} (${w.category})، ${w.city}، ${w.hourlyRate}/ساعة، ${stars}`;
    })
    .join('\n');
}

/**
 * المساعد يعمل فقط عندما يكون مزوّد النموذج مُهيّأً على الخادم.
 * بدونه نُعيد 503 بدل توليد إجابات مُختلقة أو أسعار وهمية.
 */
router.post('/chat', requireAuth, async (req: AuthedRequest, res) => {
  const userMessage = String(req.body?.message ?? '').slice(0, 2000).trim();
  if (!userMessage) {
    res.status(400).json({ error: 'الرسالة فارغة' });
    return;
  }
  if (!MODEL_ENDPOINT) {
    res.status(503).json({
      code: 'assistant_unavailable',
      error: 'المساعد الذكي غير متاح حالياً',
    });
    return;
  }

  const messages: ChatMessage[] = [
    {
      role: 'system',
      content:
        'أنت مساعد لتطبيق شغالتي لخدمات العاملات المنزلية. أجب بالعربية بإيجاز. ' +
        'اعتمد فقط على هذه القائمة من الخدمات المتاحة:\n' +
        workerContext() +
        '\nلا تذكر خدمات أو أشخاصاً غير موجودين، ولا تُقدّر أسعاراً نهائية: السعر يظهر في شاشة الحجز.',
    },
    { role: 'user', content: userMessage },
  ];

  try {
    const upstream = await fetch(MODEL_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(MODEL_API_KEY ? { Authorization: `Bearer ${MODEL_API_KEY}` } : {}),
      },
      body: JSON.stringify({
        model: MODEL_NAME,
        stream: false,
        messages,
      }),
      signal: AbortSignal.timeout(20000),
    });

    if (!upstream.ok) {
      res.status(502).json({
        code: 'assistant_upstream_error',
        error: 'تعذر الوصول إلى المساعد حالياً',
      });
      return;
    }
    const data = (await upstream.json()) as {
      choices?: { message?: { content?: string } }[];
      message?: { content?: string };
    };
    const reply =
      data.choices?.[0]?.message?.content ?? data.message?.content ?? '';
    if (!reply.trim()) {
      res.status(502).json({ code: 'assistant_empty', error: 'لا يوجد رد' });
      return;
    }
    res.json({ reply: reply.trim() });
  } catch {
    res.status(504).json({ code: 'assistant_timeout', error: 'انتهت المهلة' });
  }
});

router.get('/context', requireAuth, (req: AuthedRequest, res) => {
  const userBookings = bookings.filter((b) => b.userId === req.user!.id);
  res.json({
    bookingsCount: userBookings.length,
    completed: userBookings.filter((b) => b.status === 'completed').length,
  });
});

export default router;
