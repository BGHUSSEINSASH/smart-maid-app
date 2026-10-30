"use client";
import { useLocale } from "next-intl";
import { useTheme } from "../../lib/theme";

export default function Footer() {
  const locale = useLocale();
  const { theme } = useTheme();
  const ar = locale === "ar";

  const cols = ar
    ? [
        { t: "المنتج", ls: [["المميزات","#features"],["كيف يعمل","#how"],["تحميل","#download"]] },
        { t: "الشركة", ls: [["اتصل بنا","mailto:support@shaghalti.app"]] },
        { t: "قانوني", ls: [["الشروط والأحكام","terms"],["سياسة الخصوصية","privacy"]] },
      ]
    : [
        { t: "Product", ls: [["Features","#features"],["How it works","#how"],["Download","#download"]] },
        { t: "Company", ls: [["Contact","mailto:support@shaghalti.app"]] },
        { t: "Legal", ls: [["Terms & Conditions","terms"],["Privacy Policy","privacy"]] },
      ];

  return (
    <footer style={{ background: "var(--bg)", borderTop: "1px solid var(--border)", paddingTop: "4rem", paddingBottom: "2rem" }}>
      <div className="mx">
        <div style={{ display: "grid", gridTemplateColumns: "2fr 1fr 1fr 1fr", gap: "3rem", marginBottom: "3rem" }} className="footer-g">
          <style>{`.footer-g { @media(max-width:800px){ grid-template-columns:1fr 1fr!important } @media(max-width:500px){ grid-template-columns:1fr!important } }`}</style>

          {/* Brand */}
          <div>
            <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: "1rem" }}>
              <img src="/logo.png" width={40} height={40} alt="شغّالتي"
                style={{ borderRadius: 11, boxShadow: "0 2px 12px rgba(3,5,90,.18)" }} />
              <span style={{ fontWeight: 900, fontSize: "1.05rem" }}>
                {ar ? "شغّالتي" : "Shaghalti"}
              </span>
            </div>
            <p style={{ fontSize: ".875rem", color: "var(--text-2)", maxWidth: 240, lineHeight: 1.75 }}>
              {ar ? "خدمات منزلية احترافية بلمسة واحدة." : "Professional home services in one tap."}
            </p>
            {/* Social */}
            <div style={{ display: "flex", gap: 8, marginTop: "1.25rem" }}>
              {["𝕏", "in", "f", "📷"].map(s => (
                <a key={s} href="#" style={{ width: 34, height: 34, borderRadius: 9, border: "1.5px solid var(--border)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 13, color: "var(--text-3)", textDecoration: "none", transition: "all .2s" }}
                  onMouseEnter={e => { (e.currentTarget as HTMLAnchorElement).style.borderColor = "var(--indigo)"; (e.currentTarget as HTMLAnchorElement).style.color = "var(--indigo)"; }}
                  onMouseLeave={e => { (e.currentTarget as HTMLAnchorElement).style.borderColor = "var(--border)"; (e.currentTarget as HTMLAnchorElement).style.color = "var(--text-3)"; }}>
                  {s}
                </a>
              ))}
            </div>
          </div>

          {cols.map(col => (
            <div key={col.t}>
              <h4 style={{ fontWeight: 800, fontSize: ".875rem", color: "var(--text)", marginBottom: "1rem" }}>{col.t}</h4>
              <div style={{ display: "flex", flexDirection: "column", gap: ".55rem" }}>
                {col.ls.map(([label, href]) => (
                  <a key={label} href={href} style={{ fontSize: ".85rem", color: "var(--text-3)", textDecoration: "none", transition: "color .15s" }}
                    onMouseEnter={e => (e.currentTarget as HTMLAnchorElement).style.color = "var(--indigo)"}
                    onMouseLeave={e => (e.currentTarget as HTMLAnchorElement).style.color = "var(--text-3)"}>
                    {label}
                  </a>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Bottom bar */}
        <div className="divider" style={{ marginBottom: "1.5rem" }} />
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", flexWrap: "wrap", gap: 12, fontSize: ".8rem", color: "var(--text-3)" }}>
          <span>© {new Date().getFullYear()} شغّالتي — {ar ? "جميع الحقوق محفوظة" : "All rights reserved"}</span>
          <div style={{ display: "flex", gap: "1.25rem" }}>
            <a href="terms" style={{ color: "var(--text-3)", textDecoration: "none" }}>{ar ? "الشروط" : "Terms"}</a>
            <a href="privacy" style={{ color: "var(--text-3)", textDecoration: "none" }}>{ar ? "الخصوصية" : "Privacy"}</a>
            <a href="mailto:support@shaghalti.app" style={{ color: "var(--text-3)", textDecoration: "none" }}>{ar ? "الدعم" : "Support"}</a>
          </div>
        </div>
      </div>
    </footer>
  );
}
