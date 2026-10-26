"use client";
import { useParams } from "next/navigation";

const features = [
  {
    icon: "🔧",
    title: "أعلام التحكم",
    titleEn: "Control Flags",
    desc: "تحكّم في كل ميزة بمفتاح واحد — حجوزات، دفع، عروض، وأكثر",
    descEn: "Toggle any feature with one switch — bookings, payment, offers & more",
    color: "#0353A4",
  },
  {
    icon: "🚧",
    title: "وضع الصيانة",
    titleEn: "Maintenance Mode",
    desc: "فعّل الصيانة بضغطة واحدة — المستخدمون يرون شاشة مخصصة",
    descEn: "Enable maintenance with one tap — users see a custom screen",
    color: "#DC2626",
  },
  {
    icon: "💳",
    title: "إدارة الاشتراكات",
    titleEn: "Subscription Management",
    desc: "منح وتمديد وإلغاء الاشتراكات لأي مستخدم مع سجل كامل",
    descEn: "Grant, extend & revoke subscriptions for any user with full audit trail",
    color: "#D97706",
  },
  {
    icon: "🛡️",
    title: "تعليق الحسابات",
    titleEn: "Account Suspension",
    desc: "علّق حساب أي مستخدم — يرى بانر تحذيري ولا يمكنه الحجز أو الدفع",
    descEn: "Suspend any account — they see a warning banner and can't book or pay",
    color: "#7C3AED",
  },
  {
    icon: "✅",
    title: "مراجعة KYC",
    titleEn: "KYC Review",
    desc: "لا تظهر أي شركة أو عاملة للعملاء إلا بعد موافقة الإدارة على المستندات",
    descEn: "No company or worker appears to customers without admin document approval",
    color: "#16A34A",
  },
  {
    icon: "🎯",
    title: "تطبيق فوري",
    titleEn: "Instant Control",
    desc: "كل تغيير يُطبَّق فوراً على كل المستخدمين",
    descEn: "Every change applies instantly to all users",
    color: "#0E7490",
  },
];

export default function AdminControlSection() {
  const { locale } = useParams<{ locale: string }>();
  const isAr = locale === "ar";

  return (
    <section dir={isAr ? "rtl" : "ltr"} style={{
      padding: "80px 24px",
      background: "linear-gradient(180deg, var(--bg) 0%, #EEF2FF 100%)",
    }}>
      <div style={{ maxWidth: 1100, margin: "0 auto" }}>
        {/* Header */}
        <div style={{ textAlign: "center", marginBottom: 56 }}>
          <div style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 8,
            background: "linear-gradient(135deg,#03045A,#0353A4)",
            color: "white",
            padding: "6px 18px",
            borderRadius: 30,
            fontSize: ".8rem",
            fontWeight: 700,
            marginBottom: 16,
          }}>
            🛡️ {isAr ? "نظام التحكم الإداري" : "Admin Control System"}
          </div>
          <h2 style={{
            fontSize: "clamp(1.8rem,4vw,2.6rem)",
            fontWeight: 900,
            color: "var(--text)",
            margin: "0 0 16px",
          }}>
            {isAr ? "تحكّم كامل بكل شيء" : "Complete Control Over Everything"}
          </h2>
          <p style={{ color: "var(--text-2)", fontSize: "1.05rem", maxWidth: 580, margin: "0 auto" }}>
            {isAr
              ? "أدوات إدارية احترافية تمنحك السيطرة الكاملة على المنصة — من مفتاح واحد يغيّر كل شيء"
              : "Professional admin tools giving you complete platform control — one switch changes everything"}
          </p>
        </div>

        {/* Features Grid */}
        <div style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))",
          gap: 20,
          marginBottom: 48,
        }}>
          {features.map((f) => (
            <div key={f.title} style={{
              background: "white",
              borderRadius: 20,
              padding: 28,
              border: "1px solid var(--border)",
              display: "flex",
              gap: 18,
              boxShadow: "0 2px 16px rgba(0,0,0,.05)",
              transition: "transform .2s, box-shadow .2s",
            }}
            onMouseEnter={e => {
              (e.currentTarget as HTMLDivElement).style.transform = "translateY(-4px)";
              (e.currentTarget as HTMLDivElement).style.boxShadow = "0 12px 32px rgba(0,0,0,.1)";
            }}
            onMouseLeave={e => {
              (e.currentTarget as HTMLDivElement).style.transform = "translateY(0)";
              (e.currentTarget as HTMLDivElement).style.boxShadow = "0 2px 16px rgba(0,0,0,.05)";
            }}
            >
              <div style={{
                width: 52,
                height: 52,
                borderRadius: 14,
                background: `${f.color}15`,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontSize: "1.6rem",
                flexShrink: 0,
              }}>
                {f.icon}
              </div>
              <div>
                <h3 style={{ margin: "0 0 6px", fontSize: "1rem", fontWeight: 800, color: "var(--text)" }}>
                  {isAr ? f.title : f.titleEn}
                </h3>
                <p style={{ margin: 0, fontSize: ".87rem", color: "var(--text-2)", lineHeight: 1.6 }}>
                  {isAr ? f.desc : f.descEn}
                </p>
              </div>
            </div>
          ))}
        </div>

        {/* Stats Bar */}
        <div style={{
          background: "linear-gradient(135deg,#03045A,#0353A4)",
          borderRadius: 24,
          padding: "28px 36px",
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit,minmax(140px,1fr))",
          gap: 24,
          color: "white",
          textAlign: "center",
        }}>
          {[
            { n: "59", label: isAr ? "مفتاح تحكم" : "Control Flags" },
            { n: "7", label: isAr ? "تبويبات إدارة" : "Admin Tabs" },
            { n: "100%", label: isAr ? "تطبيق فوري" : "Instant Apply" },
            { n: "∞", label: isAr ? "مستخدمون" : "Users" },
          ].map(s => (
            <div key={s.label}>
              <div style={{ fontSize: "2rem", fontWeight: 900 }}>{s.n}</div>
              <div style={{ opacity: 0.8, fontSize: ".85rem", marginTop: 4 }}>{s.label}</div>
            </div>
          ))}
        </div>

        {/* CTA */}
        <div style={{ textAlign: "center", marginTop: 40 }}>
          <a href={`/${locale}/admin`} style={{
            display: "inline-block",
            background: "linear-gradient(135deg,#03045A,#0353A4)",
            color: "white",
            padding: "14px 36px",
            borderRadius: 16,
            fontWeight: 800,
            fontSize: "1rem",
            textDecoration: "none",
            marginLeft: 12,
          }}>
            {isAr ? "استكشف لوحة التحكم" : "Explore Admin Panel"} →
          </a>
          <a href={`/${locale}/app-demo`} style={{
            display: "inline-block",
            border: "2px solid #03045A",
            color: "var(--text)",
            padding: "12px 28px",
            borderRadius: 16,
            fontWeight: 700,
            fontSize: ".95rem",
            textDecoration: "none",
          }}>
            {isAr ? "جرّب التطبيق" : "Try the App"}
          </a>
        </div>
      </div>
    </section>
  );
}
