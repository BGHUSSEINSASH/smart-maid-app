type Section = { h: string; p: string[] };

const updated = "2026-10-29";

const privacy: { ar: Section[]; en: Section[] } = {
  ar: [
    {
      h: "من نحن",
      p: [
        "شغّالتي (المشار إليها بـ«المنصة») تقدّم خدمة حجز خدمات منزلية (تنظيف، رعاية أطفال، طبخ) عبر تطبيق الهاتف. نحن مسؤولون عن البيانات التي تُجمع من خلال التطبيق والموقع.",
        "للتواصل بشأن الخصوصية أو لحذف حسابك: support@shaghalti.app",
      ],
    },
    {
      h: "البيانات التي نجمعها",
      p: [
        "بيانات الحساب: الاسم، البريد الإلكتروني، كلمة المرور (مُخزّنة مُشفّرة على الخادم)، رقم الهاتف إن أضفته، ونوع الحساب (عميل أو عاملة).",
        "بيانات الخدمة: العناوين التي تُدخلها، تفاصيل الحجز، المواعيد، الملاحظات، والرسائل التي تتبادلها مع الطرف الآخر داخل التطبيق.",
        "بيانات الدفع: لا نحتفظ ببيانات بطاقتك. عند تفعيل الدفع بالبطاقة تُعالَج البيانات لدى مزوّد الدفع المعتمد، ولا تصل إلينا. الدفع النقدي عند إتمام الخدمة لا يتطلب أي بيانات مالية.",
        "بيانات الاستخدام: سجلات الدخول والأخطاء اللازمة لتشغيل الخدمة وحمايتها.",
      ],
    },
    {
      h: "لماذا نجمعها",
      p: [
        "لإنشاء الحساب وتسجيل الدخول، وتنفيذ الحجز وإيصاله إلى العاملة، ولإدارة المحفظة والنقاط، وللتواصل بين الطرفين، ولحماية المنصة من إساءة الاستخدام، وللامتثال للالتزامات القانونية.",
      ],
    },
    {
      h: "مع من نشاركها",
      p: [
        "مع العاملة أو العميل الطرف في الحجز: الاسم ورقم الهاتف والعنوان وتفاصيل الحجز بالقدر اللازم لتنفيذ الخدمة.",
        "مع مزوّدي البنية التقنية الذين يستضيفون الخادم وقاعدة البيانات فقط، وبموجب اتفاقيات معالجة بيانات.",
        "مع مزوّد الدفع، فقط إذا اخترت الدفع بالبطاقة.",
        "لا نبيع بياناتك ولا نشاركها لأغراض إعلانية، ولا يوجد في التطبيق أي تتبّع إعلاني أو أدوات تحليلات طرف ثالث.",
      ],
    },
    {
      h: "مدة الاحتفاظ",
      p: [
        "نحتفظ ببيانات الحساب ما دام الحساب قائماً. عند حذف الحساب تُحذف بياناتك الشخصية وبيانات حجوزاتك ورسائلك ونقاطك خلال 30 يوماً، عدا ما يلزم الاحتفاظ به نظاماً (مثل سجلات الفواتير) للمدة التي يفرضها القانون.",
      ],
    },
    {
      h: "حذف الحساب",
      p: [
        "يمكنك حذف حسابك من داخل التطبيق: الإعدادات ← حذف الحساب. الحذف نهائي ويشمل البيانات المرتبطة بالحساب.",
        "وإذا تعذّر عليك الدخول، أرسل طلب الحذف من البريد المسجّل إلى support@shaghalti.app وسيُنفَّذ خلال 30 يوماً.",
      ],
    },
    {
      h: "الأطفال",
      p: [
        "الخدمة موجَّهة لمن هم في سن 18 عاماً أو أكثر. لا نجمع بيانات من هم دون 18 عاماً عن قصد.",
      ],
    },
    {
      h: "حقوقك",
      p: [
        "لك حق الوصول إلى بياناتك وتصحيحها وحذفها وسحب موافقتك. تواصل معنا على support@shaghalti.app وسنستجيب خلال 30 يوماً.",
      ],
    },
    {
      h: "الأمان",
      p: [
        "تُنقل البيانات عبر HTTPS، وكلمات المرور مُخزّنة مُشفّرة (bcrypt)، ويُخزَّن رمز الجلسة في التخزين الآمن للجهاز (Keychain / Keystore).",
      ],
    },
    {
      h: "التحديثات",
      p: [
        `آخر تحديث لهذه السياسة: ${updated}. عند إجراء تغيير جوهري سنُعلمك داخل التطبيق قبل نفاذه.`,
      ],
    },
  ],
  en: [
    {
      h: "Who we are",
      p: [
        "Shaghalti (“the Platform”) provides home-service booking (cleaning, childcare, cooking) through a mobile app. We are the controller of the data collected through the app and website.",
        "Privacy and deletion requests: support@shaghalti.app",
      ],
    },
    {
      h: "Data we collect",
      p: [
        "Account data: name, email, password (stored hashed on our server), optional phone number and account type (customer or worker).",
        "Service data: addresses you enter, booking details, appointments, notes, and the in-app messages you exchange with the other party.",
        "Payment data: we never store card numbers. When card payment is enabled, data is handled by our payment processor and never reaches us. Cash payment on completion requires no financial data.",
        "Usage data: login and error logs needed to operate and secure the service.",
      ],
    },
    {
      h: "Why we collect it",
      p: [
        "To create accounts and sign you in, to place a booking and deliver it to the worker, to run wallet and loyalty features, to let the two parties communicate, to prevent abuse, and to meet legal obligations.",
      ],
    },
    {
      h: "Who we share it with",
      p: [
        "The worker or customer on the other side of a booking: name, phone, address and booking details, only as needed to deliver the service.",
        "Infrastructure providers that host the API and database, under data-processing agreements.",
        "Our payment processor, only if you choose card payment.",
        "We do not sell your data, do not share it for advertising, and the app contains no ad tracking or third-party analytics SDKs.",
      ],
    },
    {
      h: "Retention",
      p: [
        "Account data is kept while the account exists. When you delete your account, your personal data, bookings, messages and points are deleted within 30 days, except records we must keep by law (for example invoices).",
      ],
    },
    {
      h: "Account deletion",
      p: [
        "You can delete your account in the app: Settings → Delete account. Deletion is permanent and erases the data linked to the account.",
        "If you cannot sign in, email your request from the registered address to support@shaghalti.app and it will be completed within 30 days.",
      ],
    },
    {
      h: "Children",
      p: ["The service is for users aged 18 or older. We do not knowingly collect data from children."],
    },
    {
      h: "Your rights",
      p: [
        "You may access, correct or delete your data and withdraw consent. Contact support@shaghalti.app; we respond within 30 days.",
      ],
    },
    {
      h: "Security",
      p: [
        "Data moves over HTTPS, passwords are hashed (bcrypt), and the session token is stored in the platform secure store (Keychain / Keystore).",
      ],
    },
    {
      h: "Changes",
      p: [`Last updated: ${updated}. Material changes are announced in the app before they take effect.`],
    },
  ],
};

