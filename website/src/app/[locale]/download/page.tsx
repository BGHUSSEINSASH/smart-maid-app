import Navbar from "../../../components/layout/Navbar";
import Footer from "../../../components/layout/Footer";
import DownloadSection from "../../../components/sections/DownloadSection";

export default function DownloadPage() {
  return (
    <>
      <Navbar />
      <div style={{ paddingTop:"5rem", minHeight:"100dvh" }}>
        <DownloadSection />
      </div>
      <Footer />
    </>
  );
}
