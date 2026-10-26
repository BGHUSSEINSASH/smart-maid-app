import Navbar from "../../../components/layout/Navbar";
import Footer from "../../../components/layout/Footer";

export default function WorkersPage({ params }: { params: Promise<{ locale: string }> }) {
  return (
    <>
      <Navbar />
      <WorkersContent />
      <Footer />
    </>
  );
}

function WorkersContent() {
  return (
    <div style={{ paddingTop:"4.5rem" }}>
      {/* Hero */}
      <section style={{ background:"linear-gradient(160deg,#0B0918 0%,#1C1640 50%,#0d1426 100%)", minHeight:"60vh", display:"flex", alignItems:"center", padding:"clamp(5rem,10vw,8rem) 0 clamp(4rem,8vw,6rem)", position:"relative", overflow:"hidden" }}>
        <div style={{ position:"absolute", inset:0, backgroundImage:"radial-gradient(circle, rgba(79,70,229,.15) 1px, transparent 1px)", backgroundSize:"28px 28px", opacity:.5 }} />
        <div style={{ position:"absolute", width:500, height:500, borderRadius:"50%", background:"rgba(6,182,212,.15)", filter:"blur(100px)", top:"50%", left:"50%", transform:"translate(-50%,-50%)" }} />
        <div className="mx" style={{ position:"relative", zIndex:2 }}>
          <div style={{ maxWidth:640, marginInline:"auto", textAlign:"center", display:"flex", flexDirection:"column", gap:"1.5rem" }}>
            <span className="badge badge-dark" style={{ alignSelf:"center" }}>
              <span className="pulse" style={{ background:"#a5f3fc" }} /> للعاملات
            </span>
            <h1 className="t-hero" style={{ color:"#fff" }}>
              انضمي لأكبر منصة<br />
              <span style={{ background:"linear-gradient(135deg,#818cf8,#67e8f9)", WebkitBackgroundClip:"text", WebkitTextFillColor:"transparent", backgroundClip:"text" }}>خدمات منزلية</span>
            </h1>
            <p style={{ color:"rgba(255,255,255,.65)", fontSize:"1.1rem", lineHeight:1.75 }}>
              آلاف العاملات يكسبن دخلاً ثابتاً مع مرونة كاملة في الجدول والطلبات.
              80% من كل حجز — مباشرة لحسابك البنكي.
            </p>
            <div style={{ display:"flex", gap:12, flexWrap:"wrap", justifyContent:"center" }}>
              <a href={`/ar/register/worker`} className="btn btn-primary" style={{ padding:".9rem 2rem", fontSize:"1rem" }}>
                سجّلي كعاملة الآن ←
              </a>
              <a href="/ar/app-demo" className="btn btn-dark" style={{ padding:".9rem 2rem", fontSize:"1rem" }}>
                ▶ جرّب التطبيق
              </a>
            </div>
            {/* Earning stat */}
            <div style={{ background:"rgba(255,255,255,.07)", borderRadius:16, padding:"1rem 1.5rem", border:"1px solid rgba(255,255,255,.1)", display:"inline-flex", alignItems:"center", gap:16, alignSelf:"center" }}>
              <div style={{ textAlign:"center" }}>
                <div style={{ fontSize:"2rem", fontWeight:900, color:"#a5f3fc" }}>$1,200+</div>
                <div style={{ fontSize:".78rem", color:"rgba(255,255,255,.5)" }}>متوسط الدخل الشهري</div>
              </div>
              <div style={{ width:1, height:40, background:"rgba(255,255,255,.15)" }} />
              <div style={{ textAlign:"center" }}>
                <div style={{ fontSize:"2rem", fontWeight:900, color:"#a5f3fc" }}>80%</div>
                <div style={{ fontSize:".78rem", color:"rgba(255,255,255,.5)" }}>من كل حجز لك</div>
              </div>
              <div style={{ width:1, height:40, background:"rgba(255,255,255,.15)" }} />
              <div style={{ textAlign:"center" }}>
                <div style={{ fontSize:"2rem", fontWeight:900, color:"#a5f3fc" }}>24h</div>
                <div style={{ fontSize:".78rem", color:"rgba(255,255,255,.5)" }}>مراجعة KYC</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Steps */}
      <section className="section" style={{ background:"var(--bg)" }}>
        <div className="mx">
          <div style={{ textAlign:"center", marginBottom:"clamp(2.5rem,5vw,4rem)" }}>
            <h2 className="t-h1" style={{ color:"var(--text)", marginBottom:".75rem" }}>كيف تبدئين؟</h2>
            <p className="t-lead" style={{ maxWidth:480, marginInline:"auto" }}>أربع خطوات بسيطة للانضمام وبدء الكسب</p>
          </div>
          <div style={{ display:"grid", gridTemplateColumns:"repeat(4,1fr)", gap:"1.5rem" }} className="worker-steps">
            <style>{`.worker-steps{@media(max-width:900px){grid-template-columns:repeat(2,1fr)!important}@media(max-width:520px){grid-template-columns:1fr!important}}`}</style>
            {[
              { n:"1", i:"📝", t:"سجّلي بياناتك", d:"الاسم، جواز السفر، مهاراتك في 3 خطوات بسيطة" },
              { n:"2", i:"✅", t:"توثيق KYC", d:"ارفعي مستنداتك وانتظري الموافقة خلال 24 ساعة" },
              { n:"3", i:"📅", t:"استلمي الطلبات", d:"قبولي أو رفضي الطلبات وأديري جدولك بحرية تامة" },
              { n:"4", i:"💰", t:"اجمعي أرباحك", d:"80% من كل حجز تُحوَّل لحسابك البنكي مباشرة" },
            ].map((s,i) => (
              <div key={i} className="card" style={{ padding:"1.75rem 1.5rem", textAlign:"center" }}>
                <div style={{ width:52, height:52, borderRadius:16, margin:"0 auto 1rem", background:"linear-gradient(135deg,var(--indigo),var(--cyan))", display:"flex", alignItems:"center", justifyContent:"center", fontSize:22, boxShadow:"var(--shadow-brand)" }}>{s.i}</div>
                <div style={{ fontSize:"2.2rem", fontWeight:900, background:"linear-gradient(135deg,var(--indigo-m),var(--cyan-m))", WebkitBackgroundClip:"text", WebkitTextFillColor:"transparent", backgroundClip:"text", opacity:.6, marginBottom:".5rem" }}>{s.n}</div>
                <h3 style={{ fontSize:"1rem", fontWeight:800, color:"var(--text)", marginBottom:".5rem" }}>{s.t}</h3>
                <p style={{ fontSize:".83rem", color:"var(--text-2)", lineHeight:1.65 }}>{s.d}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Benefits */}
      <section className="section" style={{ background:"var(--bg-alt)" }}>
        <div className="divider" style={{ position:"absolute", top:0, left:0, right:0 }} />
        <div className="mx">
          <h2 className="t-h1" style={{ color:"var(--text)", marginBottom:"2.5rem", textAlign:"center" }}>مزايا الانضمام</h2>
          <div style={{ display:"grid", gridTemplateColumns:"repeat(2,1fr)", gap:"1.25rem" }} className="worker-benefits">
            <style>{`.worker-benefits{@media(max-width:640px){grid-template-columns:1fr!important}}`}</style>
            {[
              { icon:"💰", t:"80% من كل حجز", d:"الحصة الأعلى في السوق — المال يصلك مباشرة بعد إتمام الخدمة" },
              { icon:"📅", t:"حرية الجدول الكاملة", d:"اقبلي أو ارفضي أي طلب — أنتِ من تتحكم في وقتك" },
              { icon:"📍", t:"تحديد نطاق العمل", d:"حددي المناطق والمسافة التي تريدين العمل ضمنها" },
              { icon:"⭐", t:"بناء سمعة احترافية", d:"التقييمات تبني ملفك المهني وتجلب طلبات أكثر" },
              { icon:"🛡️", t:"حماية كاملة", d:"عمليات موثّقة، دفع مضمون، ودعم في أي مشكلة" },
              { icon:"📱", t:"تطبيق سهل الاستخدام", d:"جدول أسبوعي، إشعارات فورية، سجل كامل للأرباح" },
            ].map((b,i) => (
              <div key={i} className="card" style={{ padding:"1.5rem", display:"flex", alignItems:"flex-start", gap:"1rem" }}>
                <div style={{ width:46, height:46, borderRadius:12, background:"var(--indigo-l)", display:"flex", alignItems:"center", justifyContent:"center", fontSize:"1.3rem", flexShrink:0 }}>{b.icon}</div>
                <div>
                  <h3 style={{ fontSize:".95rem", fontWeight:800, color:"var(--text)", marginBottom:".35rem" }}>{b.t}</h3>
                  <p style={{ fontSize:".82rem", color:"var(--text-2)", lineHeight:1.6 }}>{b.d}</p>
                </div>
              </div>
            ))}
          </div>
          <div style={{ textAlign:"center", marginTop:"3rem" }}>
            <a href="/ar/register/worker" className="btn btn-primary" style={{ padding:".9rem 2.5rem", fontSize:"1rem" }}>
              سجّلي الآن وابدئي الكسب ←
            </a>
          </div>
        </div>
      </section>
    </div>
  );
}
