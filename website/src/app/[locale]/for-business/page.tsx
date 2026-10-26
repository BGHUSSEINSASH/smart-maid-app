import Navbar from "../../../components/layout/Navbar";
import Footer from "../../../components/layout/Footer";
import PricingSection from "../../../components/sections/PricingSection";
import ControlSection from "../../../components/sections/ControlSection";
import RolesSection from "../../../components/sections/RolesSection";

export default function BusinessPage() {
  return (
    <>
      <Navbar />
      <div style={{ paddingTop:"5rem" }}>
        <div className="mx section" style={{ textAlign:"center" }}>
          <span className="badge badge-brand" style={{ marginBottom:"1rem", display:"inline-flex" }}>
            <span className="pulse" /> للشركات
          </span>
          <h1 className="t-h1" style={{ color:"var(--text)", marginBottom:".75rem" }}>نمِّ أعمالك مع SmartMaid</h1>
          <p className="t-lead" style={{ maxWidth:520, marginInline:"auto" }}>
            لوحة تحكم متكاملة — KPIs حقيقية، إسناد طلبات، فواتير PDF، وتحكم كامل في الفريق
          </p>
        </div>
        <ControlSection />
        <RolesSection />
        <PricingSection />
      </div>
      <Footer />
    </>
  );
}
