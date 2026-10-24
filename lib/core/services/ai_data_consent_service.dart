import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:url_launcher/url_launcher.dart';

import 'api_client.dart';

typedef AiConsentStateHandler = Future<void> Function(bool granted);

class AiDataConsentService {
  AiDataConsentService({required ApiClient apiClient}) : _dio = apiClient.dio;

  @visibleForTesting
  AiDataConsentService.withDio(Dio dio) : _dio = dio;

  static const String currentVersion = '2026-10-04';
  static final Uri _privacyPolicy = Uri.parse(
    'https://www.italirpothe.com/privacy-policy',
  );

  final Dio _dio;
  Future<bool>? _activePrompt;
  final Set<AiConsentStateHandler> _stateHandlers = <AiConsentStateHandler>{};

  void addStateHandler(AiConsentStateHandler handler) {
    _stateHandlers.add(handler);
  }

  void removeStateHandler(AiConsentStateHandler handler) {
    _stateHandlers.remove(handler);
  }

  Future<bool> hasCurrentConsent() async {
    final Map<String, dynamic> status = await _fetchStatus();
    final bool granted =
        status['granted'] == true && status['version'] == currentVersion;
    await _notifyState(granted);
    return granted;
  }

  Future<bool> requireConsent() async {
    final Map<String, dynamic> status = await _fetchStatus();
    if (status['granted'] == true && status['version'] == currentVersion) {
      await _notifyState(true);
      return true;
    }
    final Future<bool>? activePrompt = _activePrompt;
    if (activePrompt != null) return activePrompt;

    final Future<bool> prompt = _showConsentPrompt();
    _activePrompt = prompt;
    try {
      return await prompt;
    } finally {
      if (identical(_activePrompt, prompt)) _activePrompt = null;
    }
  }

