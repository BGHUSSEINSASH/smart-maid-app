"use client";
import { useParams } from "next/navigation";

const ar = {
  title: "باقات SmartMaid",
  subtitle: "اختر الباقة المناسبة لاحتياجاتك",
  monthly: "شهرياً",
  mostPopular: "الأكثر طلباً",
  getStarted: "ابدأ الآن",
  subscribe: "اشترك الآن",
  currentPlan: "باقتك الحالية",
  features: "المميزات",
  faq: "الأسئلة الشائعة",
  plans: [
    {
      name: "مجاني",
      nameEn: "Free",
      price: "0",
      color: "#64748B",
      icon: "👤",
      popular: false,
      features: [
        "حجز الخدمات الأساسية",
        "بحث عن العاملات",
        "دعم عبر البريد",
        "حجز واحد في اليوم",
      ],
      notIncluded: [
        "خصم على الحجوزات",
        "أولوية في النتائج",
        "إلغاء مجاني",
        "دعم أولوية",
      ],
    },
    {
      name: "SmartGold",
      nameEn: "Gold",
      price: "9.99",
      color: "#D97706",
      icon: "✨",
      popular: true,
      features: [
        "خصم 10% على كل الحجوزات",
        "أولوية في نتائج البحث",
        "إلغاء مجاني قبل 24 ساعة",
        "دعم أولوية",
        "حجوزات غير محدودة",
        "إشعارات مخصصة",
      ],
      notIncluded: [
        "عاملة بديلة مجانية",
        "دعم 24/7 مباشر",
        "هدايا على الحجوزات",
      ],
    },
    {
      name: "SmartPlatinum",
      nameEn: "Platinum",
      price: "19.99",
      color: "#7C3AED",
      icon: "💎",
      popular: false,
      features: [
        "خصم 15% على كل الحجوزات",
        "أولوية قصوى في النتائج",
        "إلغاء مجاني في أي وقت",
        "دعم مباشر 24/7",
        "عاملة بديلة مجانية",
        "هدايا على كل الحجوزات",
        "تقارير شهرية مخصصة",
        "مدير حساب شخصي",
      ],
      notIncluded: [],
    },
  ],
  faqs: [
    {
      q: "كيف يتم الدفع؟",
      a: "يُخصم مبلغ الاشتراك مباشرة من محفظتك الرقمية داخل التطبيق. تأكد من أن رصيدك كافٍ قبل الاشتراك.",
    },
    {
      q: "هل يمكن إلغاء الاشتراك؟",
      a: "نعم، يمكنك إلغاء الاشتراك في أي وقت من الإعدادات. لن يتم الاسترداد للأشهر المدفوعة مسبقاً.",
    },
    {
      q: "هل الخصم يُطبَّق تلقائياً؟",
      a: "نعم! عند إتمام الحجز، يُحسب الخصم تلقائياً ويظهر في شاشة الدفع قبل التأكيد.",
    },
    {
      q: "هل يمكن للإدارة منح اشتراك؟",
      a: "نعم، فريق SmartMaid يمكنه منح اشتراكات مجانية أو ممتدة لعملاء مميزين.",
    },
    {
      q: "ماذا يحدث عند انتهاء الاشتراك؟",
      a: "يعود حسابك تلقائياً للباقة المجانية. ستصلك إشعار قبل 3 أيام من الانتهاء.",
    },
  ],
};

const en = {
  title: "SmartMaid Plans",
  subtitle: "Choose the plan that fits your needs",
  monthly: "/ month",
  mostPopular: "Most Popular",
  getStarted: "Get Started",
  subscribe: "Subscribe Now",
  currentPlan: "Your Plan",
  features: "Features",
  faq: "FAQ",
  plans: ar.plans,
  faqs: ar.faqs,
};

