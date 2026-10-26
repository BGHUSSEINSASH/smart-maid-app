# تقرير قاعدة البيانات والنظام الكامل — شغالتي

> آخر فحص: اختُبر الـ API بالكامل ✅ — 16/16 اختبار ناجح

---

## ⚠️ طبيعة قاعدة البيانات

**لا توجد قاعدة بيانات حقيقية** — كل البيانات في الذاكرة (`backend/src/store.ts`).  
تُمسح عند كل إعادة تشغيل للخادم. مناسبة للتطوير والتجربة فقط.

---

## 📦 الكيانات (Entities)

### 1. المستخدمون `users: User[]`

| id | name | email | role | كلمة المرور |
|----|------|-------|------|------------|
| u_customer_1 | Demo User | user@example.com | customer | Passw0rd! |
| u_worker_1 | Demo Worker | worker@example.com | worker | Passw0rd! |
| u_admin_1 | Demo Admin | admin@example.com | admin | Passw0rd! |
| u_company_1 | Ideal Cleaning Co. | company@example.com | company | Passw0rd! |

**هيكل البيانات:**
```typescript
{ id, name, email, password, passwordHash, role, isActive?, suspendReason? }
```

---

### 2. العاملات `workers: Worker[]`

| id | name | rating | hourlyRate | سنوات الخبرة |
|----|------|--------|-----------|-------------|
| w1 | ماريا سانتوس | 4.9 | $32 | 7 |
| w2 | آنا كوفالسكي | 4.8 | $29 | 6 |
| w3 | نور خليل | 4.7 | $27 | 5 |
| w4 | فاطمة الحسن | 4.8 | $30 | 5 |
| w5 | لينا رودريغيز | 4.8 | $35 | 6 |

---

### 3. الحجوزات `bookings: Booking[]`

**فارغة عند البدء** — تُضاف عبر API.

```typescript
{
  id,           // b_<timestamp>
  userId,       // مرتبط بـ users
  workerId,     // مرتبط بـ workers
  contractType, // 'hourly' | 'daily' | 'monthly'
  hours,
  notes?,
  total,        // hours * worker.hourlyRate
  status,       // 'pending' | 'accepted' | 'rejected' | 'completed'
  paymentStatus,// 'pending' | 'processing' | 'succeeded' | 'failed'
  paymentIntentId?,
  createdAt
}
```

---

### 4. المحفظة

**رصيد أولي:**
| userId | الرصيد |
|--------|-------|
| u_customer_1 | $250 |
| u_worker_1 | $80 |

```typescript
// معاملات: walletTransactions[]
{ id, userId, title, amount, type: 'topup'|'payment'|'withdrawal'|'earning'|'refund', createdAt }
```

---

### 5. نقاط الولاء `loyaltyByUser: Map`

| userId | نقاط |
|--------|------|
| u_customer_1 | 1250 |

---

### 6. الكوبونات `coupons: Coupon[]`

| code | خصم | حد أدنى |
|------|-----|---------|
| SMART50 | 50% | $50 |
| SAVE15 | 15% | $30 |
| MONTHLY10 | 10% | $200 |

---

### 7. التقييمات `reviews: Review[]`

تقييم واحد — w1 من u_customer_1 (5 نجوم): *"ممتازة جداً! المنزل نظيف بشكل رائع."*

---

### 8. بيانات أخرى (فارغة عند البدء)

- `addresses: Address[]` — عناوين المستخدمين
- `notifications: AppNotification[]` — الإشعارات
- `passwordResetCodes: Map<email, code>` — رموز إعادة تعيين كلمة المرور (مؤقتة)

---

## 🛣️ API Endpoints الكاملة — مُختبَرة ✅

### `/api/v1/auth`
| Method | Path | الوصف | مصادقة |
|--------|------|-------|--------|
| POST | /login | تسجيل دخول | لا |
| POST | /register | تسجيل حساب جديد | لا |
| POST | /forgot-password | طلب رمز إعادة تعيين | لا |
| POST | /reset-password | إعادة تعيين كلمة المرور | لا |
| GET | /me | بيانات المستخدم الحالي | ✅ نعم |

### `/api/v1/workers`
| Method | Path | الوصف |
|--------|------|-------|
| GET | /search | قائمة العاملات |
| GET | /:id | تفاصيل عاملة محددة |

### `/api/v1/bookings`
| Method | Path | الوصف |
|--------|------|-------|
| POST | / | إنشاء حجز جديد |
| GET | / | حجوزات المستخدم الحالي |
| GET | /:id | تفاصيل حجز |
| PATCH | /:id/cancel | إلغاء حجز |

### `/api/v1/payments`
| Method | Path | الوصف |
|--------|------|-------|
| POST | /intent | إنشاء Payment Intent (Stripe/mock) |
| POST | /:paymentId/status | تحديث حالة الدفع |
| POST | /webhook/stripe | Stripe Webhook |

### `/api/v1/wallet`
| Method | Path | الوصف |
|--------|------|-------|
| GET | / | الرصيد والمعاملات |
| POST | /topup | شحن المحفظة |
| POST | /withdraw | سحب (worker/admin فقط) |

### `/api/v1/loyalty`
| Method | Path | الوصف |
|--------|------|-------|
| GET | / | نقاط الولاء |
| POST | /add | إضافة نقاط |

### `/api/v1/reviews`
| Method | Path | الوصف |
|--------|------|-------|
| GET | /worker/:workerId | تقييمات عاملة |
| POST | / | إضافة تقييم |

