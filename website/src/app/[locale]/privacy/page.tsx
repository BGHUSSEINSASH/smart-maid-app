import Navbar from "../../../components/layout/Navbar";
import Footer from "../../../components/layout/Footer";
import LegalContent from "../../../components/sections/LegalContent";

export const metadata = {
  title: "سياسة الخصوصية | Privacy Policy — شغّالتي",
  description: "كيف نجمع بياناتك ونستخدمها ونحذفها.",
};

export default async function PrivacyPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  return (
    <>
      <Navbar />
      <div style={{ paddingTop: "5rem", minHeight: "100dvh" }}>
        <LegalContent kind="privacy" locale={locale} />
      </div>
      <Footer />
    </>
  );
}
