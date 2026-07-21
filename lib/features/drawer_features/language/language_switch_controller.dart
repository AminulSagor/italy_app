import 'package:get/get.dart';

import '../../../core/localization/translation_service.dart';

class LanguageDialogController extends GetxController {
  LanguageDialogController({AppLanguage? initialLanguage}) {
    final translationService = Get.find<TranslationService>();

    selectedLanguage.value =
        initialLanguage ?? translationService.currentLanguage;
  }

  final Rx<AppLanguage> selectedLanguage = AppLanguage.english.obs;

  void selectLanguage(AppLanguage language) {
    selectedLanguage.value = language;
  }

  bool isSelected(AppLanguage language) {
    return selectedLanguage.value == language;
  }

  void closeDialog() {
    Get.back<AppLanguage>();
  }

  void confirmLanguage() {
    Get.back<AppLanguage>(result: selectedLanguage.value);
  }
}