const terms: { ar: Section[]; en: Section[] } = {
  ar: [
    {
      h: "قبول الشروط",
      p: [
        "باستخدامك تطبيق شغّالتي فإنك توافق على هذه الشروط. إن لم توافق فلا تستخدم الخدمة.",
      ],
    },
    {
      h: "طبيعة الخدمة",
      p: [
        "المنصة وسيط تقني يربط بين العملاء والعاملات المستقلات لتقديم خدمات منزلية. الخدمة تُقدَّم خارج التطبيق وفي موقع العميل.",
        "الأسعار المعروضة تُحسب من سعر الساعة المعلن للخدمة ومدة الحجز، وتظهر لك كاملة قبل التأكيد. لا تُضاف رسوم خفية.",
      ],
    },
    {
      h: "الحجز والدفع",
      p: [
        "يصبح الحجز نافذاً بعد قبول العاملة. طرق الدفع المتاحة تظهر في شاشة الدفع؛ والدفع النقدي عند إتمام الخدمة هو الطريقة الافتراضية.",
        "لا يُطلب منك إدخال بيانات بطاقة داخل التطبيق، ولا يخزّن التطبيق أي بيانات بطاقة.",
      ],
    },
    {
      h: "الإلغاء والاسترجاع",
      p: [
        "يمكنك إلغاء الحجز مجاناً حتى 24 ساعة قبل الموعد. الإلغاء بعد ذلك يحتاج مراجعة الدعم وقد يترتب عليه رسوم بقيمة الخدمة الجزئية.",
        "الدفع النقدي لا يُخصم إلا بعد إتمام الخدمة، ولذلك لا يوجد استرجاع عند الإلغاء.",
      ],
    },
    {
      h: "التقييمات والمحتوى",
      p: [
        "يلتزم المستخدمون بكتابة تقييمات صادقة. يُمنع المحتوى المسيء أو المضلل. يمكن الإبلاغ عن أي رسالة أو مستخدم من داخل المحادثة، وتُراجع البلاغات خلال 24 ساعة، وقد يُحظر الحساب المخالف.",
      ],
    },
    {
      h: "مسؤوليات المستخدم",
      p: [
        "تقديم بيانات صحيحة، والحفاظ على سرية كلمة المرور، وعدم استخدام الخدمة في أي غرض غير قانوني.",
      ],
    },
    {
      h: "حدود المسؤولية",
      p: [
        "المنصة ليست طرفاً في العقد بين العميل والعاملة، وهي لا تقدّم أي ضمان تأميني. مسؤوليتنا محدودة بالقيمة المدفوعة للمنصة عن الحجز المعني.",
      ],
    },
    {
      h: "التعليق والإلغاء",
      p: [
        "يمكننا تعليق أو إلغاء أي حساب يخالف هذه الشروط أو يُسيء استخدام المنصة.",
      ],
    },
    {
      h: "القانون الواجب التطبيق",
      p: [
        "تخضع هذه الشروط لأنظمة المملكة العربية السعودية، وتختص محاكمها بأي نزاع.",
      ],
    },
    {
      h: "التواصل",
      p: [`لأي استفسار: support@shaghalti.app — آخر تحديث: ${updated}.`],
    },
  ],
  en: [
    {
      h: "Acceptance",
      p: ["By using the Shaghalti app you agree to these terms. If you do not agree, do not use the service."],
    },
    {
      h: "What the service is",
      p: [
        "The platform is a technical intermediary that connects customers with independent workers who provide home services. The service is performed outside the app, at the customer's location.",
        "Prices are calculated from the published hourly rate and the booked duration, and the full amount is shown before you confirm. There are no hidden fees.",
      ],
    },
    {
      h: "Booking and payment",
      p: [
        "A booking becomes effective once the worker accepts it. Available payment methods are shown on the payment screen; cash on completion is the default.",
        "The app never asks you to type card details into it and never stores card data.",
      ],
    },
    {
      h: "Cancellation and refunds",
      p: [
        "You can cancel free of charge up to 24 hours before the appointment. Later cancellations require support review and may incur a partial service fee.",
        "Cash payments are only collected after the service is completed, so no refund applies on cancellation.",
      ],
    },
    {
      h: "Reviews and content",
      p: [
        "Users must leave honest reviews. Abusive or misleading content is prohibited. Any message or user can be reported from the conversation; reports are reviewed within 24 hours and offending accounts may be suspended.",
      ],
    },
    {
      h: "Your responsibilities",
      p: ["Provide accurate information, keep your password confidential, and do not use the service for unlawful purposes."],
    },
    {
      h: "Limitation of liability",
      p: [
        "The platform is not a party to the contract between customer and worker and provides no insurance guarantee. Our liability is limited to the amount paid to the platform for the affected booking.",
      ],
    },
    {
      h: "Suspension",
      p: ["We may suspend or terminate any account that breaches these terms or misuses the platform."],
    },
    {
      h: "Governing law",
      p: ["These terms are governed by the laws of the Kingdom of Saudi Arabia, whose courts have jurisdiction over any dispute."],
    },
    {
      h: "Contact",
      p: [`support@shaghalti.app — last updated: ${updated}.`],
    },
  ],
};

