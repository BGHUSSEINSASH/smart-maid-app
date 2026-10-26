"use client";
import { useState } from "react";
import { useLocale } from "next-intl";

const DATA = {
  ar: {
    label:"الأسعار", title:"خطط تناسب الجميع",
    sub:"للأفراد، ابدأ مجاناً. للشركات، اشترك وطوّر أعمالك",
    tabs:["للأفراد والعملاء","للشركات"],
    personal: [
      { name:"مجاني", price:"0", unit:"", desc:"للأفراد والعملاء", popular:false, pts:["حجز غير محدود","محفظة رقمية","تقييمات وآراء","دعم عبر الدردشة","تحديد موقع GPS"] },
      { name:"SmartGold", price:"9.99", unit:"/شهر", desc:"للمستخدمين المميّزين", popular:true, pts:["كل مزايا المجاني","خصم 10% على كل حجز","أولوية في نتائج البحث","إلغاء مجاني حتى 24 ساعة","دعم أولوية"] },
      { name:"SmartPlatinum", price:"19.99", unit:"/شهر", desc:"للمحترفين", popular:false, pts:["كل مزايا Gold","خصم 15% دائم","أولوية قصوى","إلغاء مجاني دائم","عاملة بديلة فوراً","دعم 24/7"] },
    ],
    company: [
      { name:"أساسي", price:"49", unit:"/شهر", desc:"حتى 5 عاملات", popular:false, pts:["لوحة تحكم أساسية","KPIs حقيقية","تقارير شهرية","دعم عبر البريد"] },
      { name:"برو", price:"129", unit:"/شهر", desc:"حتى 20 عاملة", popular:true, pts:["تحليلات متقدمة","توزيع ذكي للطلبات","فواتير PDF","دعم أولوية 24/7"] },
      { name:"متميز", price:"تواصل", unit:"", desc:"عاملات غير محدود", popular:false, pts:["API خاص","مدير حساب مخصص","تكامل ERP كامل","دعم 24/7"] },
    ],
    cta:"ابدأ الآن", pop:"الأكثر طلباً",
  },
  en: {
    label:"Pricing", title:"Plans for everyone",
    sub:"For individuals, start free. For companies, scale your business",
    tabs:["For Individuals","For Companies"],
    personal: [
      { name:"Free", price:"0", unit:"", desc:"For individuals & customers", popular:false, pts:["Unlimited bookings","Digital wallet","Ratings & reviews","Chat support","GPS address detection"] },
      { name:"SmartGold", price:"9.99", unit:"/mo", desc:"For premium users", popular:true, pts:["Everything in Free","10% discount on all bookings","Priority in search","Free cancellation to 24h","Priority support"] },
      { name:"SmartPlatinum", price:"19.99", unit:"/mo", desc:"For professionals", popular:false, pts:["Everything in Gold","15% permanent discount","Top priority always","Always free cancellation","Instant replacement maid","24/7 dedicated support"] },
    ],
    company: [
      { name:"Basic", price:"49", unit:"/mo", desc:"Up to 5 maids", popular:false, pts:["Basic dashboard","Real KPIs","Monthly reports","Email support"] },
      { name:"Pro", price:"129", unit:"/mo", desc:"Up to 20 maids", popular:true, pts:["Advanced analytics","Smart order distribution","PDF invoicing","24/7 priority support"] },
      { name:"Enterprise", price:"Contact", unit:"", desc:"Unlimited maids", popular:false, pts:["Custom API","Dedicated account manager","Full ERP integration","24/7 support"] },
    ],
    cta:"Get Started", pop:"Most Popular",
  },
};

