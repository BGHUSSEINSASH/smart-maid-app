# شغّالتي — تطبيق خدمات منزلية

منصة متكاملة لحجز عاملات منزليات موثوقات.

## هيكل المشروع

```
/                   ← تطبيق Flutter (iOS / Android / Windows / Web)
├── lib/            ← كود Flutter
├── backend/        ← خادم Node.js + TypeScript
├── website/        ← موقع الويب (Next.js)
├── android/        ← مشروع Android
├── ios/            ← مشروع iOS
└── web/            ← Flutter Web build
```

## الروابط

| | الرابط |
|-|--------|
| 🌐 موقع الويب | https://smartmaid-website.vercel.app |
| 🔧 Backend API | https://smaidapi.vercel.app/api/v1/health |
| 📦 تحميل APK | https://github.com/BGHUSSEINSASH/smartmaid-app/releases |

## تشغيل التطبيق

```bash
flutter pub get
flutter run
```

## تشغيل الخادم

```bash
cd backend
npm install
npm run dev
```

## تشغيل الموقع

```bash
cd website
npm install
npm run dev
```

## الأدوار التجريبية

| الدور | البريد | كلمة المرور |
|-------|--------|-------------|
| عميل | user@example.com | Passw0rd! |
| عاملة | worker@example.com | Passw0rd! |
| مدير | admin@example.com | Passw0rd! |
| شركة | company@example.com | Passw0rd! |
