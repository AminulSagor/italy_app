import 'legal_document_models.dart';
import 'settings_localization.dart';

class TermsOfServiceContent {
  const TermsOfServiceContent._();

  static const String supportEmail = 'hello@italirpothe.com';

  static LegalDocumentModel get document {
    switch (SettingsL10n.languageCode) {
      case 'bn':
        return _bn;
      case 'it':
        return _it;
      default:
        return _en;
    }
  }

  static const LegalDocumentModel _en = LegalDocumentModel(
    title: 'Terms of Service',
    effectiveDate: 'Effective July 21, 2026',
    introduction:
        'These Terms govern access to and use of Italir Pothe, including learning content, AI tools, messaging, calls, purchases, certificates, and related services.',
    sections: <LegalSectionModel>[
      LegalSectionModel(
        title: '1. Acceptance and eligibility',
        paragraphs: <String>[
          'By creating an account or using the service, you agree to these Terms and the Privacy Policy. Do not use the service if you do not agree.',
          'You must be at least 13 years old. A higher local minimum age or required parental permission still applies.',
        ],
      ),
      LegalSectionModel(
        title: '2. Account responsibilities',
        bullets: <String>[
          'Provide accurate information and keep your verified email or phone current.',
          'Protect your password and verification codes and do not share your account.',
          'Tell support promptly if you suspect unauthorized access.',
          'You are responsible for activity through your account unless applicable law provides otherwise.',
        ],
      ),
      LegalSectionModel(
        title: '3. Educational and AI limitations',
        paragraphs: <String>[
          'AI responses, translations, corrections, speech recognition, and level estimates may be incomplete or incorrect. Review important output before relying on it.',
          'The service is an educational tool and does not provide legal, immigration, medical, financial, employment, or other professional advice. It does not guarantee exam, employment, residency, or official outcomes.',
        ],
      ),
      LegalSectionModel(
        title: '4. Acceptable use',
        bullets: <String>[
          'Do not harass, threaten, impersonate, exploit, or expose another person’s private information.',
          'Do not upload illegal, abusive, deceptive, infringing, malicious, or unsafe content.',
          'Do not record or distribute another person’s voice, video, messages, or information without required consent.',
          'Do not bypass access controls, probe security, introduce malware, scrape protected content, or use unauthorized automation.',
          'Do not manipulate purchases, credits, rewards, exams, referrals, or service systems.',
        ],
      ),
      LegalSectionModel(
        title: '5. User content, messaging, and calls',
        paragraphs: <String>[
          'You keep ownership of content you create. You grant Italir Pothe a limited license to host, process, transmit, adapt, and display it only as reasonably needed to operate, secure, moderate, and improve the service.',
          'You confirm that you have the rights and permissions needed for content you submit. Community, messaging, and call features must be used lawfully and respectfully.',
        ],
      ),
      LegalSectionModel(
        title: '6. Purchases and digital entitlements',
        bullets: <String>[
          'Prices, taxes, currency, package contents, and payment terms are shown before confirmation.',
          'Android purchases are processed through Google Play and its payment and refund rules may apply.',
          'Courses, AI usage, CV credits, streak freezes, subscriptions, rewards, and similar entitlements are personal, non-transferable, and have no cash value unless required by law.',
          'Entitlements may be reversed after a refund, cancellation, chargeback, duplicate transaction, fraud, or grant made in error.',
        ],
      ),
      LegalSectionModel(
        title: '7. Intellectual property and third-party services',
        paragraphs: <String>[
          'The app, software, designs, lessons, branding, and service content belong to Italir Pothe or its licensors. You receive a limited, revocable, non-exclusive, non-transferable license for personal learning use.',
          'The service may use Google Play, Firebase, hosting and storage providers, AI and voice providers, Agora, WhatsApp, Facebook, email, and SMS services. Their own terms may apply.',
        ],
      ),
      LegalSectionModel(
        title: '8. Suspension, termination, and account deletion',
        paragraphs: <String>[
          'We may warn, limit, suspend, or terminate access when reasonably needed for security, fraud prevention, non-payment, legal compliance, serious or repeated violations, or protection of users and the service.',
          'You may stop using the service and can request permanent account deletion from Settings. Terms that naturally survive termination remain effective.',
        ],
      ),
      LegalSectionModel(
        title: '9. Availability, disclaimers, and liability',
        paragraphs: <String>[
          'The service may be interrupted by maintenance, networks, providers, device limitations, or events outside our control. To the extent allowed by law, it is provided “as is” and “as available.”',
          'To the maximum extent permitted by law, Italir Pothe is not liable for indirect, incidental, special, consequential, or punitive loss. Rights and protections that cannot legally be excluded remain unaffected.',
        ],
      ),
      LegalSectionModel(
        title: '10. Changes, law, disputes, and contact',
        paragraphs: <String>[
          'We may update these Terms when the service, providers, safety requirements, or law changes. The effective date will be updated and additional notice will be provided when required.',
          'Applicable law and courts with lawful jurisdiction govern disputes while preserving mandatory consumer protections.',
          'Questions about these Terms can be sent to hello@italirpothe.com.',
        ],
      ),
    ],
  );

