import Navbar from "../../components/layout/Navbar";
import Footer from "../../components/layout/Footer";
import HeroSection from "../../components/sections/HeroSection";
import FeaturesSection from "../../components/sections/FeaturesSection";
import VoiceSearchSection from "../../components/sections/VoiceSearchSection";
import HowItWorksSection from "../../components/sections/HowItWorksSection";
import RolesSection from "../../components/sections/RolesSection";
import AdminControlSection from "../../components/sections/AdminControlSection";
import ControlSection from "../../components/sections/ControlSection";
import SecuritySection from "../../components/sections/SecuritySection";
import TestimonialsSection from "../../components/sections/TestimonialsSection";
import PricingSection from "../../components/sections/PricingSection";
import DownloadSection from "../../components/sections/DownloadSection";

export default function HomePage() {
  return (
    <>
      <Navbar />
      <HeroSection />
      {/* Payment partners strip */}
      <div style={{ borderBottom:"1px solid var(--border)", borderTop:"1px solid var(--border)", padding:"1.25rem 0", overflow:"hidden", background:"var(--bg)" }}>
        <div className="mx" style={{ display:"flex", alignItems:"center", justifyContent:"center", gap:"2.5rem", flexWrap:"wrap" }}>
          {["Visa","Mastercard","Apple Pay","Google Pay","Stripe","Tamara","Tabby","STC Pay"].map(b => (
            <span key={b} style={{ fontSize:".82rem", fontWeight:700, color:"var(--text-3)", letterSpacing:".05em", whiteSpace:"nowrap" }}>{b}</span>
          ))}
        </div>
      </div>
      <FeaturesSection />
      <VoiceSearchSection />
      <HowItWorksSection />
      <RolesSection />
      <AdminControlSection />
      <ControlSection />
      <SecuritySection />
      <TestimonialsSection />
      <PricingSection />
      <DownloadSection />
      <Footer />
    </>
  );
}
