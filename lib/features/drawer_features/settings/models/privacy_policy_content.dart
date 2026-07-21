import 'legal_document_models.dart';
import 'settings_localization.dart';

class PrivacyPolicyContent {
  const PrivacyPolicyContent._();

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
    title: 'Privacy Policy',
    effectiveDate: 'Effective July 21, 2026',
    introduction:
        'This Privacy Policy explains how Italir Pothe collects, uses, protects, and shares information when you use our mobile app and related services.',
    sections: <LegalSectionModel>[
      LegalSectionModel(
        title: '1. Information we collect',
        bullets: <String>[
          'Account information such as your name, verified email address or phone number, password hash, profile photo, and learning level.',
          'Learning activity such as course progress, quiz and exam answers, certificates, streaks, rewards, and AI usage balances.',
          'Content you choose to provide, including messages, call information, voice recordings, CV details, uploaded files, and support requests.',
          'Technical information such as device identifiers, app version, push-notification tokens, IP address, crash details, and security logs.',
          'Purchase and entitlement information received from Google Play. We do not receive your full card details.',
        ],
      ),
      LegalSectionModel(
        title: '2. How we use information',
        bullets: <String>[
          'Create and secure your account, verify contact details, and provide requested features.',
          'Save progress, personalize learning, deliver certificates, operate messaging and calls, and provide AI-assisted tools.',
          'Process purchases, prevent fraud, troubleshoot problems, enforce safety rules, and improve the service.',
          'Send essential service, security, learning, and support communications. Marketing messages are sent only where permitted.',
        ],
      ),
      LegalSectionModel(
        title: '3. Permissions and device access',
        paragraphs: <String>[
          'Features may request access to the camera, microphone, photos, files, notifications, or call-related capabilities. Access is used only for the feature you choose and can be changed in device settings.',
        ],
      ),
      LegalSectionModel(
        title: '4. AI, voice, messaging, and calls',
        paragraphs: <String>[
          'Text, audio, and related context may be sent to contracted service providers when needed to generate AI responses, speech recognition, voice conversations, messaging, or calls. Do not submit sensitive information that is not needed for learning.',
          'Call and message metadata may be retained for delivery, security, abuse prevention, and support. Audio or video content is processed only when required by the chosen feature or when you explicitly record or upload it.',
        ],
      ),
      LegalSectionModel(
        title: '5. Service providers and sharing',
        paragraphs: <String>[
          'We share information only as needed with providers that help us operate the service, including hosting and storage, Firebase, Google Play, email and SMS delivery, AI and voice infrastructure, and Agora call services. Providers must handle information under their contracts and applicable law.',
          'We may disclose information when required by law, to protect users and the service, to investigate fraud or abuse, or as part of a business transfer with appropriate safeguards. We do not sell personal information to advertisers.',
        ],
      ),
      LegalSectionModel(
        title: '6. Retention and deletion',
        paragraphs: <String>[
          'We keep information only as long as reasonably needed for the service, security, legal obligations, dispute resolution, and legitimate business records. Retention periods vary by data type.',
          'You can request permanent account deletion from Settings. Some limited records may remain where required for legal, fraud-prevention, payment, safety, backup, or audit purposes.',
        ],
      ),
      LegalSectionModel(
        title: '7. Security',
        paragraphs: <String>[
          'We use reasonable technical and organizational measures such as password hashing, authenticated sessions, access controls, encrypted transport, and monitoring. No internet service can guarantee absolute security.',
        ],
      ),
      LegalSectionModel(
        title: '8. Your choices and rights',
        bullets: <String>[
          'Review or update available profile information in Settings.',
          'Change notification, camera, microphone, and photo permissions in device settings.',
          'Request access, correction, deletion, restriction, objection, or portability where applicable law provides these rights.',
          'Contact us to ask a privacy question or make a rights request. We may need to verify your identity first.',
        ],
      ),
      LegalSectionModel(
        title: '9. Children and international use',
        paragraphs: <String>[
          'The service is not intended for children under 13. Where local law requires a higher age or parental permission, that rule applies.',
          'Information may be processed in countries other than your own. We use appropriate safeguards where required by applicable law.',
        ],
      ),
      LegalSectionModel(
        title: '10. Changes and contact',
        paragraphs: <String>[
          'We may update this policy when the service, providers, or law changes. The effective date will be updated and additional notice will be provided for material changes when required.',
          'Privacy questions and requests can be sent to hello@italirpothe.com.',
        ],
      ),
    ],
  );

  static const LegalDocumentModel _bn = LegalDocumentModel(
    title: 'গোপনীয়তা নীতি',
    effectiveDate: 'কার্যকর: ২১ জুলাই ২০২৬',
    introduction:
        'Italir Pothe মোবাইল অ্যাপ ও সংশ্লিষ্ট সেবা ব্যবহারের সময় আমরা কী তথ্য সংগ্রহ, ব্যবহার, সুরক্ষা ও ভাগ করি—এই নীতিতে তা ব্যাখ্যা করা হয়েছে।',
    sections: <LegalSectionModel>[
      LegalSectionModel(
        title: '১. আমরা যে তথ্য সংগ্রহ করি',
        bullets: <String>[
          'নাম, যাচাইকৃত ইমেইল বা ফোন, পাসওয়ার্ড হ্যাশ, প্রোফাইল ছবি এবং শেখার স্তরের মতো অ্যাকাউন্ট তথ্য।',
          'কোর্স অগ্রগতি, কুইজ ও পরীক্ষার উত্তর, সার্টিফিকেট, স্ট্রিক, পুরস্কার এবং AI ব্যবহারের ব্যালান্স।',
          'বার্তা, কলের তথ্য, ভয়েস রেকর্ডিং, CV তথ্য, আপলোড করা ফাইল ও সহায়তা অনুরোধের মতো আপনার দেওয়া কনটেন্ট।',
          'ডিভাইস আইডি, অ্যাপ সংস্করণ, পুশ টোকেন, IP ঠিকানা, ক্র্যাশ তথ্য ও নিরাপত্তা লগ।',
          'Google Play থেকে পাওয়া ক্রয় ও সুবিধার তথ্য। আমরা আপনার সম্পূর্ণ কার্ডের তথ্য পাই না।',
        ],
      ),
      LegalSectionModel(
        title: '২. তথ্য কীভাবে ব্যবহার করি',
        bullets: <String>[
          'অ্যাকাউন্ট তৈরি ও সুরক্ষিত রাখা, যোগাযোগ যাচাই এবং চাওয়া ফিচার দেওয়া।',
          'অগ্রগতি সংরক্ষণ, শেখা ব্যক্তিগতকরণ, সার্টিফিকেট, বার্তা, কল ও AI ফিচার পরিচালনা।',
          'ক্রয় যাচাই, প্রতারণা রোধ, সমস্যা সমাধান, নিরাপত্তা নীতি প্রয়োগ এবং সেবা উন্নত করা।',
          'প্রয়োজনীয় সেবা, নিরাপত্তা, শেখা ও সহায়তা সম্পর্কিত বার্তা পাঠানো।',
        ],
      ),
      LegalSectionModel(
        title: '৩. অনুমতি ও ডিভাইস ব্যবহার',
        paragraphs: <String>[
          'ক্যামেরা, মাইক্রোফোন, ছবি, ফাইল, নোটিফিকেশন বা কল-সংশ্লিষ্ট সুবিধার অনুমতি চাওয়া হতে পারে। শুধু আপনার নির্বাচিত ফিচারের জন্য এগুলো ব্যবহার করা হয় এবং ডিভাইস সেটিংস থেকে পরিবর্তন করা যায়।',
        ],
      ),
      LegalSectionModel(
        title: '৪. AI, ভয়েস, বার্তা ও কল',
        paragraphs: <String>[
          'AI উত্তর, স্পিচ রিকগনিশন, ভয়েস কথোপকথন, বার্তা বা কল চালাতে প্রয়োজন অনুযায়ী লেখা, অডিও ও প্রাসঙ্গিক তথ্য চুক্তিবদ্ধ সেবা প্রদানকারীর কাছে পাঠানো হতে পারে।',
          'ডেলিভারি, নিরাপত্তা, অপব্যবহার প্রতিরোধ ও সহায়তার জন্য কল ও বার্তার মেটাডেটা রাখা হতে পারে।',
        ],
      ),
      LegalSectionModel(
        title: '৫. সেবা প্রদানকারী ও তথ্য ভাগ',
        paragraphs: <String>[
          'হোস্টিং, স্টোরেজ, Firebase, Google Play, ইমেইল ও SMS, AI/ভয়েস অবকাঠামো এবং Agora কল সেবার মতো প্রয়োজনীয় প্রদানকারীর সঙ্গে সীমিত তথ্য ভাগ করা হয়।',
          'আইনগত বাধ্যবাধকতা, ব্যবহারকারী ও সেবা সুরক্ষা, প্রতারণা তদন্ত বা নিরাপদ ব্যবসায়িক হস্তান্তরের ক্ষেত্রে তথ্য প্রকাশ করা হতে পারে। বিজ্ঞাপনদাতার কাছে ব্যক্তিগত তথ্য বিক্রি করা হয় না।',
        ],
      ),
      LegalSectionModel(
        title: '৬. তথ্য সংরক্ষণ ও মুছে ফেলা',
        paragraphs: <String>[
          'সেবা, নিরাপত্তা, আইনগত দায়, বিরোধ নিষ্পত্তি ও বৈধ ব্যবসায়িক রেকর্ডের জন্য যতদিন যুক্তিসঙ্গতভাবে প্রয়োজন ততদিন তথ্য রাখা হয়।',
          'সেটিংস থেকে স্থায়ী অ্যাকাউন্ট মুছে ফেলার অনুরোধ করা যায়। আইন, প্রতারণা প্রতিরোধ, পেমেন্ট, নিরাপত্তা, ব্যাকআপ বা অডিটের জন্য কিছু সীমিত রেকর্ড থাকতে পারে।',
        ],
      ),
      LegalSectionModel(
        title: '৭. নিরাপত্তা',
        paragraphs: <String>[
          'পাসওয়ার্ড হ্যাশিং, যাচাইকৃত সেশন, অ্যাক্সেস নিয়ন্ত্রণ, এনক্রিপ্টেড যোগাযোগ ও পর্যবেক্ষণের মতো যুক্তিসঙ্গত ব্যবস্থা ব্যবহার করি। কোনো অনলাইন সেবাই শতভাগ নিরাপত্তা নিশ্চিত করতে পারে না।',
        ],
      ),
      LegalSectionModel(
        title: '৮. আপনার পছন্দ ও অধিকার',
        bullets: <String>[
          'সেটিংস থেকে প্রোফাইল তথ্য দেখা বা পরিবর্তন করা।',
          'ডিভাইস সেটিংস থেকে নোটিফিকেশন, ক্যামেরা, মাইক্রোফোন ও ছবির অনুমতি পরিবর্তন করা।',
          'প্রযোজ্য আইন অনুযায়ী তথ্য দেখা, সংশোধন, মুছে ফেলা, সীমিত করা, আপত্তি বা পোর্টেবিলিটির অনুরোধ করা।',
          'অনুরোধের আগে পরিচয় যাচাই করা হতে পারে।',
        ],
      ),
      LegalSectionModel(
        title: '৯. শিশু ও আন্তর্জাতিক ব্যবহার',
        paragraphs: <String>[
          'সেবাটি ১৩ বছরের কম বয়সীদের জন্য নয়। স্থানীয় আইনে বেশি বয়স বা অভিভাবকের অনুমতি লাগলে সেই নিয়ম প্রযোজ্য।',
          'আপনার দেশের বাইরে তথ্য প্রক্রিয়াকরণ হতে পারে এবং প্রযোজ্য ক্ষেত্রে উপযুক্ত সুরক্ষা ব্যবহার করা হয়।',
        ],
      ),
      LegalSectionModel(
        title: '১০. পরিবর্তন ও যোগাযোগ',
        paragraphs: <String>[
          'সেবা, প্রদানকারী বা আইন পরিবর্তিত হলে নীতিটি হালনাগাদ হতে পারে। গুরুত্বপূর্ণ পরিবর্তনে প্রয়োজন অনুযায়ী অতিরিক্ত নোটিশ দেওয়া হবে।',
          'গোপনীয়তা সম্পর্কিত প্রশ্ন বা অনুরোধ hello@italirpothe.com-এ পাঠান।',
        ],
      ),
    ],
  );

  static const LegalDocumentModel _it = LegalDocumentModel(
    title: 'Informativa sulla privacy',
    effectiveDate: 'In vigore dal 21 luglio 2026',
    introduction:
        'Questa informativa spiega come Italir Pothe raccoglie, utilizza, protegge e condivide le informazioni quando usi l’app mobile e i servizi collegati.',
    sections: <LegalSectionModel>[
      LegalSectionModel(
        title: '1. Informazioni raccolte',
        bullets: <String>[
          'Dati dell’account come nome, email o telefono verificato, hash della password, foto del profilo e livello di apprendimento.',
          'Attività didattica come progressi, risposte a quiz ed esami, certificati, serie, premi e saldo di utilizzo AI.',
          'Contenuti forniti volontariamente, inclusi messaggi, dati delle chiamate, registrazioni vocali, informazioni del CV, file e richieste di assistenza.',
          'Dati tecnici come identificatori del dispositivo, versione dell’app, token push, indirizzo IP, arresti anomali e registri di sicurezza.',
          'Informazioni su acquisti e diritti ricevute da Google Play. Non riceviamo i dati completi della carta.',
        ],
      ),
      LegalSectionModel(
        title: '2. Come utilizziamo le informazioni',
        bullets: <String>[
          'Creare e proteggere l’account, verificare i contatti e fornire le funzioni richieste.',
          'Salvare i progressi, personalizzare l’apprendimento, fornire certificati, messaggi, chiamate e strumenti AI.',
          'Gestire acquisti, prevenire frodi, risolvere problemi, applicare regole di sicurezza e migliorare il servizio.',
          'Inviare comunicazioni essenziali relative a servizio, sicurezza, apprendimento e assistenza.',
        ],
      ),
      LegalSectionModel(
        title: '3. Autorizzazioni e accesso al dispositivo',
        paragraphs: <String>[
          'Alcune funzioni possono richiedere fotocamera, microfono, foto, file, notifiche o capacità di chiamata. L’accesso viene usato solo per la funzione scelta e può essere modificato nelle impostazioni del dispositivo.',
        ],
      ),
      LegalSectionModel(
        title: '4. AI, voce, messaggi e chiamate',
        paragraphs: <String>[
          'Testo, audio e contesto possono essere inviati a fornitori contrattuali quando necessario per risposte AI, riconoscimento vocale, conversazioni vocali, messaggi o chiamate.',
          'I metadati di chiamate e messaggi possono essere conservati per consegna, sicurezza, prevenzione degli abusi e assistenza.',
        ],
      ),
      LegalSectionModel(
        title: '5. Fornitori e condivisione',
        paragraphs: <String>[
          'Condividiamo dati limitati con fornitori necessari, tra cui hosting, archiviazione, Firebase, Google Play, email e SMS, infrastruttura AI/voce e servizi di chiamata Agora.',
          'Possiamo comunicare dati quando richiesto dalla legge, per proteggere utenti e servizio, indagare frodi o nell’ambito di un trasferimento aziendale protetto. Non vendiamo dati personali agli inserzionisti.',
        ],
      ),
      LegalSectionModel(
        title: '6. Conservazione ed eliminazione',
        paragraphs: <String>[
          'Conserviamo i dati per il tempo ragionevolmente necessario al servizio, alla sicurezza, agli obblighi legali, alle controversie e ai registri aziendali legittimi.',
          'Puoi richiedere l’eliminazione permanente dell’account dalle Impostazioni. Alcuni registri limitati possono restare per legge, prevenzione frodi, pagamenti, sicurezza, backup o audit.',
        ],
      ),
      LegalSectionModel(
        title: '7. Sicurezza',
        paragraphs: <String>[
          'Adottiamo misure ragionevoli come hashing delle password, sessioni autenticate, controlli di accesso, trasporto cifrato e monitoraggio. Nessun servizio online può garantire sicurezza assoluta.',
        ],
      ),
      LegalSectionModel(
        title: '8. Scelte e diritti',
        bullets: <String>[
          'Visualizzare o aggiornare le informazioni disponibili nelle Impostazioni.',
          'Modificare autorizzazioni per notifiche, fotocamera, microfono e foto nelle impostazioni del dispositivo.',
          'Richiedere accesso, rettifica, cancellazione, limitazione, opposizione o portabilità quando previsto dalla legge.',
          'Potremmo dover verificare la tua identità prima di gestire una richiesta.',
        ],
      ),
      LegalSectionModel(
        title: '9. Minori e uso internazionale',
        paragraphs: <String>[
          'Il servizio non è destinato ai minori di 13 anni. Se la legge locale richiede un’età superiore o il consenso dei genitori, si applica tale regola.',
          'I dati possono essere trattati in paesi diversi dal tuo, con garanzie appropriate quando richiesto.',
        ],
      ),
      LegalSectionModel(
        title: '10. Modifiche e contatti',
        paragraphs: <String>[
          'Possiamo aggiornare l’informativa quando cambiano il servizio, i fornitori o la legge. Per modifiche rilevanti forniremo ulteriore avviso quando necessario.',
          'Invia domande o richieste sulla privacy a hello@italirpothe.com.',
        ],
      ),
    ],
  );
}