export default function PricingPage() {
  const { locale } = useParams<{ locale: string }>();
  const t = locale === "ar" ? ar : en;
  const isAr = locale === "ar";

  return (
    <main dir={isAr ? "rtl" : "ltr"} style={{ minHeight: "100vh", background: "var(--bg)", fontFamily: "var(--font)" }}>
      {/* Header */}
      <section style={{
        background: "linear-gradient(135deg, #03045A 0%, #0353A4 100%)",
        padding: "80px 24px 60px",
        textAlign: "center",
        color: "white",
      }}>
        <h1 style={{ fontSize: "clamp(2rem, 5vw, 3rem)", fontWeight: 900, margin: 0 }}>{t.title}</h1>
        <p style={{ fontSize: "1.1rem", opacity: 0.8, marginTop: 12 }}>{t.subtitle}</p>
      </section>

      {/* Plans Grid */}
      <section style={{ maxWidth: 1100, margin: "0 auto", padding: "60px 24px" }}>
        <div style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))",
          gap: 24,
          alignItems: "start",
        }}>
          {t.plans.map((plan) => (
            <div key={plan.nameEn} style={{
              background: plan.popular ? "linear-gradient(135deg, #03045A, #0353A4)" : "var(--surface)",
              borderRadius: 24,
              padding: 32,
              border: plan.popular ? "none" : "1px solid var(--border)",
              position: "relative",
              transform: plan.popular ? "scale(1.04)" : "scale(1)",
              boxShadow: plan.popular ? "0 20px 60px rgba(3,5,90,0.3)" : "0 4px 20px rgba(0,0,0,0.06)",
              color: plan.popular ? "white" : "var(--text)",
            }}>
              {plan.popular && (
                <div style={{
                  position: "absolute",
                  top: -14,
                  left: "50%",
                  transform: "translateX(-50%)",
                  background: "#F59E0B",
                  color: "white",
                  padding: "4px 18px",
                  borderRadius: 20,
                  fontSize: ".8rem",
                  fontWeight: 800,
                  whiteSpace: "nowrap",
                }}>
                  ⭐ {t.mostPopular}
                </div>
              )}

              <div style={{ fontSize: "2.5rem", marginBottom: 12 }}>{plan.icon}</div>
              <h2 style={{ fontSize: "1.4rem", fontWeight: 900, margin: "0 0 4px" }}>{plan.name}</h2>
              <div style={{ display: "flex", alignItems: "baseline", gap: 4, marginBottom: 24 }}>
                <span style={{ fontSize: "2.5rem", fontWeight: 900 }}>${plan.price}</span>
                {plan.price !== "0" && (
                  <span style={{ opacity: 0.7, fontSize: ".9rem" }}>{t.monthly}</span>
                )}
              </div>

              <div style={{ marginBottom: 24 }}>
                {plan.features.map((f) => (
                  <div key={f} style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 8 }}>
                    <span style={{ color: plan.popular ? "#4ADE80" : "#16A34A", fontSize: "1rem" }}>✓</span>
                    <span style={{ fontSize: ".9rem", opacity: 0.9 }}>{f}</span>
                  </div>
                ))}
                {plan.notIncluded?.map((f) => (
                  <div key={f} style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 8, opacity: 0.4 }}>
                    <span style={{ fontSize: "1rem" }}>✗</span>
                    <span style={{ fontSize: ".9rem" }}>{f}</span>
                  </div>
                ))}
              </div>

              <a href={`/${locale}/app-demo`} style={{
                display: "block",
                textAlign: "center",
                padding: "12px 24px",
                borderRadius: 14,
                background: plan.popular ? "white" : "#03045A",
                color: plan.popular ? "#03045A" : "white",
                fontWeight: 800,
                fontSize: ".95rem",
                textDecoration: "none",
              }}>
                {plan.price === "0" ? t.getStarted : t.subscribe}
              </a>
            </div>
          ))}
        </div>
      </section>

      {/* Comparison Table */}
      <section style={{ maxWidth: 900, margin: "0 auto", padding: "0 24px 60px" }}>
        <h2 style={{ textAlign: "center", fontSize: "1.6rem", fontWeight: 900, marginBottom: 32, color: "var(--text)" }}>
          {isAr ? "مقارنة تفصيلية" : "Detailed Comparison"}
        </h2>
        <div style={{ overflowX: "auto" }}>
          <table style={{ width: "100%", borderCollapse: "collapse", fontSize: ".9rem" }}>
            <thead>
              <tr style={{ background: "#03045A", color: "white" }}>
                <th style={{ padding: "14px 16px", textAlign: isAr ? "right" : "left", borderRadius: isAr ? "0 12px 12px 0" : "12px 0 0 12px" }}>
                  {isAr ? "الميزة" : "Feature"}
                </th>
                {["مجاني", "SmartGold ✨", "SmartPlatinum 💎"].map(n => (
                  <th key={n} style={{ padding: "14px 16px", textAlign: "center" }}>{n}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {[
                [isAr ? "الحجز الأساسي" : "Basic Booking", "✓", "✓", "✓"],
                [isAr ? "خصم على الحجوزات" : "Booking Discount", "—", "10%", "15%"],
                [isAr ? "أولوية في البحث" : "Search Priority", "—", "✓", "✓✓"],
                [isAr ? "إلغاء مجاني" : "Free Cancellation", "—", "قبل 24 ساعة", "دائماً"],
                [isAr ? "دعم العملاء" : "Customer Support", isAr ? "عادي" : "Basic", isAr ? "أولوية" : "Priority", "24/7"],
                [isAr ? "عاملة بديلة" : "Replacement Worker", "—", "—", "✓"],
                [isAr ? "هدايا الحجوزات" : "Booking Gifts", "—", "—", "✓"],
                [isAr ? "تقارير شهرية" : "Monthly Reports", "—", "—", "✓"],
              ].map((row, i) => (
                <tr key={i} style={{ background: i % 2 === 0 ? "var(--surface)" : "transparent" }}>
                  {row.map((cell, j) => (
                    <td key={j} style={{
                      padding: "12px 16px",
                      textAlign: j === 0 ? (isAr ? "right" : "left") : "center",
                      color: cell === "✓" || cell === "✓✓" ? "#16A34A" : cell === "—" ? "#94A3B8" : "var(--text)",
                      fontWeight: cell === "✓" || cell === "✓✓" ? 700 : 400,
                      borderBottom: "1px solid var(--border)",
                    }}>{cell}</td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      {/* FAQ */}
      <section style={{ maxWidth: 720, margin: "0 auto", padding: "0 24px 80px" }}>
        <h2 style={{ textAlign: "center", fontSize: "1.6rem", fontWeight: 900, marginBottom: 32, color: "var(--text)" }}>
          {t.faq}
        </h2>
        <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
          {t.faqs.map((faq, i) => (
            <details key={i} style={{
              background: "var(--surface)",
              borderRadius: 14,
              border: "1px solid var(--border)",
              padding: "16px 20px",
            }}>
              <summary style={{
                cursor: "pointer",
                fontWeight: 700,
                fontSize: "1rem",
                color: "var(--text)",
                listStyle: "none",
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
              }}>
                {faq.q}
                <span style={{ color: "#03045A", fontSize: "1.2rem" }}>+</span>
              </summary>
              <p style={{ marginTop: 12, color: "var(--text-2)", lineHeight: 1.7, fontSize: ".9rem" }}>{faq.a}</p>
            </details>
          ))}
        </div>
      </section>

      {/* CTA */}
      <section style={{
        background: "linear-gradient(135deg, #03045A, #0353A4)",
        padding: "60px 24px",
        textAlign: "center",
        color: "white",
      }}>
        <h2 style={{ fontSize: "1.8rem", fontWeight: 900, margin: "0 0 12px" }}>
          {isAr ? "ابدأ التوفير اليوم" : "Start Saving Today"}
        </h2>
        <p style={{ opacity: 0.8, marginBottom: 28 }}>
          {isAr ? "حمّل التطبيق وابدأ رحلتك مع SmartMaid" : "Download the app and start your SmartMaid journey"}
        </p>
        <a href={`/${locale}/app-demo`} style={{
          display: "inline-block",
          background: "white",
          color: "#03045A",
          padding: "14px 36px",
          borderRadius: 16,
          fontWeight: 900,
          fontSize: "1rem",
          textDecoration: "none",
        }}>
          {isAr ? "جرّب مجاناً" : "Try Free"}
        </a>
      </section>
    </main>
  );
}
