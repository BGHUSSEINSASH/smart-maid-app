import Navbar from "../../../components/layout/Navbar";
import Footer from "../../../components/layout/Footer";
import FeaturesSection from "../../../components/sections/FeaturesSection";
import HowItWorksSection from "../../../components/sections/HowItWorksSection";
import SecuritySection from "../../../components/sections/SecuritySection";

export default function FeaturesPage() {
  return (
    <>
      <Navbar />
      <div style={{ paddingTop:"5rem" }}>
        <div className="mx section-sm" style={{ textAlign:"center" }}>
          <span className="badge badge-brand" style={{ marginBottom:"1rem", display:"inline-flex" }}>
            <span className="pulse" /> المميزات
          </span>
          <h1 className="t-h1" style={{ color:"var(--text)", marginBottom:".75rem" }}>مميزات تصنع الفرق</h1>
          <p className="t-lead" style={{ maxWidth:500, marginInline:"auto" }}>
            من GPS والعناوين إلى Escrow والاشتراكات — كل ما تحتاجه لتجربة منزلية استثنائية
          </p>
        </div>
        <FeaturesSection />
        <HowItWorksSection />
        <SecuritySection />
      </div>
      <Footer />
    </>
  );
}
