"use client";
import { useLocale } from "next-intl";
import { useState } from "react";

export default function AppDemoPage() {
  const locale = useLocale();
  const ar = locale === "ar";
  const [loaded, setLoaded] = useState(false);
  const [view, setView] = useState<"mobile" | "tablet" | "fullscreen">("mobile");

  const sizes = {
    mobile:     { w: 393,  h: 852,  label: ar ? "📱 هاتف"  : "📱 Phone"  },
    tablet:     { w: 768,  h: 1024, label: ar ? "📟 تابلت" : "📟 Tablet" },
    fullscreen: { w: 0,    h: 0,    label: ar ? "🖥️ ملء الشاشة" : "🖥️ Fullscreen" },
  };

  // ── وضع ملء الشاشة ─────────────────────────────────────────────────
  if (view === "fullscreen") {
    return (
      <div style={{ width:"100vw", height:"100dvh", display:"flex", flexDirection:"column", background:"#02021E" }}>
        <div style={{
          height: 50,
          background: "rgba(3,4,90,.95)",
          borderBottom: "1px solid rgba(255,255,255,.08)",
          display: "flex", alignItems: "center",
          paddingInline: 20, gap: 14, flexShrink: 0,
          backdropFilter: "blur(20px)",
        }}>
          {/* شعار */}
          <div style={{ display:"flex", alignItems:"center", gap:10 }}>
            <img src="/icon-192.png" alt="شغّالتي" width={30} height={30}
              style={{ borderRadius:8 }} />
            <span style={{ fontWeight:900, color:"#fff", fontSize:"1rem" }}>
              {ar ? "شغّالتي" : "Shaghalti"}
            </span>
            <span style={{
              background:"rgba(6,182,212,.18)", border:"1px solid rgba(6,182,212,.35)",
              color:"#67e8f9", fontSize:".68rem", fontWeight:700,
              padding:".2rem .6rem", borderRadius:99
            }}>
              {ar ? "نسخة تجريبية" : "Demo"}
            </span>
          </div>

          <div style={{ marginInlineStart:"auto", display:"flex", gap:8 }}>
            {(["mobile","tablet"] as const).map(v => (
              <button key={v} onClick={() => setView(v)} style={{
                padding:".3rem .8rem", borderRadius:8,
                border:"1px solid rgba(255,255,255,.15)",
                background:"transparent", color:"rgba(255,255,255,.6)",
                cursor:"pointer", fontSize:".78rem", fontWeight:600,
              }}>{sizes[v].label}</button>
            ))}
            <a href={`/${locale}`} style={{
              padding:".3rem .8rem", borderRadius:8,
              border:"1px solid rgba(255,255,255,.15)",
              color:"rgba(255,255,255,.5)", textDecoration:"none",
              fontSize:".78rem", display:"flex", alignItems:"center", gap:4,
            }}>
              {ar ? "← العودة" : "← Back"}
            </a>
          </div>
        </div>
        <iframe
          src="/app/index.html"
          style={{ flex:1, border:"none", width:"100%", height:"100%" }}
          onLoad={() => setLoaded(true)}
          allow="camera; microphone; geolocation; clipboard-write"
          title="شغّالتي App"
        />
      </div>
    );
  }

  const sz = sizes[view];

  return (
    <div style={{
      minHeight:"100dvh",
      background:"linear-gradient(160deg, #02021E 0%, #03045A 50%, #02021E 100%)",
      position:"relative", overflow:"hidden",
      fontFamily:"Cairo, Sora, sans-serif",
    }}>
      {/* خلفية نقاط */}
      <div style={{
        position:"absolute", inset:0,
        backgroundImage:"radial-gradient(circle, rgba(3,83,164,.18) 1px, transparent 1px)",
        backgroundSize:"30px 30px", pointerEvents:"none",
      }} />

      {/* توهّج خلفي */}
      <div style={{
        position:"absolute", width:600, height:600, borderRadius:"50%",
        background:"rgba(3,83,164,.22)", filter:"blur(120px)",
        top:"25%", left:"50%", transform:"translateX(-50%)", pointerEvents:"none",
      }} />
      <div style={{
        position:"absolute", width:300, height:300, borderRadius:"50%",
        background:"rgba(3,62,138,.18)", filter:"blur(80px)",
        top:"5%", right:"8%", pointerEvents:"none",
      }} />

      {/* ── شريط التنقل ──────────────────────────────────────────── */}
      <div style={{
        position:"sticky", top:0, zIndex:50,
        backdropFilter:"blur(20px)",
        background:"rgba(2,2,30,.85)",
        borderBottom:"1px solid rgba(255,255,255,.07)",
        padding:".7rem 0",
      }}>
        <div style={{
          maxWidth:1160, marginInline:"auto",
          paddingInline:"clamp(1rem,5vw,2.5rem)",
          display:"flex", alignItems:"center", gap:14,
        }}>
          <a href={`/${locale}`} style={{
            display:"flex", alignItems:"center", gap:6,
            color:"rgba(255,255,255,.65)", textDecoration:"none",
            fontSize:".875rem", fontWeight:600,
          }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" strokeWidth="2.5">
              <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
            {ar ? "العودة" : "Back"}
          </a>

          <div style={{ width:1, height:20, background:"rgba(255,255,255,.1)" }} />

          {/* شعار شغّالتي */}
          <div style={{ display:"flex", alignItems:"center", gap:10 }}>
            <img src="/logo.png" alt="شغّالتي" width={34} height={34}
              style={{ borderRadius:10, boxShadow:"0 4px 12px rgba(3,5,90,.3)" }} />
            <div>
              <div style={{ fontWeight:900, color:"#fff", fontSize:".95rem", lineHeight:1 }}>
                {ar ? "شغّالتي" : "Shaghalti"}
              </div>
              <div style={{ fontSize:".65rem", color:"rgba(255,255,255,.4)", lineHeight:1.2 }}>
                SmartMaid
              </div>
            </div>
            <span style={{
              background:"rgba(6,182,212,.18)", border:"1px solid rgba(6,182,212,.3)",
              color:"#67e8f9", fontSize:".68rem", fontWeight:700,
              padding:".2rem .55rem", borderRadius:99,
            }}>
              {ar ? "تجريبي" : "Demo"}
            </span>
          </div>

          {/* مبدّل العرض */}
          <div style={{ marginInlineStart:"auto", display:"flex", gap:6 }}>
            {(["mobile","tablet","fullscreen"] as const).map(v => (
              <button key={v} onClick={() => setView(v)} style={{
                padding:".38rem .85rem", borderRadius:10,
                fontSize:".78rem", fontWeight:700, cursor:"pointer",
                transition:"all .2s",
                background: view===v ? "rgba(3,83,164,.35)" : "transparent",
                border: `1px solid ${view===v ? "rgba(3,83,164,.55)" : "rgba(255,255,255,.1)"}`,
                color: view===v ? "#93c5fd" : "rgba(255,255,255,.45)",
              }}>{sizes[v].label}</button>
            ))}
          </div>
        </div>
      </div>

      {/* ── المحتوى الرئيسي ──────────────────────────────────────── */}
      <div style={{
        display:"flex", flexDirection:"column", alignItems:"center",
        padding:"clamp(2rem,5vw,4rem) clamp(1rem,4vw,2rem)",
        position:"relative", zIndex:2,
      }}>

        {/* ── العنوان ────────────────────────────────────────────── */}
        <div style={{ textAlign:"center", marginBottom:"2.5rem" }}>
          {/* شعار كبير */}
          <div style={{ display:"flex", justifyContent:"center", marginBottom:20 }}>
            <div style={{ position:"relative" }}>
              <img src="/icon-192.png" alt="شغّالتي" width={80} height={80}
                style={{
                  borderRadius:22,
                  boxShadow:"0 20px 50px rgba(3,5,90,.6), 0 0 0 1px rgba(255,255,255,.08)",
                }} />
              <div style={{
                position:"absolute", inset:-1,
                borderRadius:22, border:"1px solid rgba(255,255,255,.15)",
                pointerEvents:"none",
              }} />
            </div>
          </div>

          <h1 style={{
            fontSize:"clamp(1.8rem,4vw,3rem)", fontWeight:900,
            color:"#fff", marginBottom:".75rem", letterSpacing:"-.03em",
          }}>
            {ar
              ? <>جرّب <span style={{
                  background:"linear-gradient(135deg,#60a5fa,#93c5fd)",
                  WebkitBackgroundClip:"text", WebkitTextFillColor:"transparent",
                  backgroundClip:"text",
                }}>شغّالتي</span> الآن</>
              : <>Try <span style={{
                  background:"linear-gradient(135deg,#60a5fa,#93c5fd)",
                  WebkitBackgroundClip:"text", WebkitTextFillColor:"transparent",
                  backgroundClip:"text",
                }}>Shaghalti</span> Now</>
            }
          </h1>

          <p style={{
            color:"rgba(255,255,255,.55)", fontSize:"1rem",
            maxWidth:520, marginInline:"auto", lineHeight:1.75,
          }}>
            {ar
              ? "جرّب التطبيق كاملاً مباشرة من متصفحك — بحث ذكي، حجز، إدارة، بدون تحميل"
              : "Try the full app from your browser — AI search, booking, admin panel, no download needed"}
          </p>

          {/* تلميح الحسابات */}
          <div style={{
            display:"inline-flex", alignItems:"center", gap:8, marginTop:"1rem",
            padding:".5rem 1.2rem", borderRadius:99,
            background:"rgba(255,255,255,.06)", border:"1px solid rgba(255,255,255,.1)",
            fontSize:".78rem", color:"rgba(255,255,255,.5)",
          }}>
            💡 {ar ? "اضغط 'دخول سريع' داخل التطبيق" : "Tap 'Quick Login' inside the app"}
          </div>
        </div>

        {/* ── إطار الجهاز ─────────────────────────────────────── */}
        <div style={{ position:"relative" }}>
          {/* الإطار الخارجي */}
          <div style={{
            width: sz.w + 28,
            borderRadius: view==="mobile" ? 54 : 28,
            background:"linear-gradient(160deg, #1a1535, #0d0b24)",
            padding: view==="mobile" ? "14px" : "10px",
            boxShadow:[
              "0 40px 120px rgba(0,0,0,.75)",
              "0 0 0 1px rgba(255,255,255,.07) inset",
              "0 0 100px rgba(3,83,164,.25)",
            ].join(","),
            position:"relative",
          }}>
            {/* notch للهاتف */}
            {view==="mobile" && (
              <>
                <div style={{
                  position:"absolute", top:24, left:"50%",
                  transform:"translateX(-50%)",
                  width:110, height:6,
                  background:"rgba(255,255,255,.1)", borderRadius:99, zIndex:10,
                }} />
                <div style={{
                  position:"absolute", bottom:16, left:"50%",
                  transform:"translateX(-50%)",
                  width:130, height:4,
                  background:"rgba(255,255,255,.18)", borderRadius:99, zIndex:10,
                }} />
              </>
            )}

            {/* الشاشة */}
            <div style={{
              width:sz.w, height:sz.h,
              borderRadius: view==="mobile" ? 42 : 20,
              overflow:"hidden", position:"relative",
              background:"#02021E",
            }}>
              {/* شاشة تحميل */}
              {!loaded && (
                <div style={{
                  position:"absolute", inset:0, zIndex:20,
                  display:"flex", flexDirection:"column",
                  alignItems:"center", justifyContent:"center",
                  background:"linear-gradient(160deg,#02021E,#03045A)",
                }}>
                  <img src="/icon-192.png" alt="" width={72} height={72}
                    style={{
                      borderRadius:20, marginBottom:20,
                      boxShadow:"0 12px 40px rgba(3,5,90,.5)",
                      animation:"iconPulse 1.8s ease-in-out infinite",
                    }} />
                  <div style={{ fontSize:"1rem", fontWeight:700, color:"rgba(255,255,255,.8)", marginBottom:6 }}>
                    {ar ? "شغّالتي" : "Shaghalti"}
                  </div>
                  <div style={{ fontSize:".82rem", color:"rgba(255,255,255,.45)", marginBottom:20 }}>
                    {ar ? "جارٍ تحميل التطبيق..." : "Loading app..."}
                  </div>
                  <div style={{
                    width:140, height:3, borderRadius:99,
                    background:"rgba(255,255,255,.1)", overflow:"hidden",
                  }}>
                    <div style={{
                      height:"100%", borderRadius:99,
                      background:"linear-gradient(90deg,#03045A,#0353A4,#03045A)",
                      backgroundSize:"200% 100%",
                      animation:"loadShimmer 1.4s ease-in-out infinite",
                    }} />
                  </div>
                </div>
              )}

              <iframe
                src="/app/index.html"
                style={{ width:"100%", height:"100%", border:"none", display:"block" }}
                onLoad={() => setLoaded(true)}
                allow="camera; microphone; geolocation; clipboard-write"
                title={ar ? "شغّالتي" : "Shaghalti App"}
              />
            </div>
          </div>

          {/* توهّج تحت الجهاز */}
          <div style={{
            position:"absolute", bottom:-50, left:"50%",
            transform:"translateX(-50%)",
            width:"75%", height:70,
            background:"rgba(3,83,164,.4)",
            filter:"blur(35px)", borderRadius:"50%",
            pointerEvents:"none",
          }} />
        </div>

        {/* ── حسابات الدخول ────────────────────────────────────── */}
        <div style={{ marginTop:"3rem" }}>
          <p style={{
            textAlign:"center", color:"rgba(255,255,255,.35)",
            fontSize:".82rem", marginBottom:"1rem",
          }}>
            {ar ? "🔑 حسابات تجريبية" : "🔑 Demo Accounts"}
          </p>
          <div style={{ display:"flex", flexWrap:"wrap", justifyContent:"center", gap:12 }}>
            {[
              { role: ar ? "👤 عميل"   : "👤 Customer", color:"#3B82F6", hint: ar ? "حجز خدمات" : "Book services" },
              { role: ar ? "👩 عاملة"  : "👩 Maid",     color:"#8B5CF6", hint: ar ? "إدارة جدول" : "Manage schedule" },
              { role: ar ? "🏢 شركة"   : "🏢 Company",  color:"#06B6D4", hint: ar ? "لوحة تحكم" : "Dashboard" },
              { role: ar ? "🛡️ إدارة"  : "🛡️ Admin",    color:"#10B981", hint: ar ? "تحكم كامل" : "Full control" },
            ].map(item => (
              <div key={item.role} style={{
                padding:".7rem 1.3rem", borderRadius:14,
                background:"rgba(255,255,255,.04)",
                border:`1px solid ${item.color}30`,
                textAlign:"center", minWidth:110,
              }}>
                <div style={{ fontSize:".95rem", fontWeight:800, color:item.color, marginBottom:3 }}>
                  {item.role}
                </div>
                <div style={{ fontSize:".72rem", color:"rgba(255,255,255,.35)" }}>
                  {item.hint}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ── روابط التحميل ───────────────────────────────────── */}
        <div style={{ marginTop:"2.5rem", textAlign:"center" }}>
          <p style={{ color:"rgba(255,255,255,.3)", fontSize:".82rem", marginBottom:".9rem" }}>
            {ar ? "حمّل التطبيق على جهازك" : "Download the app on your device"}
          </p>
          <div style={{ display:"flex", justifyContent:"center", gap:10, flexWrap:"wrap" }}>
            <a
              href="https://github.com/BGHUSSEINSASH/smartmaid-app/releases/download/v1.0.0/SmartMaid-v1.0.0-arm64-NewLogo.apk"
              style={{
                display:"flex", alignItems:"center", gap:8,
                background:"#fff", color:"#03045A",
                padding:".7rem 1.5rem", borderRadius:12,
                fontWeight:800, textDecoration:"none", fontSize:".88rem",
                boxShadow:"0 8px 24px rgba(0,0,0,.3)",
              }}
            >
              <svg width="18" height="18" fill="#3DDC84" viewBox="0 0 24 24">
                <path d="M3.18 23.76A1 1 0 012 22.84V1.16A1 1 0 013.18.24l11.67 11.76-11.67 11.76z"/>
              </svg>
              {ar ? "Android APK" : "Android APK"}
            </a>
            <a
              href="https://github.com/BGHUSSEINSASH/smartmaid-app/releases/tag/v1.0.0"
              style={{
                display:"flex", alignItems:"center", gap:8,
                background:"rgba(255,255,255,.08)",
                border:"1px solid rgba(255,255,255,.15)",
                color:"#fff",
                padding:".7rem 1.5rem", borderRadius:12,
                fontWeight:800, textDecoration:"none", fontSize:".88rem",
              }}
            >
              <svg width="18" height="18" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 0C5.374 0 0 5.373 0 12c0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z"/>
              </svg>
              GitHub Releases
            </a>
          </div>
        </div>

        {/* ── مميزات سريعة ─────────────────────────────────────── */}
        <div style={{
          marginTop:"3rem",
          display:"grid",
          gridTemplateColumns:"repeat(auto-fit, minmax(160px, 1fr))",
          gap:12, maxWidth:700, width:"100%",
        }}>
          {[
            { icon:"🤖", title: ar?"بحث ذكي AI":"AI Smart Search"  },
            { icon:"🎤", title: ar?"بحث صوتي":"Voice Search"       },
            { icon:"📅", title: ar?"حجز سنوي":"Annual Booking"     },
            { icon:"💎", title: ar?"اشتراك Pro":"Pro Subscription"  },
            { icon:"🛡️", title: ar?"تحكم إداري":"Admin Control"    },
            { icon:"💳", title: ar?"دفع بالمحفظة":"Wallet Payment"   },
          ].map(f => (
            <div key={f.icon} style={{
              padding:".85rem", borderRadius:14,
              background:"rgba(255,255,255,.04)",
              border:"1px solid rgba(255,255,255,.07)",
              textAlign:"center",
            }}>
              <div style={{ fontSize:"1.4rem", marginBottom:6 }}>{f.icon}</div>
              <div style={{ fontSize:".8rem", fontWeight:700, color:"rgba(255,255,255,.7)" }}>
                {f.title}
              </div>
            </div>
          ))}
        </div>
      </div>

      <style>{`
        @keyframes loadShimmer {
          0%   { background-position: -200% 0 }
          100% { background-position:  200% 0 }
        }
        @keyframes iconPulse {
          0%,100% { opacity:1; transform:scale(1) }
          50%     { opacity:.75; transform:scale(.93) }
        }
      `}</style>
    </div>
  );
}
