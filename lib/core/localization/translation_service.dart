import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/localization/app_translations.dart';
import 'package:italir_pothe/core/services/services.dart';

enum AppLanguage { italian, english, bengali }

class TranslationService extends Translations {
  TranslationService({required StorageService storageService})
    : _storageService = storageService {
    initializeLocale();
  }

  final StorageService _storageService;

  static const Locale fallbackLocale = Locale('en', 'US');

  final RxString selectedLabel = 'EN'.obs;

  @override
  Map<String, Map<String, String>> get keys => _localizedValues;

  Locale get currentLocale => _localeFromLabel(selectedLabel.value);

  AppLanguage get currentLanguage => _languageFromLabel(selectedLabel.value);

  void initializeLocale() {
    final String? savedLabel = _storageService.savedAppLocale;

    if (savedLabel != null) {
      selectedLabel.value = savedLabel;
      return;
    }

    final Locale resolved = Get.deviceLocale ?? fallbackLocale;
    selectedLabel.value = _labelFromLocale(resolved);
  }

  Future<void> setLanguage(AppLanguage language) async {
    final Locale locale = _localeFromLanguage(language);
    final String label = _labelFromLanguage(language);

    if (selectedLabel.value == label) {
      return;
    }

    selectedLabel.value = label;
    await _storageService.saveAppLocale(label);

    Get.updateLocale(locale);
  }

  Future<void> setLanguageLabel(String label) async {
    final Locale locale = _localeFromLabel(label);
    final String normalizedLabel = _labelFromLocale(locale);

    if (selectedLabel.value == normalizedLabel) {
      return;
    }

    selectedLabel.value = normalizedLabel;
    await _storageService.saveAppLocale(normalizedLabel);

    Get.updateLocale(locale);
  }

  Locale _localeFromLabel(String label) {
    switch (label) {
      case 'IT':
        return const Locale('it', 'IT');
      case 'বাং':
        return const Locale('bn', 'BD');
      case 'EN':
      default:
        return const Locale('en', 'US');
    }
  }

  Locale _localeFromLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.italian:
        return const Locale('it', 'IT');
      case AppLanguage.bengali:
        return const Locale('bn', 'BD');
      case AppLanguage.english:
        return const Locale('en', 'US');
    }
  }

  AppLanguage _languageFromLabel(String label) {
    switch (label) {
      case 'IT':
        return AppLanguage.italian;
      case 'বাং':
        return AppLanguage.bengali;
      case 'EN':
      default:
        return AppLanguage.english;
    }
  }

  String _labelFromLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.italian:
        return 'IT';
      case AppLanguage.bengali:
        return 'বাং';
      case AppLanguage.english:
        return 'EN';
    }
  }

  String _labelFromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'it':
        return 'IT';
      case 'bn':
        return 'বাং';
      case 'en':
      default:
        return 'EN';
    }
  }

  static const Map<String, Map<String, String>> _localizedValues =
      appTranslations;
}