  static const LegalDocumentModel _bn = LegalDocumentModel(
    title: 'সেবার শর্তাবলি',
    effectiveDate: 'কার্যকর: ২১ জুলাই ২০২৬',
    introduction:
        'শেখার কনটেন্ট, AI টুল, বার্তা, কল, ক্রয়, সার্টিফিকেট এবং সংশ্লিষ্ট Italir Pothe সেবা ব্যবহারের ক্ষেত্রে এই শর্তাবলি প্রযোজ্য।',
    sections: <LegalSectionModel>[
      LegalSectionModel(
        title: '১. সম্মতি ও যোগ্যতা',
        paragraphs: <String>[
          'অ্যাকাউন্ট তৈরি বা সেবা ব্যবহার করে আপনি এই শর্তাবলি ও গোপনীয়তা নীতিতে সম্মতি দেন। সম্মত না হলে সেবা ব্যবহার করবেন না।',
          'আপনার বয়স কমপক্ষে ১৩ বছর হতে হবে। স্থানীয় আইনে বেশি বয়স বা অভিভাবকের অনুমতি লাগলে সেই নিয়ম প্রযোজ্য।',
        ],
      ),
      LegalSectionModel(
        title: '২. অ্যাকাউন্টের দায়িত্ব',
        bullets: <String>[
          'সঠিক তথ্য দিন এবং যাচাইকৃত ইমেইল বা ফোন হালনাগাদ রাখুন।',
          'পাসওয়ার্ড ও যাচাইকরণ কোড সুরক্ষিত রাখুন এবং অ্যাকাউন্ট ভাগ করবেন না।',
          'অননুমোদিত প্রবেশের সন্দেহ হলে দ্রুত সহায়তা টিমকে জানান।',
          'প্রযোজ্য আইনে ভিন্ন কিছু না থাকলে অ্যাকাউন্টের কার্যক্রমের জন্য আপনি দায়ী।',
        ],
      ),
      LegalSectionModel(
        title: '৩. শিক্ষা ও AI সীমাবদ্ধতা',
        paragraphs: <String>[
          'AI উত্তর, অনুবাদ, সংশোধন, স্পিচ রিকগনিশন ও লেভেল অনুমান অসম্পূর্ণ বা ভুল হতে পারে। গুরুত্বপূর্ণ ফল যাচাই করুন।',
          'এটি একটি শিক্ষামূলক সেবা; আইন, অভিবাসন, চিকিৎসা, অর্থ, চাকরি বা অন্য পেশাগত পরামর্শ নয় এবং কোনো সরকারি ফল নিশ্চিত করে না।',
        ],
      ),
      LegalSectionModel(
        title: '৪. গ্রহণযোগ্য ব্যবহার',
        bullets: <String>[
          'হয়রানি, হুমকি, পরিচয় নকল, শোষণ বা অন্যের ব্যক্তিগত তথ্য প্রকাশ করবেন না।',
          'অবৈধ, অপমানজনক, প্রতারণামূলক, অধিকার লঙ্ঘনকারী, ক্ষতিকর বা অনিরাপদ কনটেন্ট আপলোড করবেন না।',
          'প্রয়োজনীয় সম্মতি ছাড়া অন্যের ভয়েস, ভিডিও, বার্তা বা তথ্য রেকর্ড বা ছড়াবেন না।',
          'অ্যাক্সেস নিয়ন্ত্রণ এড়ানো, নিরাপত্তা পরীক্ষা, ম্যালওয়্যার, স্ক্র্যাপিং বা অননুমোদিত অটোমেশন ব্যবহার করবেন না।',
          'ক্রয়, ক্রেডিট, পুরস্কার, পরীক্ষা, রেফারেল বা সিস্টেমে কারসাজি করবেন না।',
        ],
      ),
      LegalSectionModel(
        title: '৫. ব্যবহারকারীর কনটেন্ট, বার্তা ও কল',
        paragraphs: <String>[
          'আপনার তৈরি কনটেন্টের মালিকানা আপনার থাকে। সেবা পরিচালনা, নিরাপত্তা, মডারেশন ও উন্নতির জন্য প্রয়োজনীয় সীমিত লাইসেন্স Italir Pothe-কে দেন।',
          'জমা দেওয়া কনটেন্টের জন্য প্রয়োজনীয় অধিকার ও অনুমতি আপনার আছে বলে নিশ্চিত করেন। বার্তা ও কল আইনসম্মত ও সম্মানজনকভাবে ব্যবহার করতে হবে।',
        ],
      ),
      LegalSectionModel(
        title: '৬. ক্রয় ও ডিজিটাল সুবিধা',
        bullets: <String>[
          'মূল্য, কর, মুদ্রা, প্যাকেজ ও পেমেন্টের তথ্য নিশ্চিত করার আগে দেখানো হয়।',
          'Android ক্রয় Google Play-এর মাধ্যমে প্রক্রিয়াকৃত হয় এবং তাদের রিফান্ড নীতি প্রযোজ্য হতে পারে।',
          'কোর্স, AI ব্যবহার, CV ক্রেডিট, স্ট্রিক ফ্রিজ, সাবস্ক্রিপশন ও পুরস্কার ব্যক্তিগত, হস্তান্তরযোগ্য নয় এবং আইনে প্রয়োজন না হলে নগদ মূল্য নেই।',
          'রিফান্ড, বাতিল, চার্জব্যাক, ডুপ্লিকেট, প্রতারণা বা ভুলভাবে দেওয়া সুবিধা প্রত্যাহার করা হতে পারে।',
        ],
      ),
      LegalSectionModel(
        title: '৭. মেধাস্বত্ব ও তৃতীয় পক্ষ',
        paragraphs: <String>[
          'অ্যাপ, সফটওয়্যার, ডিজাইন, পাঠ, ব্র্যান্ড ও সেবার কনটেন্ট Italir Pothe বা লাইসেন্সদাতার। ব্যক্তিগত শেখার জন্য সীমিত, প্রত্যাহারযোগ্য ও অ-হস্তান্তরযোগ্য লাইসেন্স দেওয়া হয়।',
          'Google Play, Firebase, হোস্টিং/স্টোরেজ, AI ও ভয়েস প্রদানকারী, Agora, WhatsApp, Facebook, ইমেইল ও SMS সেবা ব্যবহার হতে পারে; তাদের নিজস্ব শর্ত প্রযোজ্য।',
        ],
      ),
      LegalSectionModel(
        title: '৮. স্থগিত, সমাপ্তি ও অ্যাকাউন্ট মুছে ফেলা',
        paragraphs: <String>[
          'নিরাপত্তা, প্রতারণা, পেমেন্ট, আইন, গুরুতর বা পুনরাবৃত্ত লঙ্ঘন, বা ব্যবহারকারী ও সেবা রক্ষার জন্য প্রবেশ সীমিত, স্থগিত বা বন্ধ করা হতে পারে।',
          'আপনি সেবা ব্যবহার বন্ধ করতে পারেন এবং সেটিংস থেকে স্থায়ী অ্যাকাউন্ট মুছে ফেলার অনুরোধ করতে পারেন। স্বভাবতই বহাল থাকা শর্ত কার্যকর থাকবে।',
        ],
      ),
      LegalSectionModel(
        title: '৯. প্রাপ্যতা, দায় অস্বীকার ও সীমাবদ্ধতা',
        paragraphs: <String>[
          'রক্ষণাবেক্ষণ, নেটওয়ার্ক, প্রদানকারী, ডিভাইস বা নিয়ন্ত্রণের বাইরের কারণে সেবা বন্ধ হতে পারে। আইনে অনুমোদিত সীমায় সেবা “যেমন আছে” ও “যখন উপলভ্য” ভিত্তিতে দেওয়া হয়।',
          'আইনে সর্বোচ্চ অনুমোদিত সীমায় পরোক্ষ, আনুষঙ্গিক, বিশেষ, ফলশ্রুতিমূলক বা শাস্তিমূলক ক্ষতির জন্য Italir Pothe দায়ী নয়। বাদ দেওয়া যায় না এমন অধিকার অক্ষুণ্ণ থাকে।',
        ],
      ),
      LegalSectionModel(
        title: '১০. পরিবর্তন, আইন, বিরোধ ও যোগাযোগ',
        paragraphs: <String>[
          'সেবা, প্রদানকারী, নিরাপত্তা বা আইন বদলালে শর্তাবলি হালনাগাদ হতে পারে। কার্যকর তারিখ বদলানো হবে এবং প্রয়োজন অনুযায়ী নোটিশ দেওয়া হবে।',
          'প্রযোজ্য আইন ও বৈধ এখতিয়ারের আদালত বিরোধ পরিচালনা করবে; বাধ্যতামূলক ভোক্তা অধিকার অক্ষুণ্ণ থাকবে।',
          'প্রশ্ন hello@italirpothe.com-এ পাঠান।',
        ],
      ),
    ],
  );

