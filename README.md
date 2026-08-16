# Smart Maid System

واجهة Flutter + Backend TypeScript لاختبار سيناريو الحجز والدفع المحلي مع Stripe webhook.

## ما الذي يعتبر التطبيق متكاملاً هنا؟

- تسجيل دخول + أدوار (عميل / عاملة / إدارة).
- واجهات رئيسية متعددة حسب الدور.
- تدفق حجز كامل مع حالة ومزامنة.
- تدفق دفع كامل مع Payment Intent + Webhook تجريبي.
- شاشة دردشة وتجميع Dashboards للإدارة والعاملة.
- وضع Demo Seed لتعبئة بيانات جاهزة تلقائياً قبل التشغيل.

## المتطلبات

- Flutter 3.38+
- Dart 3.10+
- Node.js 20+
- Stripe CLI (اختياري لاختبار webhook الحقيقي)

## تشغيل تطبيق Flutter

```bash
flutter pub get
flutter run -d windows
```

## تشغيل التطبيق مع بيانات تجريبية جاهزة (Seed)

```bash
flutter run -d windows --dart-define=ENABLE_DEMO_SEED=true
```

هذا الخيار يقوم تلقائياً بـ:

- تسجيل دخول مستخدم تجريبي.
- تعبئة بيانات عاملات تجريبية في الواجهة.
- حقن حالة حجز/دفع تجريبية لبدء الاختبار مباشرة.

## ملاحظة مهمة لمسارات ويندوز العربية

إذا فشل بناء ويندوز بسبب المسار العربي، استخدم مسار ASCII (Junction) ثم شغّل منه:

```powershell
cmd /c mklink /J C:\smart_maid_seed "C:\Users\BGHUSSEINSASH\شغالتي"
Set-Location C:\smart_maid_seed
flutter clean
flutter pub get
flutter run -d windows --dart-define=ENABLE_DEMO_SEED=true
```

## تشغيل Backend

```bash
cd backend
npm install
npm run dev
```

الخادم يعمل على:

```txt
http://localhost:4000
```

## حسابات تجريبية

- مستخدم: user@example.com / Passw0rd!
- عاملة: worker@example.com / Passw0rd!
- إدارة: admin@example.com / Passw0rd!

## اختبار Stripe Webhook محليًا

1. انسخ ملف البيئة:

```bash
cd backend
copy .env.example .env
```

2. ضع المفاتيح داخل .env:

```env
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

3. اربط Stripe CLI مع webhook المحلي:

```bash
stripe listen --forward-to localhost:4000/api/v1/payments/webhook/stripe
```

4. أرسل event تجريبي:

```bash
stripe trigger payment_intent.succeeded
```

## هيكل المشروع

```txt
lib/
	core/
	data/
	features/
	widgets/
backend/
	src/routes/
```
