# تقرير فحص قاعدة البيانات والنظام الكامل

## ⚠️ طبيعة قاعدة البيانات

**لا توجد قاعدة بيانات حقيقية** — كل البيانات مخزّنة في الذاكرة (`backend/src/store.ts`).
تُمسح عند كل إعادة تشغيل للخادم.

---

## 📦 الكيانات (Entities) في store.ts

### 1. المستخدمون `users: User[]`
| الحقل | النوع | الوصف |
|-------|-------|-------|
| id | string | معرّف فريد (`u_<role>_<timestamp>`) |
| name | string | الاسم |
| email | string | البريد الإلكتروني |
| password | string | كلمة المرور plain-text (لا تُستخدم بعد التهيئة) |
| passwordHash | string | Hash bcrypt — تُستخدم للمصادقة |
| role | AppRole | customer / worker / admin / company |

**بيانات أولية (seed):**
| id | name | email | role |
|----|------|-------|------|
| u_customer_1 | Demo User | user@example.com | customer |
| u_worker_1 | Demo Worker | worker@example.com | worker |
| u_admin_1 | Demo Admin | admin@example.com | admin |
| u_company_1 | Ideal Cleaning Co. | company@example.com | company |

**كلمة المرور لجميعهم:** `Passw0rd!`

---

### 2. العاملات `workers: Worker[]`
| الحقل | النوع |
|-------|-------|
| id | string |
| name | string |
| image | string (URL) |
| rating | number |
| experienceYears | number |
| hourlyRate | number |

**بيانات أولية:**
| id | name | rating | hourlyRate |
|----|------|--------|-----------|
| w1 | Maria | 4.9 | 32 |
| w2 | Anna | 4.8 | 29 |
| w3 | Nour | 4.7 | 27 |

---

### 3. الحجوزات `bookings: Booking[]`
**فارغة** — تُضاف عند الحجز.

**هيكل الحجز:**
```typescript
{
  id, userId, workerId,
  contractType: 'hourly' | 'daily' | 'monthly',
  hours, notes?, total,
  status: 'pending' | 'accepted' | 'rejected' | 'completed',
  paymentStatus: 'pending' | 'processing' | 'succeeded' | 'failed',
  paymentIntentId?, createdAt
}
```

---

### 4. معاملات المحفظة `walletTransactions: WalletTransaction[]`
**فارغة.**
```typescript
{ id, userId, title, amount, type: 'topup'|'payment'|'withdrawal'|'earning'|'refund', createdAt }
```

---

### 5. نقاط الولاء `loyaltyByUser: Map<userId, LoyaltyRecord>`
**بيانات أولية:** المستخدم `u_customer_1` لديه 1250 نقطة.
```typescript
{ points: number, history: [{title, points, at}] }
```

---

### 6. الكوبونات `coupons: Coupon[]`
| code | title | خصم | حد أدنى |
|------|-------|-----|---------|
| SMART50 | خصم النصف | 50% | 50 |
| SAVE15 | وفّر 15% | 15% | 30 |
| MONTHLY10 | باقة الشهر | 10% | 200 |

---

### 7. التقييمات `reviews: Review[]`
**بيانات أولية:** تقييم واحد للعاملة w1 من u_customer_1 (5 نجوم).

---

### 8. العناوين `addresses: Address[]`
**فارغة.**
```typescript
{ id, userId, label, city, details, isDefault }
```

---

### 9. الإشعارات `notifications: AppNotification[]`
**فارغة.**

---

### 10. رموز إعادة تعيين كلمة المرور `passwordResetCodes: Map<email, code>`
مؤقتة — تُنشأ عند طلب `forgot-password`.

---

## 🔐 نظام المصادقة

| الحالة | التفاصيل |
|--------|---------|
| مع JWT_SECRET في .env | يُصدر JWT حقيقي (7 أيام) |
| بدون JWT_SECRET | يُصدر `demo-token-<userId>` (للتطوير فقط) |
| Rate limiting | 20 محاولة كل 15 دقيقة لكل IP |
| bcrypt | 10 rounds للتشفير |

---

## 🛣️ API Endpoints الكاملة (19 ملف route)

