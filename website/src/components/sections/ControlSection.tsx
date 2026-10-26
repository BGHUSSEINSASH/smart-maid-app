"use client";
import { useLocale } from "next-intl";

const ITEMS_AR = [
  { icon:"🎛️", t:"إخفاء وإظهار الأقسام", d:"أغلق أي قسم من التطبيق لأي دور بمفتاح واحد" },
  { icon:"💰", t:"إدارة العمولات", d:"عمولة مخصصة لكل شركة أو عمولة عالمية موحّدة" },
  { icon:"👑", t:"منح الاشتراكات", d:"منح Gold أو Platinum لأي مستخدم من يوم حتى سنة" },
  { icon:"🛡️", t:"إدارة الحسابات", d:"تعليق، حذف، تفعيل أي حساب فوراً مع سبب" },
  { icon:"✅", t:"مراجعة KYC", d:"قبول أو رفض توثيق العاملات مع ملاحظات" },
  { icon:"💬", t:"إدارة المحادثات", d:"الرد على العملاء وحل المشاكل مباشرة" },
  { icon:"⚡", t:"ردود تلقائية", d:"كلمات مفتاحية مع ردود فورية لتوفير وقت الدعم" },
  { icon:"🎁", t:"التعويضات", d:"إصدار تعويضات (رصيد، أيام اشتراك، كوبون) موثّقة" },
  { icon:"📊", t:"تقارير الأداء", d:"إيرادات وعمولات وأداء العاملات في رسوم بيانية" },
];

const ITEMS_EN = [
  { icon:"🎛️", t:"Show/Hide Sections", d:"Toggle any app section for any user role with one switch" },
  { icon:"💰", t:"Commission Management", d:"Custom commission per company or a global unified rate" },
  { icon:"👑", t:"Grant Subscriptions", d:"Give Gold or Platinum to any user from 1 day to a year" },
  { icon:"🛡️", t:"Account Management", d:"Suspend, delete, or activate any account instantly with reason" },
  { icon:"✅", t:"KYC Review", d:"Approve or reject maid verification with detailed notes" },
  { icon:"💬", t:"Chat Management", d:"Reply to users and resolve issues directly from admin" },
  { icon:"⚡", t:"Auto Replies", d:"Keywords with instant replies to save support team time" },
  { icon:"🎁", t:"Compensations", d:"Issue credits, subscription days, or coupons with documentation" },
  { icon:"📊", t:"Performance Reports", d:"Revenue, commissions, worker performance in visual charts" },
];

export default function ControlSection() {
  const locale = useLocale();
  const ar = locale === "ar";
  const items = ar ? ITEMS_AR : ITEMS_EN;

  return (
    <section id="control" className="section" style={{ background:"var(--bg-alt)", position:"relative", overflow:"hidden" }}>
      <div className="divider" style={{ position:"absolute", top:0, left:0, right:0 }} />
      <div className="divider" style={{ position:"absolute", bottom:0, left:0, right:0 }} />

      <div className="mx">
        {/* Header */}
        <div style={{ display:"flex", flexDirection:"column", gap:"1.5rem", marginBottom:"clamp(2.5rem,5vw,4rem)" }}>
          <div>
            <span className="badge badge-brand" style={{ marginBottom:"1rem" }}>
              <span className="pulse" />{ar?"التحكم المركزي":"Central Control"}
            </span>
            <h2 className="t-h1" style={{ color:"var(--text)", marginBottom:".75rem" }}>
              {ar?"تحكم مركزي بكل شيء":"Full Central Control"}
            </h2>
            <p className="t-lead" style={{ maxWidth:560 }}>
              {ar?"المدير يتحكم في كل شيء من لوحة واحدة — أغلق، افتح، عدّل، راقب":"Admin controls everything from one dashboard — close, open, edit, monitor"}
            </p>
          </div>
          
          {/* Stats row */}
          <div style={{ display:"flex", flexWrap:"wrap", gap:"1.5rem" }}>
            {(ar
              ? [["9","أداة تحكم رئيسية"],["4","أدوار مستخدم"],["100%","تغطية كل الأقسام"]]
              : [["9","Admin Tools"],["4","User Roles"],["100%","Full Section Coverage"]]
            ).map(([v,l]) => (
              <div key={l} style={{ padding:".75rem 1.25rem", borderRadius:14, border:"1.5px solid var(--indigo-m)", background:"var(--indigo-l)" }}>
                <div style={{ fontSize:"1.6rem", fontWeight:900, color:"var(--indigo)" }}>{v}</div>
                <div style={{ fontSize:".78rem", color:"var(--indigo)", fontWeight:600, marginTop:2 }}>{l}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Grid */}
        <div style={{ display:"grid", gridTemplateColumns:"repeat(3,1fr)", gap:"1.25rem" }} className="control-grid">
          <style>{`.control-grid{@media(max-width:900px){grid-template-columns:repeat(2,1fr)!important}@media(max-width:560px){grid-template-columns:1fr!important}}`}</style>
          {items.map((item,i) => (
            <div key={i} className="card" style={{ padding:"1.5rem", display:"flex", alignItems:"flex-start", gap:"1rem" }}>
              <div style={{ width:46, height:46, borderRadius:12, background:"var(--indigo-l)", display:"flex", alignItems:"center", justifyContent:"center", fontSize:"1.25rem", flexShrink:0 }}>
                {item.icon}
              </div>
              <div>
                <h3 style={{ fontSize:".95rem", fontWeight:800, color:"var(--text)", marginBottom:".35rem" }}>{item.t}</h3>
                <p style={{ fontSize:".82rem", color:"var(--text-2)", lineHeight:1.6 }}>{item.d}</p>
              </div>
            </div>
          ))}
        </div>

        {/* CTA */}
        <div style={{ textAlign:"center", marginTop:"3rem" }}>
          <a href={`/${locale}/app-demo`} className="btn btn-primary" style={{ padding:".9rem 2.5rem", fontSize:"1rem" }}>
            {ar?"جرّب لوحة التحكم أون لاين ▶":"Try Admin Dashboard Online ▶"}
          </a>
        </div>
      </div>
    </section>
  );
}