  Future<void> openConsentSettings() async {
    final Map<String, dynamic> status = await _fetchStatus();
    final bool granted = status['granted'] == true;
    if (!granted) {
      await _showConsentPrompt();
      return;
    }

    final _AiConsentCopy copy = _copy;
    final bool? revoke = await Get.dialog<bool>(
      AlertDialog(
        title: Text(copy.settingsTitle),
        content: Text(copy.settingsBody),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                launchUrl(_privacyPolicy, mode: LaunchMode.externalApplication),
            child: Text(copy.privacyPolicy),
          ),
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: Text(copy.keepEnabled),
          ),
          TextButton(
            onPressed: () => Get.back<bool>(result: true),
            child: Text(copy.withdraw),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    if (revoke == true) {
      final Response<dynamic> response = await _dio.delete<dynamic>(
        '/privacy/ai-consent',
      );
      final dynamic data = response.data;
      if (data is! Map || data['granted'] != false) {
        throw StateError('AI consent withdrawal was not confirmed.');
      }
      await _notifyState(false);
      Get.snackbar(copy.settingsTitle, copy.withdrawnMessage);
    }
  }

  Future<bool> _showConsentPrompt() async {
    final _AiConsentCopy copy = _copy;
    final bool? accepted = await Get.dialog<bool>(
      AlertDialog(
        title: Text(copy.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(copy.intro),
              const SizedBox(height: 12),
              Text(
                copy.providersForCurrentPlatform,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(copy.data),
              const SizedBox(height: 12),
              Text(copy.choice),
              TextButton(
                onPressed: () => launchUrl(
                  _privacyPolicy,
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(copy.privacyPolicy),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: Text(copy.notNow),
          ),
          FilledButton(
            onPressed: () => Get.back<bool>(result: true),
            child: Text(copy.allow),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    if (accepted != true) return false;

    final Response<dynamic> response = await _dio.post<dynamic>(
      '/privacy/ai-consent',
      data: const <String, dynamic>{'version': currentVersion},
    );
    final dynamic data = response.data;
    final bool granted = data is Map && data['granted'] == true;
    await _notifyState(granted);
    return granted;
  }

  Future<void> _notifyState(bool granted) async {
    for (final AiConsentStateHandler handler in List<AiConsentStateHandler>.of(
      _stateHandlers,
    )) {
      try {
        await handler(granted);
      } catch (error) {
        debugPrint('AI consent state handler failed: $error');
      }
    }
  }

  Future<Map<String, dynamic>> _fetchStatus() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/privacy/ai-consent',
    );
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException('AI consent status was invalid.');
  }

  _AiConsentCopy get _copy {
    switch (Get.locale?.languageCode) {
      case 'bn':
        return _AiConsentCopy.bn;
      case 'it':
        return _AiConsentCopy.it;
      default:
        return _AiConsentCopy.en;
    }
  }
}

class _AiConsentCopy {
  const _AiConsentCopy({
    required this.title,
    required this.intro,
    required this.providers,
    required this.iosProviders,
    required this.data,
    required this.choice,
    required this.privacyPolicy,
    required this.notNow,
    required this.allow,
    required this.settingsTitle,
    required this.settingsBody,
    required this.keepEnabled,
    required this.withdraw,
    required this.withdrawnMessage,
  });

  final String title;
  final String intro;
  final String providers;
  final String iosProviders;
  final String data;
  final String choice;
  final String privacyPolicy;
  final String notNow;
  final String allow;
  final String settingsTitle;
  final String settingsBody;
  final String keepEnabled;
  final String withdraw;
  final String withdrawnMessage;

  String get providersForCurrentPlatform =>
      defaultTargetPlatform == TargetPlatform.iOS ? iosProviders : providers;

  static const _AiConsentCopy en = _AiConsentCopy(
    title: 'Allow third-party AI processing?',
    intro:
        'To provide AI Tutor and AI-assisted CV features, Italir Pothe needs to share the information you submit with third-party AI services.',
    providers:
        'Providers: Google Gemini for live AI tutoring and assessment; OpenAI for AI text, transcription, speech, and CV assistance; and LiveKit only when the legacy Android voice service is used.',
    iosProviders:
        'Providers on iOS: Google Gemini for live AI voice tutoring and assessment, and OpenAI for AI text, transcription, speech, and CV assistance.',
    data:
        'This may include prompts, conversation context, voice audio and transcripts, language-test answers, CV text, documents, and selected images. It is used only to provide the AI feature you request.',
    choice:
        'This is optional. If you choose Not now, non-AI parts of Italir Pothe remain available. You can withdraw permission later in Settings.',
    privacyPolicy: 'Read Privacy Policy',
    notNow: 'Not now',
    allow: 'Allow AI processing',
    settingsTitle: 'AI data sharing',
    settingsBody:
        'You currently allow data submitted to AI features to be processed by the named third-party AI and speech providers. Withdrawing permission disables future AI requests but does not affect other features.',
    keepEnabled: 'Keep enabled',
    withdraw: 'Withdraw permission',
    withdrawnMessage: 'AI data-sharing permission was withdrawn.',
  );

  static const _AiConsentCopy bn = _AiConsentCopy(
    title: 'তৃতীয়-পক্ষ AI প্রক্রিয়াকরণের অনুমতি দেবেন?',
    intro:
        'AI Tutor ও AI-সহায়ক CV ফিচার দিতে Italir Pothe-কে আপনার দেওয়া তথ্য তৃতীয়-পক্ষ AI সেবার সঙ্গে শেয়ার করতে হবে।',
    providers:
        'সেবাদাতা: লাইভ AI টিউটরিং ও মূল্যায়নের জন্য Google Gemini; AI লেখা, ট্রান্সক্রিপশন, ভয়েস ও CV সহায়তার জন্য OpenAI; এবং শুধু পুরোনো Android ভয়েস সেবা ব্যবহৃত হলে LiveKit।',
    iosProviders:
        'iOS-এ সেবাদাতা: লাইভ AI ভয়েস টিউটরিং ও মূল্যায়নের জন্য Google Gemini এবং AI লেখা, ট্রান্সক্রিপশন, ভয়েস ও CV সহায়তার জন্য OpenAI।',
    data:
        'এর মধ্যে প্রম্পট, কথোপকথনের প্রসঙ্গ, ভয়েস অডিও ও ট্রান্সক্রিপ্ট, ভাষা পরীক্ষার উত্তর, CV লেখা, নথি এবং নির্বাচিত ছবি থাকতে পারে।',
    choice:
        'এটি ঐচ্ছিক। এখন না বললে অন্যান্য ফিচার ব্যবহার করা যাবে। Settings থেকে পরে অনুমতি প্রত্যাহার করতে পারবেন।',
    privacyPolicy: 'Privacy Policy পড়ুন',
    notNow: 'এখন নয়',
    allow: 'AI প্রক্রিয়াকরণের অনুমতি দিন',
    settingsTitle: 'AI ডেটা শেয়ারিং',
    settingsBody:
        'আপনি বর্তমানে AI ফিচারে দেওয়া তথ্য উল্লিখিত তৃতীয়-পক্ষ AI ও স্পিচ সেবাদাতাদের দিয়ে প্রক্রিয়াকরণের অনুমতি দিয়েছেন।',
    keepEnabled: 'চালু রাখুন',
    withdraw: 'অনুমতি প্রত্যাহার করুন',
    withdrawnMessage: 'AI ডেটা শেয়ারিংয়ের অনুমতি প্রত্যাহার করা হয়েছে।',
  );

  static const _AiConsentCopy it = _AiConsentCopy(
    title: 'Consentire il trattamento tramite IA di terze parti?',
    intro:
        'Per offrire il Tutor IA e le funzioni IA per il CV, Italir Pothe deve condividere i dati inviati con servizi IA di terze parti.',
    providers:
        'Fornitori: Google Gemini per tutoraggio e valutazione IA in diretta; OpenAI per testo IA, trascrizione, voce e assistenza CV; LiveKit solo per il servizio vocale Android precedente.',
    iosProviders:
        'Fornitori su iOS: Google Gemini per il tutor vocale IA in diretta e la valutazione; OpenAI per testo IA, trascrizione, voce e assistenza CV.',
    data:
        'I dati possono includere prompt, contesto, audio e trascrizioni, risposte ai test, testo del CV, documenti e immagini selezionate.',
    choice:
        'Il consenso è facoltativo. Se scegli Non ora, le funzioni non IA restano disponibili. Puoi revocarlo in Impostazioni.',
    privacyPolicy: 'Leggi l’informativa sulla privacy',
    notNow: 'Non ora',
    allow: 'Consenti trattamento IA',
    settingsTitle: 'Condivisione dati IA',
    settingsBody:
        'Hai consentito il trattamento dei dati inviati alle funzioni IA da parte dei fornitori IA e vocali indicati.',
    keepEnabled: 'Mantieni attivo',
    withdraw: 'Revoca consenso',
    withdrawnMessage:
        'Il consenso alla condivisione dei dati IA è stato revocato.',
  );
}