export default function LegalContent({ kind, locale }: { kind: "privacy" | "terms"; locale: string }) {
  const ar = locale === "ar";
  const sections = kind === "privacy" ? (ar ? privacy.ar : privacy.en) : ar ? terms.ar : terms.en;

  return (
    <section style={{ maxWidth: 860, margin: "0 auto", padding: "2.5rem 1.25rem 5rem" }}>
      <h1 style={{ fontSize: "2rem", fontWeight: 900, marginBottom: ".5rem" }}>
        {kind === "privacy" ? (ar ? "سياسة الخصوصية" : "Privacy Policy") : ar ? "الشروط والأحكام" : "Terms & Conditions"}
      </h1>
      <p style={{ color: "var(--text-3)", marginBottom: "2.5rem", fontSize: ".9rem" }}>
        {ar ? `آخر تحديث: ${updated}` : `Last updated: ${updated}`}
      </p>

      {sections.map((s) => (
        <div key={s.h} style={{ marginBottom: "1.9rem" }}>
          <h2 style={{ fontSize: "1.15rem", fontWeight: 800, marginBottom: ".6rem" }}>{s.h}</h2>
          {s.p.map((text) => (
            <p key={text} style={{ color: "var(--text-2)", lineHeight: 1.9, fontSize: ".95rem", marginBottom: ".55rem" }}>
              {text}
            </p>
          ))}
        </div>
      ))}
    </section>
  );
}
