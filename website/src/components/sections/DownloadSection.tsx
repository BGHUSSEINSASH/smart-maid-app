"use client";
import { useLocale } from "next-intl";

export default function DownloadSection() {
  const locale = useLocale();
  const ar = locale === "ar";

  return (
    <section id="download" className="section" style={{ background: "var(--bg-alt)" }}>
      <div className="divider" style={{ position: "absolute", top: 0, left: 0, right: 0 }} />
      <div className="mx">
        <div style={{
          borderRadius: 28, overflow: "hidden", position: "relative",
          background: "linear-gradient(135deg, #1C1640 0%, #0B1A2E 50%, #1C1640 100%)",
          padding: "clamp(3rem,8vw,5.5rem) clamp(2rem,6vw,5rem)",
          textAlign: "center",
        }}>
          <div className="dot-grid" style={{ position: "absolute", inset: 0, opacity: .5 }} />
          <div className="blob" style={{ width: 500, height: 500, background: "rgba(79,70,229,.25)", top: "50%", left: "50%", transform: "translate(-50%,-50%)" }} />
          <div className="blob" style={{ width: 300, height: 300, background: "rgba(6,182,212,.12)", insetInlineEnd: "5%", top: "10%" }} />

          <div style={{ position: "relative", zIndex: 2 }}>
            <span className="badge badge-dark" style={{ marginBottom: "1.5rem" }}>
              <span className="pulse" style={{ background: "#c7d2fe" }} />
              {ar ? "حمّل التطبيق" : "Get the App"}
            </span>
            <h2 className="t-h1" style={{ color: "#fff", marginBottom: "1rem" }}>
              {ar ? "حمّل التطبيق الآن" : "Download the App Now"}
            </h2>
            <p style={{ color: "rgba(255,255,255,.58)", fontSize: "1.05rem", marginBottom: "2.5rem", maxWidth: 480, marginInline: "auto" }}>
              {ar
                ? "ابدأ رحلتك نحو منزل أنظف اليوم. متاح على iOS وAndroid مجاناً."
                : "Start your journey to a cleaner home today. Available free on iOS and Android."}
            </p>

            {/* Store buttons */}
            <div style={{ display: "flex", justifyContent: "center", gap: 14, flexWrap: "wrap", marginBottom: "2.5rem" }}>
              <a href="https://github.com/BGHUSSEINSASH/smartmaid-app/releases/download/v1.0.0/SmartMaid-v1.0.0-arm64.apk" style={{ display: "flex", alignItems: "center", gap: 10, background: "#fff", color: "#0B0918", padding: ".9rem 2rem", borderRadius: 14, fontWeight: 800, textDecoration: "none", fontSize: ".95rem", boxShadow: "0 8px 32px rgba(0,0,0,.25)", transition: "transform .2s" }}
                onMouseEnter={e => (e.currentTarget as HTMLAnchorElement).style.transform = "translateY(-3px)"}
                onMouseLeave={e => (e.currentTarget as HTMLAnchorElement).style.transform = "translateY(0)"}>
                <svg width="20" height="20" fill="#3DDC84" viewBox="0 0 24 24">
                  <path d="M3.18 23.76A1 1 0 012 22.84V1.16A1 1 0 013.18.24l11.67 11.76-11.67 11.76z" />
                </svg>
                {ar ? "تحميل — Android APK" : "Download Android APK"}
              </a>
              <a href="https://github.com/BGHUSSEINSASH/smartmaid-app/releases/tag/v1.0.0" style={{ display: "flex", alignItems: "center", gap: 10, background: "rgba(255,255,255,.1)", border: "1.5px solid rgba(255,255,255,.2)", backdropFilter: "blur(12px)", color: "#fff", padding: ".9rem 2rem", borderRadius: 14, fontWeight: 800, textDecoration: "none", fontSize: ".95rem", transition: "all .2s" }}
                onMouseEnter={e => { (e.currentTarget as HTMLAnchorElement).style.background = "rgba(255,255,255,.18)"; (e.currentTarget as HTMLAnchorElement).style.transform = "translateY(-3px)"; }}
                onMouseLeave={e => { (e.currentTarget as HTMLAnchorElement).style.background = "rgba(255,255,255,.1)"; (e.currentTarget as HTMLAnchorElement).style.transform = "translateY(0)"; }}>
                <svg width="20" height="20" fill="#fff" viewBox="0 0 24 24">
                  <path d="M12 0C5.374 0 0 5.373 0 12c0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z"/>
                </svg>
                {ar ? "GitHub Releases" : "GitHub Releases"}
              </a>
            </div>

            {/* QR Code + Stats row */}
            <div style={{ display: "flex", justifyContent: "center", alignItems: "center", gap: "3rem", flexWrap: "wrap" }}>
              {/* QR */}
              <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 8 }}>
                <div style={{ width: 88, height: 88, borderRadius: 14, background: "#fff", padding: 7, boxShadow: "0 8px 24px rgba(0,0,0,.3)", display: "grid", gridTemplateColumns: "repeat(7,1fr)", gap: 1 }}>
                  {[...Array(49)].map((_, i) => <div key={i} style={{ borderRadius: 1, background: [0,1,2,3,4,5,6,7,13,14,20,21,28,35,41,42,43,44,45,46,9,10,11,15,19,23,25,29,33,37,38,39,47].includes(i) ? "#1a1040" : "transparent" }} />)}
                </div>
                <span style={{ fontSize: ".72rem", color: "rgba(255,255,255,.4)" }}>{ar ? "امسح للتحميل" : "Scan to download"}</span>
              </div>

              {/* Divider */}
              <div style={{ width: 1, height: 60, background: "rgba(255,255,255,.12)" }} className="hide-mobile" />

              {/* Stats */}
              <div style={{ display: "flex", gap: "2rem" }}>
                {(ar ? [["4.9","نجوم"],["1,200+","حجز"],["150+","عاملة"]] : [["4.9","Stars"],["1,200+","Bookings"],["150+","Maids"]]).map(([v, l]) => (
                  <div key={l} style={{ textAlign: "center" }}>
                    <div style={{ fontSize: "1.6rem", fontWeight: 900, color: "#fff" }}>{v}</div>
                    <div style={{ fontSize: ".72rem", color: "rgba(255,255,255,.4)", marginTop: 2 }}>{l}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
