"use client";
import { useParams } from "next/navigation";
import { useState } from "react";

const STATS = [
  { label: "المستخدمون النشطون", value: "2,847", icon: "👥", color: "#0353A4" },
  { label: "الحجوزات اليوم", value: "143", icon: "📅", color: "#16A34A" },
  { label: "المشتركون Pro", value: "612", icon: "⭐", color: "#D97706" },
  { label: "الإيرادات (هذا الشهر)", value: "$18,240", icon: "💰", color: "#7C3AED" },
  { label: "الشركات النشطة", value: "28", icon: "🏢", color: "#0E7490" },
  { label: "العاملات المتاحات", value: "94", icon: "👩", color: "#BE185D" },
];

const RECENT_ACTIONS = [
  { action: "تعليق حساب شركة", admin: "أحمد المدير", time: "منذ 5 دقائق", type: "warn" },
  { action: "منح Gold 30 يوم", admin: "سارة الإدارة", time: "منذ 12 دقيقة", type: "success" },
  { action: "موافقة KYC عاملة", admin: "خالد المشرف", time: "منذ 25 دقيقة", type: "success" },
  { action: "تفعيل وضع الصيانة", admin: "أحمد المدير", time: "منذ ساعة", type: "error" },
  { action: "إيقاف وضع الصيانة", admin: "أحمد المدير", time: "منذ ساعة", type: "success" },
  { action: "إيقاف تسجيل العاملات", admin: "سارة الإدارة", time: "منذ 3 ساعات", type: "warn" },
];

const FLAGS_DEMO = [
  { key: "workerSection", label: "قسم العاملات", value: false },
  { key: "aiChat", label: "المساعد AI", value: true },
  { key: "voiceSearch", label: "البحث الصوتي", value: true },
  { key: "annualBooking", label: "الحجز السنوي", value: true },
  { key: "maintenance", label: "وضع الصيانة", value: false },
  { key: "subscriptions", label: "الاشتراكات Pro", value: true },
];

