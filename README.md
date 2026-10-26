# شغالتي — تطبيق خدمات المنازل

تطبيق Flutter لحجز عاملات منزليات موثوقات، مع backend TypeScript/Express.

## هيكل المشروع

```
lib/          — تطبيق Flutter (العميل)
backend/src/  — خادم Express + TypeScript
api/          — نقطة دخول Vercel serverless
web/          — ملفات Flutter Web
```

## الأدوار المتاحة

| الدور | البريد التجريبي | كلمة المرور |
|-------|----------------|-------------|
| عميل | user@example.com | Passw0rd! |
| عاملة | worker@example.com | Passw0rd! |
| إدارة | admin@example.com | Passw0rd! |
| شركة | company@example.com | Passw0rd! |

## تشغيل التطبيق

```bash
flutter pub get
flutter run -d windows
```

### تشغيل مع بيانات تجريبية جاهزة

```bash
flutter run -d windows --dart-define=ENABLE_DEMO_SEED=true
```

> **ملاحظة لمسارات ويندوز العربية:** إذا فشل البناء بسبب المسار، استخدم junction:
> ```powershell
> cmd /c mklink /J C:\shaghalti "C:\Users\BGHUSSEINSASH\شغالتي"
> cd C:\shaghalti
> flutter run -d windows
> ```

## تشغيل الخادم

```bash
cd backend
npm install
npm run dev
```

### متغيرات البيئة المطلوبة (backend/.env)

```env
PORT=3000
JWT_SECRET=your_secret_here
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
ALLOWED_ORIGINS=http://localhost:8080
```

## النشر

- **Frontend:** Vercel — يوجّه عبر `vercel.json`
- **Backend:** Render — انظر `render.yaml`

## قاعدة البيانات

البيانات حالياً في الذاكرة (`backend/src/store.ts`) — راجع `DATABASE_REPORT.md` للتفاصيل الكاملة.

## المتطلبات

- Flutter 3.38+
- Node.js 20+