### `/api/v1/admin` (admin فقط)
- GET /users — قائمة المستخدمين
- PATCH /users/:id/suspend — تعليق حساب
- PATCH /users/:id/activate — تفعيل حساب
- DELETE /users/:id — حذف مستخدم
- GET/POST /commissions — العمولات
- GET/POST /discounts — الخصومات
- PATCH /discounts/:id/toggle — تفعيل/تعطيل خصم
- GET/PATCH /settings — إعدادات النظام
- GET/POST/PATCH/DELETE /companies — الشركات
- GET/PATCH /feature-flags — أعلام الميزات (16 علم)

### `/api/v1/platform`
- GET /flags — كل الـ flags (60 علم)
- GET /maintenance — حالة الصيانة
- PUT /flags — تحديث (admin)
- PUT /maintenance — تفعيل الصيانة
- GET/POST/PUT/DELETE /subscriptions — الاشتراكات

### باقي الـ endpoints
- `/api/v1/offers` — العروض والكوبونات
- `/api/v1/notifications` — الإشعارات
- `/api/v1/addresses` — العناوين
- `/api/v1/referrals` — نظام الدعوة
- `/api/v1/kyc` — توثيق الهوية
- `/api/v1/escrow` — نظام الحيازة
- `/api/v1/settlements` — مستحقات العاملات
- `/api/v1/articles` — المقالات
- `/api/v1/sos` — زر الطوارئ
- `/api/v1/audit` — سجل التدقيق
- `/api/v1/ai` — مساعد الحجز (Ollama)
- `/api/v1/disputes` — النزاعات

---

## 🔐 المصادقة

| الحالة | التفاصيل |
|--------|---------|
| مع `JWT_SECRET` | JWT حقيقي، صالح 7 أيام |
| بدون `JWT_SECRET` | `demo-token-<userId>` للتطوير |
| Rate limit | 20 محاولة / 15 دقيقة / IP |
| bcrypt | 10 rounds |

---

## 📱 Flutter App — هيكل الشاشات

### أدوار وتبويبات التنقل

| الدور | Tab 1 | Tab 2 | Tab 3 | Tab 4 | Tab 5 |
|-------|-------|-------|-------|-------|-------|
| customer | الرئيسية | البحث | حجوزاتي | الدردشة | حسابي |
| worker | لوحة تحكم | الجدول | الطلبات | الدردشة | حسابي |
| company | لوحة تحكم | الطلبات | العاملات | الدردشة | حسابي |
| admin | لوحة تحكم | الشركات | المالية | النزاعات | حسابي |

### جميع المسارات (Routes)

| المسار | الشاشة |
|--------|--------|
| /splash | شاشة التحميل |
| /onboarding | الترحيب |
| /login | تسجيل الدخول |
| /register | التسجيل |
| /forgot-password | نسيت كلمة المرور |
| / | MainShell (حسب الدور) |
| /worker/:id | ملف العاملة |
| /booking | شاشة الحجز |
| /bookings | حجوزاتي |
| /payment | الدفع |
| /chat | الدردشة |
| /chat/support | دعم العملاء |
| /wallet | المحفظة |
| /loyalty | نقاط المكافآت |
| /offers | العروض والكوبونات |
| /favorites | المفضلة |
| /search | البحث |
| /faq | الأسئلة الشائعة |
| /active-booking/:id | حجز جارٍ |
| /completion/:bookingId | إتمام الخدمة |
| /subscription | الاشتراكات |
| /compare | مقارنة عاملات |
| /tips | نصائح التنظيف |
| /support | تذكرة الدعم |
| /accessibility | إعدادات الإتاحة |
| /security | إعدادات الأمان |
| /admin/audit | سجل التدقيق |
| /company/billing | فواتير الشركة |
| /referral | الدعوة والإحالة |
| /sos | زر الطوارئ |
| /kyc | توثيق الهوية |
| /settlements | أرباحي ومستحقاتي |

### المزودون (Providers)

| Provider | الوظيفة |
|----------|---------|
| authProvider | حالة تسجيل الدخول والمستخدم |
| bookingFlowProvider | تدفق إنشاء الحجز |
| myBookingsProvider | قائمة الحجوزات |
| walletProvider | المحفظة والمعاملات |
| loyaltyProvider | نقاط المكافآت |
| notificationsProvider | الإشعارات |
| favoritesProvider | المفضلة |
| currencyProvider | العملة (ر.س / $) |
| settingsProvider | إعدادات التطبيق |
| chatProvider | الدردشة |
| companyProvider | بيانات الشركة |
| recommendationsProvider | اقتراحات مخصصة |
| backendHealthProvider | حالة الاتصال بالخادم |
| securityProvider | قفل PIN وبصمة |
| achievementsProvider | شارات الإنجاز |
| reviewProvider | التقييمات |
| offersProvider | الكوبونات والعروض |
| remindersProvider | تذكيرات الحجوزات |
| auditLogProvider | سجل التدقيق |
| addressProvider | عناوين المستخدم |
| subscriptionProvider | الاشتراكات |
| trustProvider | ثقة ومصداقية |

---

## ⚠️ ما يجب فعله قبل الإطلاق الحقيقي

1. **قاعدة بيانات** — استبدال store.ts بـ PostgreSQL أو SQLite
2. **JWT_SECRET إجباري** — يجب ضبطه في `.env` للإنتاج
3. **Stripe حقيقي** — استبدال `pi_mock_*` بمفاتيح إنتاج
4. **Ollama AI** — يعمل محلياً فقط، يحتاج deployment منفصل للإنتاج
5. **حذف بيانات demo** — إزالة المستخدمين التجريبيين عند الإطلاق
6. **HTTPS** — إجباري في الإنتاج
