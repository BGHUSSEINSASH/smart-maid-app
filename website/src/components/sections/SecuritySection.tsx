"use client";
import { useLocale } from "next-intl";

const ITEMS_AR = [
  { i:"🔐", t:"تشفير SSL كامل", d:"بياناتك محمية بتشفير من طرف لطرف على كل الاتصالات" },
  { i:"✅", t:"توثيق الهوية KYC", d:"التحقق من كل عاملة بالمستندات الرسمية قبل التفعيل" },
  { i:"💰", t:"حماية الأموال Escrow", d:"نظام Escrow يحتجز المبلغ ويحوّله فقط بعد إتمام الخدمة" },
  { i:"🔒", t:"قفل التطبيق PIN", d:"حماية إضافية برمز سري مشفّر أو بصمة الإصبع" },
  { i:"📜", t:"سجل تدقيق كامل", d:"كل عملية مسجّلة وقابلة للمراجعة بشفافية تامة" },
  { i:"🛡️", t:"صلاحيات متدرّجة", d:"24 صلاحية للموظفين الإداريين — SuperAdmin إلى وكيل دعم" },
];

const ITEMS_EN = [
  { i:"🔐", t:"Full SSL Encryption", d:"Your data protected with end-to-end encryption on all connections" },
  { i:"✅", t:"KYC Identity Verification", d:"Every maid verified with official documents before activation" },
  { i:"💰", t:"Escrow Money Protection", d:"System holds funds and only transfers after service completion" },
  { i:"🔒", t:"PIN App Lock", d:"Extra protection with encrypted PIN code or fingerprint" },
  { i:"📜", t:"Full Audit Trail", d:"Every action logged and reviewable with complete transparency" },
  { i:"🛡️", t:"Granular Permissions", d:"24 admin permissions — from SuperAdmin to support agent" },
];

export default function SecuritySection() {
  const locale = useLocale();
  const ar = locale === "ar";
  const items = ar ? ITEMS_AR : ITEMS_EN;

  return (
    <section id="security" className="section" style={{ background:"#060513", position:"relative", overflow:"hidden" }}>
      <div style={{ position:"absolute", inset:0, backgroundImage:"radial-gradient(circle, rgba(79,70,229,.15) 1px, transparent 1px)", backgroundSize:"28px 28px", opacity:.5 }} />
      <div style={{ position:"absolute", width:700, height:700, borderRadius:"50%", background:"rgba(79,70,229,.18)", filter:"blur(100px)", top:"50%", left:"50%", transform:"translate(-50%,-50%)", pointerEvents:"none" }} />
      <div style={{ position:"absolute", width:300, height:300, borderRadius:"50%", background:"rgba(6,182,212,.1)", filter:"blur(80px)", top:"20%", right:"10%", pointerEvents:"none" }} />

      <div className="mx" style={{ position:"relative", zIndex:2 }}>
        <div style={{ textAlign:"center", marginBottom:"clamp(2.5rem,5vw,4rem)" }}>
          <span className="badge badge-dark" style={{ marginBottom:"1rem" }}>
            <span className="pulse" style={{ background:"#c7d2fe" }} />
            {ar?"الأمان والخصوصية":"Security & Privacy"}
          </span>
          <h2 className="t-h1" style={{ color:"#fff", marginBottom:".75rem" }}>
            {ar?"أمانك ليس خياراً":"Security is not optional"}
          </h2>
          <p style={{ color:"rgba(255,255,255,.55)", fontSize:"1.05rem", maxWidth:480, marginInline:"auto" }}>
            {ar?"بُنيت المنصة على أعلى معايير الحماية والأمان الرقمي":"Built on the highest standards of digital protection and security"}
          </p>
        </div>

        <div style={{ display:"grid", gridTemplateColumns:"repeat(3,1fr)", gap:"1.25rem" }} className="sec-grid">
          <style>{`.sec-grid{@media(max-width:900px){grid-template-columns:repeat(2,1fr)!important}@media(max-width:560px){grid-template-columns:1fr!important}}`}</style>
          {items.map((item,i) => (
            <div key={i} style={{ padding:"1.75rem 1.5rem", borderRadius:20, textAlign:"center", background:"rgba(255,255,255,.04)", border:"1px solid rgba(255,255,255,.08)", backdropFilter:"blur(12px)", transition:"all .25s", cursor:"default" }}
              onMouseEnter={e=>{const el=e.currentTarget as HTMLDivElement;el.style.background="rgba(79,70,229,.12)";el.style.borderColor="rgba(79,70,229,.35)";el.style.transform="translateY(-4px)";}}
              onMouseLeave={e=>{const el=e.currentTarget as HTMLDivElement;el.style.background="rgba(255,255,255,.04)";el.style.borderColor="rgba(255,255,255,.08)";el.style.transform="translateY(0)";}}>
              <div style={{ fontSize:"2.2rem", marginBottom:"1rem" }}>{item.i}</div>
              <h3 style={{ fontSize:"1rem", fontWeight:800, color:"#fff", marginBottom:".6rem" }}>{item.t}</h3>
              <p style={{ fontSize:".83rem", color:"rgba(255,255,255,.45)", lineHeight:1.65 }}>{item.d}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
