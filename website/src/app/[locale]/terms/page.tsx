import Navbar from "../../../components/layout/Navbar";
import Footer from "../../../components/layout/Footer";
import LegalContent from "../../../components/sections/LegalContent";

export const metadata = {
  title: "الشروط والأحكام | Terms — شغّالتي",
  description: "شروط استخدام تطبيق شغّالتي.",
};

export default async function TermsPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  return (
    <>
      <Navbar />
      <div style={{ paddingTop: "5rem", minHeight: "100dvh" }}>
        <LegalContent kind="terms" locale={locale} />
      </div>
      <Footer />
    </>
  );
}
