import 'package:get/get.dart';
import 'package:italir_pothe/routes/routes.dart';

class SettingsController extends GetxController {
  final RxBool hapticsEnabled = false.obs;

  void onSettingsTap() {
    Get.toNamed(AppRoutes.settings);
  }

  void toggleHaptics() {
    hapticsEnabled.value = !hapticsEnabled.value;
  }

  // void openProfileSecurity() {
  //   Get.snackbar(
  //     'Profile',
  //     'Profile security page will open here.',
  //     snackPosition: SnackPosition.BOTTOM,
  //   );
  // }

  // void changePassword() {
  //   Get.snackbar(
  //     'Change Password',
  //     'Change password page will open here.',
  //     snackPosition: SnackPosition.BOTTOM,
  //   );
  // }

  void rateUs() {
    Get.snackbar(
      'Rate Us',
      'Store rating page will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openReports() {
    Get.snackbar(
      'Reports',
      'Reports page will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openPrivacyPolicy() {
    Get.snackbar(
      'Privacy Policy',
      'Privacy policy page will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openTerms() {
    Get.snackbar(
      'Terms of Service',
      'Terms page will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void deleteAccount() {
    Get.snackbar(
      'Delete Account',
      'Delete account confirmation will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  final RxString editProfileTab = 'email'.obs;
  final RxString deleteConfirmText = ''.obs;

  bool get canDeleteAccount =>
      deleteConfirmText.value.trim().toUpperCase() == 'DELETE';

  void setEditProfileTab(String tab) {
    editProfileTab.value = tab;
  }

  void openProfileSecurity() {
    Get.toNamed(AppRoutes.profileSecurity);
  }

  void changePassword() {
    Get.toNamed(AppRoutes.changePassword);
  }
}
