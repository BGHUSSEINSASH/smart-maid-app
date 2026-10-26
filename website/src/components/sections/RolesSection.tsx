"use client";
import { useState } from "react";
import { useLocale } from "next-intl";

const DATA = {
  ar: {
    label:"الأدوار", title:"منصة واحدة، ثلاثة عوالم",
    sub:"تجربة مصمّمة خصيصاً لكل نوع مستخدم",
    tabs:["للعميل 👤","للعاملة 👩‍🔧","للشركة 🏢"],
    titles:["راحتك أولويتنا","دخلك بين يديك","أدر عملياتك بذكاء"],
    descs:[
      "حجز سريع وآمن مع نقاط ولاء وخصومات على كل خدمة",
      "استقبلي الطلبات وأديري جدولك واحصلي على 80% من كل حجز",
      "لوحة تحكم متكاملة لإدارة الفريق والإيرادات والتقارير",
    ],
    points:[
      ["حجز عاملات مستقلات أو شركات","نقاط ولاء وخصومات حصرية","محفظة رقمية Escrow آمنة","تحديد الموقع بـ GPS","تتبّع مباشر وإشعارات فورية","تقييمات وشفافية كاملة"],
      ["قبول/رفض الطلبات بحرية","80% من قيمة كل حجز","جدول أسبوعي منظّم","تسويات مالية شفافة","KYC بسيط وسريع","تقييمات تبني سمعتك"],
      ["KPIs حقيقية من البيانات","إسناد الطلبات للعاملات","تقارير إيرادات مفصّلة","خدمات قابلة للتخصيص","فواتير PDF قابلة للتصدير","خطط اشتراك مرنة"],
    ],
    colors:["var(--indigo)","var(--cyan)","#8B5CF6"],
    bgs:["var(--indigo-l)","var(--cyan-l)","rgba(139,92,246,.1)"],
    ctas:["/register/customer","/register/worker","/register/company"],
    ctaLabels:["ابدأ مجاناً","سجّلي كعاملة","سجّل شركتك"],
  },
  en: {
    label:"Roles", title:"One platform, three worlds",
    sub:"An experience crafted specifically for each user type",
    tabs:["For Customers 👤","For Maids 👩‍🔧","For Companies 🏢"],
    titles:["Your comfort first","Your income, your control","Run operations smartly"],
    descs:[
      "Fast, secure booking with loyalty points and discounts on every service",
      "Accept orders, manage your schedule, and keep 80% of every booking",
      "Full dashboard to manage your team, revenue, and detailed reports",
    ],
    points:[
      ["Book maids or companies","Loyalty points & discounts","Secure Escrow wallet","GPS address detection","Live tracking & notifications","Full ratings & transparency"],
      ["Accept or decline orders freely","Keep 80% of every booking","Organized weekly schedule","Transparent financial settlements","Simple, fast KYC","Reviews build your reputation"],
      ["Real KPIs from live data","Smart order assignment","Detailed revenue reports","Customizable services","Exportable PDF invoices","Flexible subscription plans"],
    ],
    colors:["var(--indigo)","var(--cyan)","#8B5CF6"],
    bgs:["var(--indigo-l)","var(--cyan-l)","rgba(139,92,246,.1)"],
    ctas:["/register/customer","/register/worker","/register/company"],
    ctaLabels:["Start Free","Register as Maid","Register Company"],
  },
};

export default function RolesSection() {
  const locale = useLocale();
  const ar = locale === "ar";
  const d = ar ? DATA.ar : DATA.en;
  const [active, setActive] = useState(0);

  return (
    <section id="roles" className="section" style={{ background:"var(--bg)" }}>
      <div className="mx">
        <div style={{ textAlign:"center", marginBottom:"3rem" }}>
          <span className="badge badge-brand" style={{ marginBottom:"1rem" }}>
            <span className="pulse" />{d.label}
          </span>
          <h2 className="t-h1" style={{ color:"var(--text)", marginBottom:".75rem" }}>{d.title}</h2>
          <p className="t-lead" style={{ maxWidth:480, marginInline:"auto" }}>{d.sub}</p>
        </div>

        {/* Tabs */}
        <div style={{ display:"flex", justifyContent:"center", gap:10, marginBottom:"2.5rem", flexWrap:"wrap" }}>
          {d.tabs.map((tab,i) => (
            <button key={i} onClick={()=>setActive(i)} style={{
              padding:".65rem 1.5rem", borderRadius:99, fontWeight:700, fontSize:".875rem",
              cursor:"pointer", transition:"all .2s",
              background:active===i?d.colors[i]:"transparent",
              color:active===i?"#fff":"var(--text-2)",
              border:active===i?"none":`1.5px solid var(--border)`,
              boxShadow:active===i?"0 4px 20px rgba(79,70,229,.3)":"none",
              transform:active===i?"scale(1.04)":"scale(1)",
            }}>{tab}</button>
          ))}
        </div>

        {/* Card */}
        <div className="card" style={{ padding:"clamp(2rem,5vw,3.5rem)", maxWidth:820, marginInline:"auto", borderColor:`${d.colors[active]}33` }}>
          <div style={{ display:"flex", flexDirection:"column", gap:".75rem", marginBottom:"2rem" }}>
            <h3 style={{ fontSize:"1.6rem", fontWeight:900, color:"var(--text)" }}>{d.titles[active]}</h3>
            <p style={{ color:"var(--text-2)", fontSize:".95rem" }}>{d.descs[active]}</p>
          </div>
          <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:".75rem 2rem" }} className="role-grid">
            <style>{`.role-grid{@media(max-width:540px){grid-template-columns:1fr!important}}`}</style>
            {(d.points[active] as string[]).map((p,i) => (
              <div key={i} style={{ display:"flex", alignItems:"center", gap:10 }}>
                <div style={{ width:22, height:22, borderRadius:"50%", background:d.bgs[active], border:`1px solid ${d.colors[active]}33`, display:"flex", alignItems:"center", justifyContent:"center", fontSize:11, color:d.colors[active], flexShrink:0 }}>✓</div>
                <span style={{ fontSize:".9rem", color:"var(--text)", fontWeight:500 }}>{p}</span>
              </div>
            ))}
          </div>
          <div style={{ marginTop:"2rem" }}>
            <a href={`/${locale}${d.ctas[active]}`} className="btn btn-primary">
              {d.ctaLabels[active]} →
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
