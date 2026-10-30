"use client";
import { useLocale } from "next-intl";

const FEATS = {
  ar: [
    { icon:"⚡", t:"حجز واضح", d:"اختر الخدمة والموعد والساعات، وترى المبلغ كاملاً قبل التأكيد", c:"icon-indigo" },
    { icon:"📩", t:"الطلب يصل للعاملة", d:"يُرسل حجزك إلى العاملة لتقبله، وتصلك التحديثات في التطبيق", c:"icon-cyan" },
    { icon:"💬", t:"محادثة داخل الحجز", d:"تواصل مع العاملة حول تفاصيل المنزل والموعد، مع إمكانية الإبلاغ", c:"icon-indigo" },
    { icon:"💵", t:"الدفع عند إتمام الخدمة", d:"تدفع نقداً بعد تنفيذ الخدمة — لا تُدخل بيانات بطاقة في التطبيق", c:"icon-cyan" },
    { icon:"📅", t:"حجز بالساعة أو باليوم", d:"ساعات محددة، أو يوم كامل، أو باقة أسبوعية أو شهرية", c:"icon-indigo" },
    { icon:"🧾", t:"فواتير قابلة للمشاركة", d:"احصل على فاتورة PDF لكل حجز وشاركها من تطبيقك", c:"icon-cyan" },
    { icon:"⭐", t:"تقييمات بعد الخدمة", d:"التقييم متاح فقط بعد إتمام حجز فعلي، ويظهر للجميع بشفافية", c:"icon-indigo" },
    { icon:"🎁", t:"نقاط وكوبونات", d:"اجمع نقاطاً على الحجوزات المكتملة واستبدلها بكوبون خصم", c:"icon-cyan" },
    { icon:"🔒", t:"قفل التطبيق برمز", d:"حماية إضافية برمز سري يمكنك تعطيله من الإعدادات", c:"icon-indigo" },
  ],
  en: [
    { icon:"⚡", t:"Clear booking", d:"Pick the service, date and hours — the full amount is shown before you confirm", c:"icon-indigo" },
    { icon:"📩", t:"Requests reach the worker", d:"Your booking is sent to the worker to accept, and updates arrive in the app", c:"icon-cyan" },
    { icon:"💬", t:"In-booking chat", d:"Discuss the home and timing with the worker, with a report option", c:"icon-indigo" },
    { icon:"💵", t:"Pay when it's done", d:"Pay cash after the service is completed — no card details in the app", c:"icon-cyan" },
    { icon:"📅", t:"Hourly, daily or longer", d:"Specific hours, a full day, or a weekly or monthly package", c:"icon-indigo" },
    { icon:"🧾", t:"Shareable invoices", d:"Get a PDF invoice for every booking and share it from the app", c:"icon-cyan" },
    { icon:"⭐", t:"Reviews after service", d:"Reviewing is only possible after a completed booking, and is public", c:"icon-indigo" },
    { icon:"🎁", t:"Points and coupons", d:"Earn points on completed bookings and redeem them for a discount", c:"icon-cyan" },
    { icon:"🔒", t:"PIN app lock", d:"Extra protection with a PIN you can turn off in settings", c:"icon-indigo" },
  ],
};

export default function FeaturesSection() {
  const locale = useLocale();
  const ar = locale === "ar";
  const items = ar ? FEATS.ar : FEATS.en;

  return (
    <section id="features" className="section" style={{ background: "var(--bg)" }}>
      <div className="mx">
        <div style={{ textAlign: "center", marginBottom: "clamp(2.5rem,5vw,4rem)" }}>
          <span className="badge badge-brand" style={{ marginBottom: "1rem" }}>
            <span className="pulse" />
            {ar ? "المميزات" : "Features"}
          </span>
          <h2 className="t-h1" style={{ color: "var(--text)", marginBottom: ".75rem" }}>
            {ar ? "مميزات التطبيق" : "What the app does"}
          </h2>
          <p className="t-lead" style={{ maxWidth: 520, marginInline: "auto" }}>
            {ar ? "ما يقدّمه التطبيق فعلياً اليوم: حجز، محادثة، تقييم بعد الخدمة، وفاتورة." : "What the app actually does today: booking, chat, post-service reviews, and invoices."}
          </p>
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "repeat(3,1fr)", gap: "1.5rem" }} className="feat-grid">
          <style>{`.feat-grid{@media(max-width:900px){grid-template-columns:repeat(2,1fr)!important}@media(max-width:560px){grid-template-columns:1fr!important}}`}</style>
          {items.map((f, i) => (
            <div key={i} className="card" style={{ padding: "2rem 1.75rem" }}>
              <div className={`icon-box ${f.c}`} style={{ marginBottom: "1.25rem", width: 52, height: 52, borderRadius: 14, fontSize: "1.4rem" }}>
                {f.icon}
              </div>
              <h3 style={{ fontSize: "1.05rem", fontWeight: 800, color: "var(--text)", marginBottom: ".5rem" }}>{f.t}</h3>
              <p style={{ fontSize: ".875rem", color: "var(--text-2)", lineHeight: 1.7 }}>{f.d}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
