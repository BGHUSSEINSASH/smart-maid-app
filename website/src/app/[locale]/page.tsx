import Navbar from "../../components/layout/Navbar";
import Footer from "../../components/layout/Footer";
import HeroSection from "../../components/sections/HeroSection";
import FeaturesSection from "../../components/sections/FeaturesSection";
import HowItWorksSection from "../../components/sections/HowItWorksSection";
import RolesSection from "../../components/sections/RolesSection";
import SecuritySection from "../../components/sections/SecuritySection";
import DownloadSection from "../../components/sections/DownloadSection";

export default function HomePage() {
  return (
    <>
      <Navbar />
      <HeroSection />
      <FeaturesSection />
      <HowItWorksSection />
      <RolesSection />
      <SecuritySection />
      <DownloadSection />
      <Footer />
    </>
  );
}