| المسار | الملف | الوظيفة |
|--------|-------|---------|
| `/api/v1/auth` | auth.ts | تسجيل دخول، تسجيل، نسيت كلمة المرور |
| `/api/v1/workers` | workers.ts | قائمة العاملات، تفاصيل عاملة |
| `/api/v1/bookings` | bookings.ts | إنشاء حجز، تحديث حالة |
| `/api/v1/payments` | payments.ts | Stripe Payment Intent، Webhook |
| `/api/v1/wallet` | wallet.ts | رصيد المحفظة، شحن، سحب |
| `/api/v1/loyalty` | loyalty.ts | نقاط الولاء، تاريخ النقاط |
| `/api/v1/offers` | offers.ts | العروض والكوبونات |
| `/api/v1/reviews` | reviews.ts | إضافة تقييم، عرض تقييمات عاملة |
| `/api/v1/notifications` | notifications.ts | جلب الإشعارات، تعليم كمقروء |
| `/api/v1/addresses` | addresses.ts | عناوين المستخدم |
| `/api/v1/referrals` | referrals.ts | نظام دعوة الأصدقاء |
| `/api/v1/kyc` | kyc.ts | توثيق هوية العاملة |
| `/api/v1/escrow` | escrow.ts | حيازة الدفع حتى اكتمال الخدمة |
| `/api/v1/settlements` | settlements.ts | مستحقات العاملات |
| `/api/v1/articles` | articles.ts | مقالات ونصائح |
| `/api/v1/sos` | sos.ts | زر الطوارئ |
| `/api/v1/audit` | audit.ts | سجل التدقيق (للإدارة) |
| `/api/v1/ai` | ai.ts | مساعد الحجز (Ollama proxy) |
| `/api/v1/disputes` | disputes.ts | النزاعات والشكاوى |
| `/api/v1/admin` | admin.ts | لوحة الإدارة |
| `/api/v1/platform` | platform.ts | إعدادات المنصة |

---

## 🚨 نقاط ضعف يجب معالجتها قبل الإطلاق الحقيقي

1. **لا استمرارية للبيانات** — يحتاج SQLite أو PostgreSQL
2. **JWT_SECRET اختياري** — يجب إجباره في الإنتاج
3. **Stripe في وضع TEST** — المفاتيح الحقيقية تحتاج تفعيل
4. **Ollama AI محلي** — يعمل على localhost فقط، لا يعمل على Render/Vercel بدون إعداد
5. **بيانات demo في الإنتاج** — المستخدمون التجريبيون يجب حذفهم عند الإطلاق

---

## 📱 Flutter App — الشاشات والمكونات

### الأدوار الأربعة:
| الدور | الشاشات الرئيسية |
|-------|-----------------|
| customer | الرئيسية، البحث، حجوزاتي، الدردشة، الملف الشخصي |
| worker | لوحة التحكم، الجدول، الطلبات، الدردشة، الملف |
| company | لوحة التحكم، الطلبات، العاملات، الدردشة، الملف |
| admin | لوحة التحكم، الشركات، المالية، النزاعات، الملف |

### Drawer — الشاشات الإضافية:
البحث، حجز جديد، حجوزاتي، المفضلة، المحفظة، نقاط الولاء، SmartGold، العروض، عناوين، نصائح التنظيف، زر الطوارئ، توثيق الهوية، أرباحي، تذكرة دعم، الأسئلة الشائعة، الإتاحة، الإعدادات

### المزودون (Providers):
- `authProvider` — حالة تسجيل الدخول والمستخدم
- `bookingProvider` — إنشاء الحجوزات وحالتها
- `myBookingsProvider` — قائمة حجوزات المستخدم
- `walletProvider` — رصيد المحفظة والمعاملات
- `loyaltyProvider` — نقاط المكافآت
- `notificationsProvider` — الإشعارات
- `favoritesProvider` — المفضلة
- `currencyProvider` — العملة (ر.س / $)
- `settingsProvider` — إعدادات التطبيق
- `chatProvider` — رسائل الدردشة
- `companyProvider` — بيانات الشركة
- `recommendationsProvider` — اقتراحات مخصصة
- `backendHealthProvider` — حالة الاتصال بالخادم
- `securityProvider` — قفل PIN وبصمة
- `achievementsProvider` — شارات الإنجاز
- `reviewProvider` — التقييمات
- `offersProvider` — الكوبونات والعروض
- `remindersProvider` — تذكيرات الحجوزات
- `auditLogProvider` — سجل التدقيق

---

*آخر تحديث: $(date)*