  static const LegalDocumentModel _it = LegalDocumentModel(
    title: 'Termini di servizio',
    effectiveDate: 'In vigore dal 21 luglio 2026',
    introduction:
        'Questi Termini regolano l’accesso e l’uso di Italir Pothe, inclusi contenuti didattici, strumenti AI, messaggi, chiamate, acquisti, certificati e servizi collegati.',
    sections: <LegalSectionModel>[
      LegalSectionModel(
        title: '1. Accettazione e requisiti',
        paragraphs: <String>[
          'Creando un account o usando il servizio accetti questi Termini e l’Informativa sulla privacy. Non usare il servizio se non sei d’accordo.',
          'Devi avere almeno 13 anni. Restano validi eventuali limiti locali superiori o il consenso dei genitori.',
        ],
      ),
      LegalSectionModel(
        title: '2. Responsabilità dell’account',
        bullets: <String>[
          'Fornisci dati corretti e mantieni aggiornata l’email o il telefono verificato.',
          'Proteggi password e codici di verifica e non condividere l’account.',
          'Avvisa subito l’assistenza se sospetti un accesso non autorizzato.',
          'Sei responsabile dell’attività dell’account salvo diversa previsione di legge.',
        ],
      ),
      LegalSectionModel(
        title: '3. Limiti educativi e dell’AI',
        paragraphs: <String>[
          'Risposte AI, traduzioni, correzioni, riconoscimento vocale e stime del livello possono essere incomplete o errate. Verifica i risultati importanti.',
          'Il servizio è educativo e non offre consulenza legale, migratoria, medica, finanziaria, lavorativa o professionale e non garantisce risultati ufficiali.',
        ],
      ),
      LegalSectionModel(
        title: '4. Uso consentito',
        bullets: <String>[
          'Non molestare, minacciare, impersonare, sfruttare o divulgare dati privati altrui.',
          'Non caricare contenuti illegali, offensivi, ingannevoli, lesivi, dannosi o non sicuri.',
          'Non registrare o diffondere voce, video, messaggi o dati altrui senza il consenso richiesto.',
          'Non aggirare controlli, testare la sicurezza, introdurre malware, estrarre contenuti protetti o usare automazioni non autorizzate.',
          'Non manipolare acquisti, crediti, premi, esami, referral o sistemi del servizio.',
        ],
      ),
      LegalSectionModel(
        title: '5. Contenuti, messaggi e chiamate',
        paragraphs: <String>[
          'Mantieni la proprietà dei contenuti creati e concedi a Italir Pothe una licenza limitata per ospitarli, elaborarli, trasmetterli, adattarli e mostrarli quanto necessario al servizio, alla sicurezza, alla moderazione e al miglioramento.',
          'Confermi di avere diritti e permessi necessari. Messaggi e chiamate devono essere usati legalmente e con rispetto.',
        ],
      ),
      LegalSectionModel(
        title: '6. Acquisti e diritti digitali',
        bullets: <String>[
          'Prezzi, imposte, valuta, contenuto del pacchetto e condizioni di pagamento vengono mostrati prima della conferma.',
          'Gli acquisti Android sono elaborati da Google Play e possono essere soggetti alle sue regole di pagamento e rimborso.',
          'Corsi, utilizzo AI, crediti CV, protezioni serie, abbonamenti e premi sono personali, non trasferibili e senza valore in contanti salvo obbligo di legge.',
          'I diritti possono essere revocati dopo rimborso, annullamento, chargeback, duplicazione, frode o assegnazione errata.',
        ],
      ),
      LegalSectionModel(
        title: '7. Proprietà intellettuale e terze parti',
        paragraphs: <String>[
          'App, software, design, lezioni, marchio e contenuti appartengono a Italir Pothe o ai licenzianti. Ricevi una licenza limitata, revocabile, non esclusiva e non trasferibile per uso personale.',
          'Il servizio può usare Google Play, Firebase, hosting e archiviazione, fornitori AI e voce, Agora, WhatsApp, Facebook, email e SMS; possono applicarsi i loro termini.',
        ],
      ),
      LegalSectionModel(
        title: '8. Sospensione, cessazione ed eliminazione',
        paragraphs: <String>[
          'Possiamo limitare, sospendere o chiudere l’accesso per sicurezza, frode, mancato pagamento, legge, violazioni gravi o ripetute o protezione degli utenti e del servizio.',
          'Puoi smettere di usare il servizio e richiedere l’eliminazione permanente dalle Impostazioni. Le clausole destinate a sopravvivere restano valide.',
        ],
      ),
      LegalSectionModel(
        title: '9. Disponibilità, esclusioni e responsabilità',
        paragraphs: <String>[
          'Il servizio può essere interrotto da manutenzione, reti, fornitori, dispositivi o eventi fuori controllo. Nei limiti di legge è fornito “così com’è” e “come disponibile”.',
          'Nella misura massima consentita, Italir Pothe non risponde di perdite indirette, incidentali, speciali, consequenziali o punitive. I diritti inderogabili restano validi.',
        ],
      ),
      LegalSectionModel(
        title: '10. Modifiche, legge, controversie e contatti',
        paragraphs: <String>[
          'Possiamo aggiornare i Termini quando cambiano servizio, fornitori, sicurezza o legge. Aggiorneremo la data e daremo ulteriore avviso quando richiesto.',
          'Si applicano la legge e i tribunali con giurisdizione valida, preservando le tutele obbligatorie dei consumatori.',
          'Invia domande a hello@italirpothe.com.',
        ],
      ),
    ],
  );
}
