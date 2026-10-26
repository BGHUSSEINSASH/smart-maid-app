"use client";
import { useLocale } from "next-intl";

export default function VoiceSearchSection() {
  const locale = useLocale();
  const ar = locale === "ar";

  const steps = ar
    ? [
        { icon: "🎤", title: "اضغط على الميكروفون", desc: "في أي شاشة — الرئيسية، البحث، أو المساعد" },
        { icon: "🗣️", title: "تحدّث بشكل طبيعي", desc: '"أحتاج طباخة غداً الصباح لأربعة أشخاص"' },
        { icon: "🔍", title: "النظام يحلل الطلب", desc: "يبحث في التصنيفات والمهارات المتاحة" },
        { icon: "✅", title: "نتائج مرتبة بالصلة", desc: "العاملات المناسبة مع التقييم والسعر" },
      ]
    : [
        { icon: "🎤", title: "Tap the microphone", desc: "On any screen — home, search, or assistant" },
        { icon: "🗣️", title: "Speak naturally", desc: '"I need a cook tomorrow morning for four people"' },
        { icon: "🔍", title: "System analyzes your request", desc: "Searches across categories and available skills" },
        { icon: "✅", title: "Results ranked by relevance", desc: "Matched maids with rating and pricing shown" },
      ];

  const features = ar
    ? [
        "🎙️ تحويل الصوت لنص فوري",
        "🌍 يدعم اللهجة العربية",
        "⚡ نتائج سريعة",
        "🔄 اقتراح بديل عند عدم التطابق",
        "📱 يعمل على iOS وAndroid وWindows",
        "🔗 مزامنة مع قاعدة بيانات العاملات",
      ]
    : [
        "🎙️ Real-time voice-to-text",
        "🌍 Supports Arabic dialects",
        "⚡ Fast results",
        "🔄 Fallback suggestions when no match",
        "📱 Works on iOS, Android & Windows",
        "🔗 Synced with maid database",
      ];

  return (
    <section id="voice-search" className="section" style={{ background: "var(--bg-alt)", position: "relative", overflow: "hidden" }}>
      <div className="divider" style={{ position: "absolute", top: 0, left: 0, right: 0 }} />
      {/* Decorative blobs */}
      <div style={{ position: "absolute", width: 400, height: 400, borderRadius: "50%", background: "rgba(3,4,90,.06)", filter: "blur(80px)", top: "50%", left: "50%", transform: "translate(-50%,-50%)", pointerEvents: "none" }} />

      <div className="mx" style={{ position: "relative", zIndex: 2 }}>
        {/* Header */}
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "3rem", alignItems: "center", marginBottom: "clamp(2.5rem,5vw,4rem)" }} className="voice-header">
          <style>{`.voice-header{@media(max-width:900px){grid-template-columns:1fr!important}}`}</style>
          <div>
            <span className="badge badge-brand" style={{ marginBottom: "1rem" }}>
              <span className="pulse" />
              {ar ? "🎤 البحث الصوتي" : "🎤 Voice Search"}
            </span>
            <h2 className="t-h1" style={{ color: "var(--text)", marginBottom: ".75rem" }}>
              {ar ? <>ابحثي بصوتك<br /><span className="gt-brand">بكل سهولة</span></> : <>Search with your voice<br /><span className="gt-brand">naturally and fast</span></>}
            </h2>
            <p className="t-lead">
              {ar
                ? "لا تحتاج كتابة — فقط تحدّث. النظام يفهم طلبك ويعرض العاملات المناسبة بسرعة."
                : "No typing needed — just speak. The system understands your request and shows matching maids quickly."}
            </p>
            <div style={{ display: "flex", flexWrap: "wrap", gap: ".6rem", marginTop: "1.5rem" }}>
              {features.map((f) => (
                <span key={f} style={{ padding: ".35rem .9rem", borderRadius: 99, background: "var(--indigo-l)", border: "1px solid var(--indigo-m)", color: "var(--indigo)", fontSize: ".78rem", fontWeight: 700 }}>{f}</span>
              ))}
            </div>
          </div>

          {/* Phone mockup with voice UI */}
          <div style={{ display: "flex", justifyContent: "center" }}>
            <div style={{ width: 280, background: "var(--bg-2)", borderRadius: 24, padding: 20, border: "1px solid var(--border)", boxShadow: "var(--shadow-xl)" }}>
              {/* Search bar mockup */}
              <div style={{ background: "var(--surface)", borderRadius: 14, padding: "12px 14px", border: "1.5px solid var(--indigo)", boxShadow: "0 0 0 3px rgba(3,4,90,.08)", marginBottom: 16 }}>
                <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                  <span style={{ fontSize: 16 }}>🔍</span>
                  <span style={{ flex: 1, fontSize: 13, color: "var(--text)", fontWeight: 600 }}>أحتاج طباخة غداً...</span>
                  <div style={{ width: 30, height: 30, borderRadius: 9, background: "linear-gradient(135deg,var(--brand),#0353A4)", display: "flex", alignItems: "center", justifyContent: "center" }}>
                    <span style={{ fontSize: 14 }}>🎤</span>
                  </div>
                </div>
              </div>
              {/* Voice indicator */}
              <div style={{ background: "rgba(3,4,90,.06)", borderRadius: 12, padding: "10px 14px", marginBottom: 14, display: "flex", alignItems: "center", gap: 8 }}>
                <div style={{ display: "flex", alignItems: "flex-end", gap: 2 }}>
                  {[12, 20, 14, 24, 10, 18, 8].map((h, i) => (
                    <div key={i} style={{ width: 3, height: h, background: "var(--brand)", borderRadius: 2 }} />
                  ))}
                </div>
                <span style={{ fontSize: 12, color: "var(--brand)", fontWeight: 700 }}>{ar ? "جارٍ الاستماع..." : "Listening..."}</span>
              </div>
              {/* Results */}
              {[
                { name: ar ? "ماريا سانتوس" : "Maria Santos", match: 98, label: ar ? "طبخ خليجي" : "Gulf Cuisine" },
                { name: ar ? "فاطمة علي" : "Fatima Ali", match: 87, label: ar ? "طبخ عربي" : "Arabic Cooking" },
              ].map((r) => (
                <div key={r.name} style={{ display: "flex", alignItems: "center", gap: 10, padding: "8px 10px", borderRadius: 12, background: "var(--surface)", border: "1px solid var(--border)", marginBottom: 8 }}>
                  <div style={{ width: 36, height: 36, borderRadius: 10, background: "linear-gradient(135deg,var(--brand),#0353A4)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 16, color: "#fff", fontWeight: 900 }}>
                    {r.name.charAt(0)}
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 13, fontWeight: 800, color: "var(--text)" }}>{r.name}</div>
                    <div style={{ fontSize: 10, color: "var(--text-3)" }}>🤖 {r.label} • {r.match}%</div>
                  </div>
                  <div style={{ fontSize: 11, color: "var(--brand)", fontWeight: 700, background: "var(--indigo-l)", padding: "2px 8px", borderRadius: 99 }}>{r.match}%</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Steps */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)", gap: "1.25rem" }} className="voice-steps">
          <style>{`.voice-steps{@media(max-width:900px){grid-template-columns:repeat(2,1fr)!important}@media(max-width:520px){grid-template-columns:1fr!important}}`}</style>
          {steps.map((s, i) => (
            <div key={i} className="card" style={{ padding: "1.5rem", textAlign: "center" }}>
              <div style={{ fontSize: "2rem", marginBottom: "1rem" }}>{s.icon}</div>
              <div style={{ fontWeight: 900, fontSize: ".95rem", color: "var(--text)", marginBottom: ".4rem" }}>{s.title}</div>
              <div style={{ fontSize: ".82rem", color: "var(--text-2)", lineHeight: 1.6, fontStyle: s.icon === "🗣️" ? "italic" : "normal" }}>{s.desc}</div>
            </div>
          ))}
        </div>

        {/* CTA */}
        <div style={{ textAlign: "center", marginTop: "2.5rem" }}>
          <a href={`/${locale}/app-demo`} className="btn btn-primary" style={{ padding: ".9rem 2.5rem", fontSize: "1rem" }}>
            {ar ? "🎤 جرّب البحث الصوتي الآن" : "🎤 Try Voice Search Now"}
          </a>
        </div>
      </div>
    </section>
  );
}