export default function PricingSection() {
  const locale = useLocale();
  const ar = locale === "ar";
  const d = ar ? DATA.ar : DATA.en;
  const [tab, setTab] = useState(0);
  const plans = tab === 0 ? d.personal : d.company;

  return (
    <section id="pricing" className="section" style={{ background:"var(--bg)" }}>
      <div className="mx">
        <div style={{ textAlign:"center", marginBottom:"3rem" }}>
          <span className="badge badge-brand" style={{ marginBottom:"1rem" }}>
            <span className="pulse" />{d.label}
          </span>
          <h2 className="t-h1" style={{ color:"var(--text)", marginBottom:".75rem" }}>{d.title}</h2>
          <p className="t-lead" style={{ maxWidth:480, marginInline:"auto" }}>{d.sub}</p>
        </div>

        {/* Tab switcher */}
        <div style={{ display:"flex", justifyContent:"center", gap:8, marginBottom:"2.5rem" }}>
          {d.tabs.map((t,i) => (
            <button key={i} onClick={()=>setTab(i)} style={{
              padding:".65rem 1.75rem", borderRadius:99, fontWeight:700, fontSize:".9rem", cursor:"pointer", transition:"all .2s",
              background:tab===i?"var(--indigo)":"transparent",
              color:tab===i?"#fff":"var(--text-2)",
              border:tab===i?"none":"1.5px solid var(--border)",
              boxShadow:tab===i?"var(--shadow-brand)":"none",
            }}>{t}</button>
          ))}
        </div>

        {/* Plans grid */}
        <div style={{ display:"grid", gridTemplateColumns:"repeat(3,1fr)", gap:"1.5rem", alignItems:"start", maxWidth:940, marginInline:"auto" }} className="plan-grid">
          <style>{`.plan-grid{@media(max-width:820px){grid-template-columns:1fr!important}}`}</style>
          {plans.map((plan,i) => (
            <div key={i} style={{
              borderRadius:24, padding:"2rem", position:"relative",
              ...(plan.popular ? {
                background:"linear-gradient(160deg,var(--indigo) 0%,var(--brand-2) 100%)",
                boxShadow:"0 0 0 1px rgba(255,255,255,.15) inset, var(--shadow-brand)",
                transform:"scale(1.04)",
              } : {
                background:"var(--surface)", border:"1.5px solid var(--border)",
                boxShadow:"var(--shadow-sm)",
              }),
            }}>
              {plan.popular && (
                <div style={{ position:"absolute", top:-14, left:"50%", transform:"translateX(-50%)", background:"#fbbf24", color:"#0B0918", fontSize:".7rem", fontWeight:900, padding:".3rem 1rem", borderRadius:99, whiteSpace:"nowrap", boxShadow:"0 4px 12px rgba(251,191,36,.4)" }}>
                  ⭐ {d.pop}
                </div>
              )}
              <div style={{ fontSize:".72rem", fontWeight:700, letterSpacing:".06em", textTransform:"uppercase", color:plan.popular?"rgba(255,255,255,.65)":"var(--text-3)", marginBottom:".5rem" }}>{plan.desc}</div>
              <h3 style={{ fontSize:"1.3rem", fontWeight:900, color:plan.popular?"#fff":"var(--text)", marginBottom:".75rem" }}>{plan.name}</h3>
              <div style={{ marginBottom:"1.5rem", display:"flex", alignItems:"baseline", gap:4 }}>
                <span style={{ fontSize:"2.4rem", fontWeight:900, color:plan.popular?"#fff":"var(--text)", lineHeight:1 }}>{plan.price}</span>
                {plan.unit && <span style={{ fontSize:".85rem", color:plan.popular?"rgba(255,255,255,.6)":"var(--text-2)" }}>{plan.unit}</span>}
              </div>
              <div style={{ display:"flex", flexDirection:"column", gap:".6rem", marginBottom:"1.75rem" }}>
                {plan.pts.map((f,j) => (
                  <div key={j} style={{ display:"flex", alignItems:"center", gap:8, fontSize:".875rem", color:plan.popular?"rgba(255,255,255,.9)":"var(--text-2)" }}>
                    <span style={{ fontSize:12, color:plan.popular?"#a5f3fc":"var(--indigo)", flexShrink:0 }}>✓</span>{f}
                  </div>
                ))}
              </div>
              <button style={{
                width:"100%", padding:".85rem", borderRadius:14, fontWeight:800, cursor:"pointer", fontSize:".9rem", transition:"all .2s",
                ...(plan.popular ? { background:"#fff", color:"var(--indigo)", border:"none", boxShadow:"0 4px 16px rgba(0,0,0,.15)" }
                  : { background:"transparent", border:"1.5px solid var(--border)", color:"var(--text)" }),
              }}
                onMouseEnter={e=>{if(!plan.popular){(e.currentTarget as HTMLButtonElement).style.borderColor="var(--indigo)";(e.currentTarget as HTMLButtonElement).style.color="var(--indigo)";}}}
                onMouseLeave={e=>{if(!plan.popular){(e.currentTarget as HTMLButtonElement).style.borderColor="var(--border)";(e.currentTarget as HTMLButtonElement).style.color="var(--text)";}}}
              >{d.cta}</button>
            </div>
          ))}
        </div>

        {/* Admin Grant note */}
        <div style={{ textAlign:"center", marginTop:"2rem", padding:"1.25rem", borderRadius:16, background:"var(--bg-alt)", border:"1px solid var(--border)", maxWidth:600, marginInline:"auto" }}>
          <p style={{ fontSize:".875rem", color:"var(--text-2)" }}>
            {ar
              ? "💡 المدير يستطيع منح اشتراك Gold أو Platinum لأي مستخدم مباشرة من لوحة التحكم — من يوم واحد حتى 365 يوم"
              : "💡 Admin can grant Gold or Platinum to any user directly from the dashboard — from 1 day to 365 days"}
          </p>
        </div>
      </div>
    </section>
  );
}