export default function AdminPage() {
  const { locale } = useParams<{ locale: string }>();
  const isAr = locale === "ar";
  const [flags, setFlags] = useState(FLAGS_DEMO);
  const [maintenanceOn, setMaintenanceOn] = useState(false);

  const toggleFlag = (key: string) => {
    setFlags(f => f.map(fl => fl.key === key ? { ...fl, value: !fl.value } : fl));
    if (key === "maintenance") setMaintenanceOn(v => !v);
  };

  return (
    <main dir={isAr ? "rtl" : "ltr"} style={{ minHeight: "100vh", background: "#F1F5F9", fontFamily: "var(--font)" }}>
      {/* Header */}
      <div style={{
        background: maintenanceOn
          ? "linear-gradient(135deg,#DC2626,#991B1B)"
          : "linear-gradient(135deg,#03045A,#0353A4)",
        padding: "28px 32px",
        color: "white",
        display: "flex",
        alignItems: "center",
        gap: 16,
        flexWrap: "wrap",
      }}>
        <span style={{ fontSize: "2rem" }}>🛡️</span>
        <div>
          <h1 style={{ margin: 0, fontSize: "1.5rem", fontWeight: 900 }}>
            {maintenanceOn ? "⚠️ التطبيق في وضع الصيانة" : "لوحة تحكم SmartMaid"}
          </h1>
          <p style={{ margin: 0, opacity: 0.8, fontSize: ".9rem" }}>
            {isAr ? "صلاحيات كاملة — مدير النظام" : "Full Access — System Administrator"}
          </p>
        </div>
        <div style={{ marginRight: "auto" }}>
          <span style={{
            background: "rgba(255,255,255,.2)",
            padding: "6px 16px",
            borderRadius: 20,
            fontSize: ".8rem",
            fontWeight: 700,
          }}>
            ⚡ {isAr ? "مباشر" : "Live"}
          </span>
        </div>
      </div>

      <div style={{ maxWidth: 1200, margin: "0 auto", padding: "32px 24px" }}>
        {/* Stats */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit,minmax(170px,1fr))", gap: 16, marginBottom: 32 }}>
          {STATS.map(s => (
            <div key={s.label} style={{
              background: "white",
              borderRadius: 16,
              padding: 20,
              borderTop: `4px solid ${s.color}`,
              boxShadow: "0 2px 12px rgba(0,0,0,.06)",
            }}>
              <div style={{ fontSize: "1.8rem", marginBottom: 8 }}>{s.icon}</div>
              <div style={{ fontSize: "1.6rem", fontWeight: 900, color: s.color }}>{s.value}</div>
              <div style={{ fontSize: ".8rem", color: "#64748B", marginTop: 4 }}>{s.label}</div>
            </div>
          ))}
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 24 }}>
          {/* Feature Flags */}
          <div style={{ background: "white", borderRadius: 20, padding: 24, boxShadow: "0 2px 12px rgba(0,0,0,.06)" }}>
            <h2 style={{ margin: "0 0 20px", fontSize: "1.1rem", fontWeight: 900, display: "flex", alignItems: "center", gap: 8 }}>
              <span>⚙️</span> {isAr ? "التحكم بالمنصة" : "Platform Flags"}
            </h2>
            <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
              {flags.map(fl => (
                <div key={fl.key} style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "10px 14px",
                  borderRadius: 12,
                  background: fl.value ? "#F0FDF4" : "#FEF2F2",
                  border: `1px solid ${fl.value ? "#86EFAC" : "#FECACA"}`,
                }}>
                  <span style={{ fontWeight: 600, fontSize: ".9rem" }}>{fl.label}</span>
                  <button
                    onClick={() => toggleFlag(fl.key)}
                    style={{
                      width: 44,
                      height: 24,
                      borderRadius: 12,
                      border: "none",
                      background: fl.value ? "#16A34A" : "#D1D5DB",
                      cursor: "pointer",
                      position: "relative",
                      transition: "background .2s",
                    }}
                  >
                    <span style={{
                      position: "absolute",
                      top: 3,
                      left: fl.value ? 23 : 3,
                      width: 18,
                      height: 18,
                      borderRadius: "50%",
                      background: "white",
                      transition: "left .2s",
                    }} />
                  </button>
                </div>
              ))}
            </div>
            <p style={{ margin: "16px 0 0", fontSize: ".75rem", color: "#94A3B8", textAlign: "center" }}>
              {isAr ? "هذه معاينة — التحكم الكامل من التطبيق" : "Preview only — Full control in app"}
            </p>
          </div>

          {/* Recent Actions */}
          <div style={{ background: "white", borderRadius: 20, padding: 24, boxShadow: "0 2px 12px rgba(0,0,0,.06)" }}>
            <h2 style={{ margin: "0 0 20px", fontSize: "1.1rem", fontWeight: 900, display: "flex", alignItems: "center", gap: 8 }}>
              <span>📋</span> {isAr ? "آخر إجراءات الإدارة" : "Recent Admin Actions"}
            </h2>
            <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
              {RECENT_ACTIONS.map((a, i) => (
                <div key={i} style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 12,
                  padding: "10px 0",
                  borderBottom: i < RECENT_ACTIONS.length - 1 ? "1px solid #F1F5F9" : "none",
                }}>
                  <span style={{
                    width: 8, height: 8, borderRadius: "50%", flexShrink: 0,
                    background: a.type === "success" ? "#16A34A" : a.type === "error" ? "#DC2626" : "#D97706",
                  }} />
                  <div style={{ flex: 1 }}>
                    <div style={{ fontWeight: 600, fontSize: ".85rem" }}>{a.action}</div>
                    <div style={{ color: "#94A3B8", fontSize: ".75rem" }}>{a.admin} · {a.time}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Subscriptions Summary */}
        <div style={{ background: "white", borderRadius: 20, padding: 24, marginTop: 24, boxShadow: "0 2px 12px rgba(0,0,0,.06)" }}>
          <h2 style={{ margin: "0 0 20px", fontSize: "1.1rem", fontWeight: 900 }}>
            💳 {isAr ? "توزيع الاشتراكات" : "Subscription Distribution"}
          </h2>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit,minmax(160px,1fr))", gap: 16 }}>
            {[
              { label: "مجاني", count: 2235, color: "#64748B", pct: 78 },
              { label: "SmartGold ✨", count: 478, color: "#D97706", pct: 17 },
              { label: "SmartPlatinum 💎", count: 134, color: "#7C3AED", pct: 5 },
            ].map(s => (
              <div key={s.label} style={{ textAlign: "center" }}>
                <div style={{ fontSize: "1.8rem", fontWeight: 900, color: s.color }}>{s.count.toLocaleString()}</div>
                <div style={{ fontSize: ".85rem", marginBottom: 8 }}>{s.label}</div>
                <div style={{ height: 6, background: "#F1F5F9", borderRadius: 3, overflow: "hidden" }}>
                  <div style={{ height: "100%", width: `${s.pct}%`, background: s.color, borderRadius: 3 }} />
                </div>
                <div style={{ fontSize: ".75rem", color: "#94A3B8", marginTop: 4 }}>{s.pct}%</div>
              </div>
            ))}
          </div>
        </div>

        <p style={{ textAlign: "center", color: "#94A3B8", marginTop: 32, fontSize: ".8rem" }}>
          {isAr
            ? "هذه بيانات تجريبية — الإدارة الكاملة متاحة في تطبيق SmartMaid"
            : "Demo data — Full admin panel available in the SmartMaid app"}
        </p>
      </div>
    </main>
  );
}
