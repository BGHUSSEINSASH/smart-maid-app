"use client";
import { useState, useEffect } from "react";
import { useLocale } from "next-intl";
import { useTheme } from "../../lib/theme";

export default function Navbar() {
  const locale = useLocale();
  const { theme, toggle } = useTheme();
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);
  const ar = locale === "ar";

  useEffect(() => {
    const h = () => setScrolled(window.scrollY > 24);
    window.addEventListener("scroll", h, { passive: true });
    return () => window.removeEventListener("scroll", h);
  }, []);

  const links = ar
    ? [["الرئيسية","#hero"],["المميزات","#features"],["للشركات","#control"],["للعاملات",`/${locale}/workers`],["الأسعار","#pricing"],["تحميل","#download"]]
    : [["Home","#hero"],["Features","#features"],["Business","#control"],["For Maids",`/${locale}/workers`],["Pricing","#pricing"],["Download","#download"]];

  const navBg = scrolled ? "rgba(255,255,255,.94)" : "transparent";
  const navBorder = scrolled ? "1px solid var(--border)" : "1px solid transparent";

  return (
    <header style={{ position:"fixed", top:0, inset:"0 0 auto 0", zIndex:999, background:navBg, backdropFilter:scrolled?"blur(24px)":"none", borderBottom:navBorder, boxShadow:scrolled?"var(--shadow-md)":"none", transition:"all .3s ease" }}>
      <nav className="mx" style={{ height:68, display:"flex", alignItems:"center", gap:24 }}>
        {/* Logo */}
        <a href={`/${locale}#hero`} style={{ textDecoration:"none", color:"inherit", display:"flex", alignItems:"center", gap:10, fontWeight:900 }}>
          <img src="/logo.png" width={38} height={38} alt="شغّالتي"
            style={{ borderRadius:10, boxShadow:"0 2px 10px rgba(3,5,90,.2)" }} />
          <span style={{ fontSize:"1.1rem", color:scrolled?"var(--gray-900)":"#fff", fontWeight:900 }}>
            {ar ? "شغّالتي" : "Shaghalti"}
          </span>
        </a>

        {/* Desktop links */}
        <div className="hide-mobile" style={{ display:"flex", alignItems:"center", gap:2, marginInlineStart:"auto" }}>
          {links.map(([label, href]) => {
            const isExternal = href.startsWith('/');
            return (
              <a key={href} href={isExternal ? href : href} style={{ padding:".5rem 1rem", borderRadius:10, fontSize:".875rem", fontWeight:600, color:scrolled?"var(--gray-500)":"rgba(255,255,255,.82)", textDecoration:"none", transition:"color .15s, background .15s", whiteSpace:"nowrap" }}
                onMouseEnter={e=>{(e.currentTarget as HTMLAnchorElement).style.color=scrolled?"var(--indigo)":"#fff";(e.currentTarget as HTMLAnchorElement).style.background=scrolled?"var(--indigo-l)":"rgba(255,255,255,.1)";}}
                onMouseLeave={e=>{(e.currentTarget as HTMLAnchorElement).style.color=scrolled?"var(--gray-500)":"rgba(255,255,255,.82)";(e.currentTarget as HTMLAnchorElement).style.background="transparent";}}>
                {label}
              </a>
            );
          })}
        </div>

        {/* Controls */}
        <div style={{ display:"flex", alignItems:"center", gap:8, marginInlineStart: "auto" }}>
          {/* Try App */}
          <a href={`/${locale}/app-demo`} className="hide-mobile" style={{ display:"inline-flex", alignItems:"center", gap:6, padding:".55rem 1.1rem", borderRadius:10, fontSize:".82rem", fontWeight:800, background:scrolled?"rgba(79,70,229,.1)":"rgba(255,255,255,.12)", color:scrolled?"var(--indigo)":"rgba(255,255,255,.9)", textDecoration:"none", border:scrolled?"1px solid rgba(79,70,229,.25)":"1px solid rgba(255,255,255,.2)", transition:"all .2s" }}
            onMouseEnter={e=>{(e.currentTarget as HTMLAnchorElement).style.background=scrolled?"rgba(79,70,229,.18)":"rgba(255,255,255,.2)";}}
            onMouseLeave={e=>{(e.currentTarget as HTMLAnchorElement).style.background=scrolled?"rgba(79,70,229,.1)":"rgba(255,255,255,.12)";}}>
            ▶ {ar?"جرّب":"Try Live"}
          </a>

          {/* Theme */}
          <button onClick={toggle} style={{ width:36, height:36, borderRadius:10, border:scrolled?"1px solid var(--border)":"1px solid rgba(255,255,255,.2)", background:scrolled?"var(--gray-50)":"rgba(255,255,255,.1)", cursor:"pointer", fontSize:16, display:"flex", alignItems:"center", justifyContent:"center", color:scrolled?"var(--gray-700)":"#fff", transition:"all .2s" }}>
            {theme==="dark"?"☀️":"🌙"}
          </button>

          {/* Lang */}
          <a href={`/${ar?"en":"ar"}${typeof window!=="undefined"?window.location.hash:""}`} style={{ width:36, height:36, borderRadius:10, border:scrolled?"1px solid var(--border)":"1px solid rgba(255,255,255,.2)", background:scrolled?"var(--gray-50)":"rgba(255,255,255,.1)", display:"flex", alignItems:"center", justifyContent:"center", fontSize:".78rem", fontWeight:800, color:scrolled?"var(--gray-700)":"#fff", textDecoration:"none", transition:"all .2s" }}>
            {ar?"EN":"ع"}
          </a>

          {/* CTA */}
          <a href="#download" className="btn btn-primary hide-mobile" style={{ padding:".62rem 1.4rem", fontSize:".85rem" }}>
            {ar?"⬇ تحميل":"⬇ Download"}
          </a>

          {/* Burger */}
          <button className="show-mobile" onClick={()=>setOpen(!open)} style={{ width:36, height:36, borderRadius:10, border:`1px solid ${scrolled?"var(--border)":"rgba(255,255,255,.2)"}`, background:scrolled?"var(--gray-50)":"rgba(255,255,255,.1)", cursor:"pointer", fontSize:18, color:scrolled?"var(--gray-700)":"#fff", alignItems:"center", justifyContent:"center" }}>
            {open?"✕":"☰"}
          </button>
        </div>
      </nav>

      {/* Mobile menu */}
      {open && (
        <div style={{ background:"var(--bg)", borderTop:"1px solid var(--border)", padding:"1rem var(--px)", display:"flex", flexDirection:"column", gap:4 }}>
          {links.map(([label, href]) => (
            <a key={href} href={href} onClick={()=>setOpen(false)} style={{ padding:".75rem 1rem", borderRadius:10, fontWeight:600, fontSize:".95rem", color:"var(--text)", textDecoration:"none", transition:"background .15s" }}
              onMouseEnter={e=>(e.currentTarget as HTMLAnchorElement).style.background="var(--indigo-l)"}
              onMouseLeave={e=>(e.currentTarget as HTMLAnchorElement).style.background="transparent"}>
              {label}
            </a>
          ))}
          <a href={`/${locale}/app-demo`} onClick={()=>setOpen(false)} style={{ padding:".75rem 1rem", borderRadius:10, fontWeight:700, fontSize:".95rem", color:"var(--indigo)", background:"var(--indigo-l)", textDecoration:"none", textAlign:"center" }}>
            ▶ {ar?"جرّب التطبيق":"Try App Online"}
          </a>
          <a href="#download" className="btn btn-primary" style={{ marginTop:8, justifyContent:"center" }}>
            {ar?"تحميل التطبيق":"Download App"}
          </a>
        </div>
      )}
    </header>
  );
}
