"use client";
import { useLocale } from "next-intl";

function PhoneMockup({ delay = 0 }: { delay?: number }) {
  return (
    <div className="phone float" style={{ animationDelay: `${delay}s` }}>
      <div className="phone-notch" />
      <div className="phone-screen">
        {/* Status bar */}
        <div style={{ padding: "20px 14px 8px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <span style={{ fontSize: 9, color: "rgba(255,255,255,.5)" }}>9:41</span>
          <div style={{ display: "flex", gap: 4 }}>
            {[12,8,14].map((h,i) => <div key={i} style={{ width: 3, height: h, background: "rgba(255,255,255,.5)", borderRadius: 2 }} />)}
          </div>
        </div>
        {/* Header */}
        <div style={{ padding: "4px 14px 12px", display: "flex", alignItems: "center", gap: 8 }}>
          <div style={{ width: 30, height: 30, borderRadius: 10, background: "linear-gradient(135deg,#4F46E5,#06B6D4)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 13 }}>🏠</div>
          <div>
            <div style={{ fontSize: 8, color: "rgba(255,255,255,.4)" }}>مرحباً 👋</div>
            <div style={{ fontSize: 11, fontWeight: 800, color: "#fff" }}>أحمد محمد</div>
          </div>
          <div style={{ marginInlineStart: "auto", display: "flex", gap: 6 }}>
            <div style={{ width: 26, height: 26, borderRadius: 8, background: "rgba(255,255,255,.08)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 11 }}>🔔</div>
            <div style={{ width: 26, height: 26, borderRadius: 8, background: "rgba(255,255,255,.08)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 11 }}>🔍</div>
          </div>
        </div>
        {/* Search */}
        <div style={{ margin: "0 14px 12px", padding: "8px 10px", borderRadius: 10, background: "rgba(255,255,255,.07)", border: "1px solid rgba(255,255,255,.08)", display: "flex", alignItems: "center", gap: 6, fontSize: 9, color: "rgba(255,255,255,.4)" }}>
          🔍 ابحث عن خدمة...
        </div>
        {/* Categories */}
        <div style={{ padding: "0 14px 12px", display: "flex", gap: 8, overflowX: "hidden" }}>
          {[["🧹","تنظيف","#4F46E5"],["🍳","طبخ","#06B6D4"],["👶","أطفال","#8B5CF6"],["👴","كبار","#10B981"]].map(([e,l,c]) => (
            <div key={l} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4, flexShrink: 0 }}>
              <div style={{ width: 34, height: 34, borderRadius: 10, background: `${c}22`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 15, border: `1px solid ${c}33` }}>{e}</div>
              <span style={{ fontSize: 7, color: "rgba(255,255,255,.55)", fontWeight: 600 }}>{l}</span>
            </div>
          ))}
        </div>
        {/* Banner */}
        <div style={{ margin: "0 14px 12px", padding: "12px", borderRadius: 14, background: "linear-gradient(135deg,#4F46E5,#06B6D4)", position: "relative", overflow: "hidden" }}>
          <div style={{ position: "absolute", insetInlineEnd: 8, top: 6, fontSize: 22, opacity: .25 }}>✨</div>
          <div style={{ fontSize: 8, color: "rgba(255,255,255,.75)", marginBottom: 2 }}>عرض الأسبوع</div>
          <div style={{ fontSize: 12, fontWeight: 900, color: "#fff", marginBottom: 2 }}>احجزي الآن وتوفّري</div>
          <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
            <span style={{ fontSize: 8, fontWeight: 700, color: "#fff", background: "rgba(255,255,255,.2)", padding: "2px 6px", borderRadius: 6 }}>خصم 50%</span>
          </div>
        </div>
        {/* Workers */}
        <div style={{ padding: "0 14px" }}>
          <div style={{ fontSize: 9, fontWeight: 800, color: "rgba(255,255,255,.85)", marginBottom: 8 }}>⭐ الأعلى تقييماً</div>
          {[{ n: "ماريا سانتوس", s: "تنظيف عام", r: "4.9", p: "$30/س" },
            { n: "فاطمة علي", s: "طبخ وتنظيف", r: "4.8", p: "$25/س" }].map((w, i) => (
            <div key={i} style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 8, padding: "7px 8px", borderRadius: 10, background: "rgba(255,255,255,.05)", border: "1px solid rgba(255,255,255,.07)" }}>
              <div style={{ width: 26, height: 26, borderRadius: 8, background: i === 0 ? "#4F46E5" : "#06B6D4", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12 }}>👩</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 9, fontWeight: 700, color: "#fff" }}>{w.n}</div>
                <div style={{ fontSize: 7, color: "rgba(255,255,255,.4)" }}>{w.s}</div>
              </div>
              <div style={{ textAlign: "end" }}>
                <div style={{ fontSize: 8, color: "#fbbf24", fontWeight: 700 }}>⭐ {w.r}</div>
                <div style={{ fontSize: 7, color: "rgba(255,255,255,.5)" }}>{w.p}</div>
              </div>
            </div>
          ))}
        </div>
        {/* Bottom nav */}
        <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, display: "flex", justifyContent: "space-around", padding: "10px 0 14px", borderTop: "1px solid rgba(255,255,255,.06)", background: "rgba(12,9,26,.9)", backdropFilter: "blur(10px)" }}>
          {[["🏠",true],["🔍",false],["📋",false],["💬",false],["👤",false]].map(([ic, active], k) => (
            <div key={k} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 2 }}>
              <div style={{ fontSize: active ? 17 : 13, filter: active ? "drop-shadow(0 0 6px #4F46E5)" : "none", opacity: active ? 1 : .35 }}>{ic as string}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default function HeroSection() {
  const locale = useLocale();
  const ar = locale === "ar";

  return (
    <section style={{
      background: "linear-gradient(165deg, #0B0918 0%, #1C1640 45%, #0D1426 100%)",
      minHeight: "100dvh", display: "flex", alignItems: "center",
      paddingTop: 100, paddingBottom: 80, position: "relative", overflow: "hidden",
    }}>
      {/* Background decorations */}
      <div className="dot-grid" style={{ position: "absolute", inset: 0, opacity: .4 }} />
      {/* Glows */}
      <div className="blob" style={{ width: 500, height: 500, background: "rgba(79,70,229,.22)", top: "10%", insetInlineStart: "5%" }} />
      <div className="blob" style={{ width: 400, height: 400, background: "rgba(6,182,212,.16)", bottom: "5%", insetInlineEnd: "10%" }} />
      {/* Decorative ring */}
      <div style={{ position: "absolute", top: "50%", left: "50%", transform: "translate(-50%,-50%)", width: 800, height: 800, borderRadius: "50%", border: "1px solid rgba(79,70,229,.08)", pointerEvents: "none" }} />
      <div style={{ position: "absolute", top: "50%", left: "50%", transform: "translate(-50%,-50%)", width: 550, height: 550, borderRadius: "50%", border: "1px solid rgba(6,182,212,.07)", pointerEvents: "none" }} />

      <div className="mx" style={{ position: "relative", zIndex: 2, width: "100%" }}>
        <div style={{
          display: "grid",
          gridTemplateColumns: "1fr 1fr",
          alignItems: "center",
          gap: "clamp(2rem, 5vw, 5rem)",
        }} className="hero-cols">
          <style>{`
            .hero-cols { grid-template-columns: 1fr 1fr; }
            .phones-wrap { justify-content: center; }
            @media (max-width:900px) {
              .hero-cols { grid-template-columns: 1fr !important; text-align: center !important; }
              .hero-text-cta { justify-content: center !important; }
              .hero-stats { justify-content: center !important; }
              .phones-wrap { margin-top: 2.5rem; }
            }
          `}</style>

          {/* ── Text column ── */}
          <div style={{ display: "flex", flexDirection: "column", gap: "1.75rem", order: ar ? 2 : 1 }}>

            {/* Headline */}
            <div className="anim-up2">
              <h1 className="t-hero" style={{ color: "#fff" }}>
                {ar ? <>منزلك يستحق<br /><span className="gt-white">لمسة احترافية</span></> : <>Your home deserves<br /><span className="gt-white">a professional touch</span></>}
              </h1>
            </div>

            {/* Sub */}
            <p className="t-lead anim-up3" style={{ color: "rgba(255,255,255,.62)", maxWidth: 460 }}>
              {ar
                ? "احجز عاملات وشركات نظافة موثّقة خلال دقيقة واحدة. دفع آمن، تتبّع لحظي، وتقييمات حقيقية."
                : "Book verified maids and cleaning companies in under a minute. Secure payments, live tracking, and real reviews."}
            </p>

            {/* CTAs */}
            <div className="anim-up4 hero-text-cta" style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
              <a href="#download" className="btn btn-primary" style={{ padding: ".9rem 2rem", fontSize: ".95rem" }}>
                <svg width="18" height="18" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                {ar ? "App Store" : "App Store"}
              </a>
              <a href="#download" className="btn btn-dark" style={{ padding: ".9rem 2rem", fontSize: ".95rem" }}>
                <svg width="17" height="17" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M3.18 23.76A1 1 0 012 22.84V1.16A1 1 0 013.18.24l11.67 11.76-11.67 11.76z" />
                </svg>
                {ar ? "Google Play" : "Google Play"}
              </a>
              <a href={`/${locale}/app-demo`}
                style={{ display: "inline-flex", alignItems: "center", gap: 8, padding: ".9rem 2rem", borderRadius: 14, fontWeight: 800, fontSize: ".95rem", cursor: "pointer", textDecoration: "none", background: "linear-gradient(135deg, rgba(6,182,212,.2), rgba(79,70,229,.2))", border: "1.5px solid rgba(6,182,212,.4)", color: "#67e8f9", backdropFilter: "blur(12px)", transition: "all .2s" }}
                onMouseEnter={e => { const el = e.currentTarget as HTMLAnchorElement; el.style.background = "linear-gradient(135deg,rgba(6,182,212,.35),rgba(79,70,229,.35))"; el.style.transform = "translateY(-2px)"; }}
                onMouseLeave={e => { const el = e.currentTarget as HTMLAnchorElement; el.style.background = "linear-gradient(135deg,rgba(6,182,212,.2),rgba(79,70,229,.2))"; el.style.transform = "translateY(0)"; }}>
                <span style={{ fontSize: 16 }}>▶</span>
                {ar ? "جرّب أون لاين" : "Try Online"}
              </a>
            </div>

            {/* Stats */}
            <div className="hero-stats anim-up4" style={{ display: "flex", gap: "2.5rem", paddingTop: 8 }}>
              {(ar
                ? [["4.9 ⭐","تقييم العملاء"],["1,200+","حجز مكتمل"],["150+","عاملة موثّقة"],["98%","نسبة الرضا"]]
                : [["4.9 ⭐","User Rating"],["1,200+","Completed Bookings"],["150+","Verified Maids"],["98%","Satisfaction"]]
              ).map(([v, l]) => (
                <div key={l}>
                  <div style={{ fontSize: "1.4rem", fontWeight: 900, color: "#fff" }}>{v}</div>
                  <div style={{ fontSize: ".75rem", color: "rgba(255,255,255,.45)", marginTop: 2 }}>{l}</div>
                </div>
              ))}
            </div>
          </div>

          {/* ── Phones column ── */}
          <div className="phones-wrap anim-fade" style={{ display: "flex", alignItems: "center", gap: 20, position: "relative", order: ar ? 1 : 2 }}>
            {/* Glow */}
            <div style={{ position: "absolute", width: 280, height: 280, borderRadius: "50%", background: "rgba(79,70,229,.3)", filter: "blur(60px)", zIndex: 0, top: "50%", left: "50%", transform: "translate(-50%,-50%)" }} />

            {/* Phone 1 (back) */}
            <div className="hide-mobile" style={{ transform: "rotate(-8deg) translateY(20px) scale(.88)", zIndex: 1, opacity: .7, position: "relative" }}>
              <PhoneMockup delay={0.8} />
            </div>

            {/* Phone 2 (front, main) */}
            <div style={{ position: "relative", zIndex: 3 }}>
              <PhoneMockup delay={0} />
              {/* Floating card: confirmed */}
              <div className="glass floatR" style={{ position: "absolute", top: "12%", insetInlineStart: "-75px", padding: "10px 14px", borderRadius: 14, minWidth: 150, zIndex: 10 }}>
                <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                  <div style={{ width: 30, height: 30, borderRadius: 8, background: "rgba(16,185,129,.2)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 14 }}>✅</div>
                  <div>
                    <div style={{ fontSize: 10, fontWeight: 800, color: "#fff" }}>{ar ? "تم التأكيد!" : "Confirmed!"}</div>
                    <div style={{ fontSize: 8, color: "rgba(255,255,255,.5)" }}>Maria Santos</div>
                  </div>
                </div>
              </div>
              {/* Floating card: rating */}
              <div className="glass float" style={{ position: "absolute", bottom: "18%", insetInlineEnd: "-70px", padding: "10px 14px", borderRadius: 14, zIndex: 10 }}>
                <div style={{ display: "flex", gap: 2, marginBottom: 2 }}>
                  {"★★★★★".split("").map((s, i) => <span key={i} style={{ color: "#fbbf24", fontSize: 11 }}>{s}</span>)}
                </div>
                <div style={{ fontSize: 9, color: "rgba(255,255,255,.5)" }}>{ar ? "خدمة ممتازة!" : "Excellent service!"}</div>
              </div>
            </div>

            {/* Phone 3 (back right) */}
            <div className="hide-mobile" style={{ transform: "rotate(8deg) translateY(20px) scale(.88)", zIndex: 1, opacity: .7, position: "relative" }}>
              <PhoneMockup delay={1.2} />
            </div>
          </div>
        </div>

        {/* Scroll hint */}
        <div style={{ position: "absolute", bottom: -50, left: "50%", transform: "translateX(-50%)", display: "flex", flexDirection: "column", alignItems: "center", gap: 8 }}>
          <span style={{ fontSize: ".72rem", color: "rgba(255,255,255,.3)", letterSpacing: ".08em" }}>
            {ar ? "مرّر للأسفل" : "Scroll down"}
          </span>
          <div style={{ width: 20, height: 32, borderRadius: 99, border: "1.5px solid rgba(255,255,255,.2)", display: "flex", justifyContent: "center", paddingTop: 5 }}>
            <div style={{ width: 3, height: 6, borderRadius: 99, background: "rgba(255,255,255,.4)", animation: "float 1.5s ease-in-out infinite" }} />
          </div>
        </div>
      </div>
    </section>
  );
}
