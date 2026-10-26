"use client";
import { useState } from "react";
import { useLocale } from "next-intl";

const DATA = {
  ar: {
    label:"آراء العملاء", title:"يثق بنا الآلاف",
    sub:"تجارب حقيقية من عملاء وعاملات وشركات",
    items:[
      { n:"نورة العتيبي", c:"الرياض", r:"👤 عميلة", color:"var(--indigo)", t:"حجزت عاملة في دقيقة وخدمة ممتازة. ميزة GPS سهّلت تحديد العنوان تماماً. أنصح به بشدة!" },
      { n:"خالد المطيري", c:"جدة", r:"👤 عميل", color:"var(--indigo)", t:"الدفع الآمن عبر Escrow أعطاني ثقة كاملة. ما دفعت إلا بعد ما اقتنعت بالخدمة." },
      { n:"ماريا سانتوس", c:"الرياض", r:"👩‍🔧 عاملة", color:"var(--cyan)", t:"المنصة أعطتني حرية إدارة وقتي. 80% من كل حجز — أفضل نسبة في السوق." },
      { n:"فاطمة علي", c:"الكويت", r:"👩‍🔧 عاملة", color:"var(--cyan)", t:"التسجيل والتوثيق KYC كان سهلاً جداً. طلبات تأتيني كل يوم!" },
      { n:"شركة النظافة المثالية", c:"الرياض", r:"🏢 شركة", color:"#8B5CF6", t:"لوحة التحكم نظّمت فريقنا. تقارير PDF وإسناد الطلبات يوفّران وقتاً كبيراً." },
    ],
  },
  en: {
    label:"Testimonials", title:"Trusted by thousands",
    sub:"Real experiences from customers, maids, and companies",
    items:[
      { n:"Noura Al-Otaibi", c:"Riyadh", r:"👤 Customer", color:"var(--indigo)", t:"Booked a maid in a minute — the GPS feature made setting my address so easy. Highly recommend!" },
      { n:"Khalid Al-Mutairi", c:"Jeddah", r:"👤 Customer", color:"var(--indigo)", t:"Escrow payments gave me full confidence. I didn't pay until I was satisfied with the service." },
      { n:"Maria Santos", c:"Riyadh", r:"👩‍🔧 Maid", color:"var(--cyan)", t:"The platform gives me freedom to manage my time. 80% of every booking — best rate in the market!" },
      { n:"Fatima Ali", c:"Kuwait", r:"👩‍🔧 Maid", color:"var(--cyan)", t:"Registration and KYC verification was super easy. Orders come to me every day!" },
      { n:"Ideal Cleaning Co.", c:"Riyadh", r:"🏢 Company", color:"#8B5CF6", t:"The dashboard organized our team perfectly. PDF invoices and order assignment save us enormous time." },
    ],
  },
};

export default function TestimonialsSection() {
  const locale = useLocale();
  const ar = locale === "ar";
  const d = ar ? DATA.ar : DATA.en;
  const [idx, setIdx] = useState(0);
  const cur = d.items[idx];

  return (
    <section id="testimonials" className="section-sm" style={{ background:"var(--bg-alt)" }}>
      <div className="divider" style={{ position:"absolute", top:0, left:0, right:0 }} />
      <div className="mx">
        <div style={{ textAlign:"center", marginBottom:"2.5rem" }}>
          <span className="badge badge-brand" style={{ marginBottom:"1rem" }}>
            <span className="pulse" />{d.label}
          </span>
          <h2 className="t-h1" style={{ color:"var(--text)", marginBottom:".6rem" }}>{d.title}</h2>
          <p className="t-lead" style={{ maxWidth:400, marginInline:"auto" }}>{d.sub}</p>
        </div>

        <div style={{ maxWidth:700, marginInline:"auto" }}>
          <div className="card" style={{ padding:"clamp(2rem,5vw,3rem)", textAlign:"center", borderColor:`${cur.color}22` }}>
            <div style={{ display:"flex", justifyContent:"center", gap:3, marginBottom:"1.5rem" }}>
              {"★★★★★".split("").map((s,i)=><span key={i} style={{ color:"#fbbf24", fontSize:20 }}>{s}</span>)}
            </div>
            <p style={{ fontSize:"1.1rem", lineHeight:1.8, color:"var(--text)", marginBottom:"1.75rem", fontStyle:"italic" }}>"{cur.t}"</p>
            <div style={{ display:"flex", alignItems:"center", justifyContent:"center", gap:12 }}>
              <div style={{ width:44, height:44, borderRadius:"50%", background:`linear-gradient(135deg,${cur.color},var(--cyan))`, display:"flex", alignItems:"center", justifyContent:"center", color:"#fff", fontWeight:900, fontSize:"1.1rem" }}>
                {cur.n.charAt(0)}
              </div>
              <div style={{ textAlign:ar?"right":"left" }}>
                <div style={{ fontWeight:800, color:"var(--text)" }}>{cur.n}</div>
                <div style={{ fontSize:".8rem", color:"var(--text-3)" }}>{cur.c} — {cur.r}</div>
              </div>
            </div>
          </div>

          {/* Dots */}
          <div style={{ display:"flex", justifyContent:"center", alignItems:"center", gap:10, marginTop:"1.5rem" }}>
            <button onClick={()=>setIdx(p=>(p-1+d.items.length)%d.items.length)} style={{ width:36, height:36, borderRadius:10, border:"1.5px solid var(--border)", background:"var(--surface)", cursor:"pointer", fontSize:18, color:"var(--text-2)", display:"flex", alignItems:"center", justifyContent:"center", transition:"all .15s" }}
              onMouseEnter={e=>{(e.currentTarget as HTMLButtonElement).style.borderColor="var(--indigo)";(e.currentTarget as HTMLButtonElement).style.color="var(--indigo)";}}
              onMouseLeave={e=>{(e.currentTarget as HTMLButtonElement).style.borderColor="var(--border)";(e.currentTarget as HTMLButtonElement).style.color="var(--text-2)";}}>
              {ar?"›":"‹"}
            </button>
            {d.items.map((_,i)=>(
              <button key={i} onClick={()=>setIdx(i)} style={{ height:8, borderRadius:99, border:"none", cursor:"pointer", transition:"all .25s", background:i===idx?"var(--indigo)":"var(--border)", width:i===idx?28:8 }} />
            ))}
            <button onClick={()=>setIdx(p=>(p+1)%d.items.length)} style={{ width:36, height:36, borderRadius:10, border:"1.5px solid var(--border)", background:"var(--surface)", cursor:"pointer", fontSize:18, color:"var(--text-2)", display:"flex", alignItems:"center", justifyContent:"center", transition:"all .15s" }}
              onMouseEnter={e=>{(e.currentTarget as HTMLButtonElement).style.borderColor="var(--indigo)";(e.currentTarget as HTMLButtonElement).style.color="var(--indigo)";}}
              onMouseLeave={e=>{(e.currentTarget as HTMLButtonElement).style.borderColor="var(--border)";(e.currentTarget as HTMLButtonElement).style.color="var(--text-2)";}}>
              {ar?"‹":"›"}
            </button>
          </div>
        </div>
      </div>
    </section>
  );
}
