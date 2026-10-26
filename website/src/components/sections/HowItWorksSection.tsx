"use client";
import { useLocale } from "next-intl";

export default function HowItWorksSection() {
  const locale = useLocale();
  const ar = locale === "ar";

  const steps = ar
    ? [{ n: "01", i: "🔍", t: "تصفّح واختر", d: "استعرض العاملات والشركات وقارن التقييمات والأسعار" },
       { n: "02", i: "📅", t: "احجز بسهولة", d: "حدّد الخدمة والوقت المناسب واختر طريقة الدفع" },
       { n: "03", i: "🔒", t: "ادفع بأمان", d: "المال محفوظ في Escrow ولا يُحوَّل إلا بعد إتمام الخدمة" },
       { n: "04", i: "✨", t: "استمتع بالنتيجة", d: "عاملة في منزلك وتقييم بعد الانتهاء لضمان الجودة" }]
    : [{ n: "01", i: "🔍", t: "Browse & Choose", d: "Browse maids and companies, compare ratings and prices" },
       { n: "02", i: "📅", t: "Book Easily", d: "Pick the service, time slot, and payment method you prefer" },
       { n: "03", i: "🔒", t: "Pay Securely", d: "Money is held in Escrow and only released after service completion" },
       { n: "04", i: "✨", t: "Enjoy the Result", d: "A maid at your home and a post-service review to guarantee quality" }];

  return (
    <section id="how" className="section" style={{ background: "var(--bg-alt)" }}>
      <div className="divider" style={{ position: "absolute", top: 0, left: 0, right: 0 }} />
      <div className="mx">
        {/* Header */}
        <div style={{ textAlign: "center", marginBottom: "clamp(2.5rem,5vw,4rem)" }}>
          <span className="badge badge-cyan" style={{ marginBottom: "1rem" }}>
            <span className="pulse" style={{ background: "var(--cyan)" }} />
            {ar ? "كيف يعمل" : "How it works"}
          </span>
          <h2 className="t-h1" style={{ color: "var(--text)", marginBottom: ".75rem" }}>
            {ar ? "أربع خطوات بسيطة فقط" : "Just four simple steps"}
          </h2>
          <p className="t-lead" style={{ maxWidth: 480, marginInline: "auto" }}>
            {ar ? "من اختيار العاملة إلى منزل نظيف — كل شيء بلمسة واحدة" : "From choosing a maid to a clean home — everything in one tap"}
          </p>
        </div>

        {/* Steps */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)", gap: "1.5rem" }} className="steps-grid">
          <style>{`
            .steps-grid { grid-template-columns: repeat(4,1fr); }
            @media(max-width:900px) { .steps-grid { grid-template-columns: repeat(2,1fr) !important; } }
            @media(max-width:520px)  { .steps-grid { grid-template-columns: 1fr !important; } }
          `}</style>
          {steps.map((s, i) => (
            <div key={i} style={{ position: "relative" }}>
              {/* Connector line */}
              {i < steps.length - 1 && (
                <div className="hide-mobile" style={{
                  position: "absolute", top: 26, insetInlineStart: "calc(50% + 32px)", width: "calc(100% - 8px)", height: 2,
                  background: `linear-gradient(${ar ? "270deg" : "90deg"}, var(--indigo-m), var(--cyan-m))`, zIndex: 0,
                }} />
              )}
              <div className="card" style={{ padding: "1.75rem 1.5rem", textAlign: "center", position: "relative", zIndex: 1 }}>
                {/* Step icon */}
                <div style={{
                  width: 52, height: 52, borderRadius: 16, margin: "0 auto 1rem",
                  background: `linear-gradient(135deg, var(--indigo), var(--cyan))`,
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontSize: 22, boxShadow: "var(--shadow-brand)",
                }}>{s.i}</div>
                {/* Number */}
                <div style={{ fontSize: "2.2rem", fontWeight: 900, lineHeight: 1, marginBottom: ".5rem", background: "linear-gradient(135deg,var(--indigo-m),var(--cyan-m))", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", backgroundClip: "text", opacity: .6 }}>{s.n}</div>
                <h3 style={{ fontSize: "1rem", fontWeight: 800, color: "var(--text)", marginBottom: ".5rem" }}>{s.t}</h3>
                <p style={{ fontSize: ".83rem", color: "var(--text-2)", lineHeight: 1.65 }}>{s.d}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
