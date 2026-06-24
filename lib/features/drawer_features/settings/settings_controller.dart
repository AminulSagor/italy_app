import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../routes/routes.dart';
import 'models/user_settings_models.dart';
import 'services/user_settings_service.dart';

class SettingsController extends GetxController {
  SettingsController({required UserSettingsService userSettingsService})
    : _userSettingsService = userSettingsService;

  final UserSettingsService _userSettingsService;
  final ImagePicker _imagePicker = ImagePicker();

  final Rxn<UserSettingsProfileModel> profile =
      Rxn<UserSettingsProfileModel>();
  final Rxn<XFile> selectedAvatar = Rxn<XFile>();
  final RxBool isLoading = false.obs;
  final RxBool isSavingName = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool hapticsEnabled = false.obs;
  final RxBool obscureCurrentPassword = true.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString editProfileTab = 'email'.obs;
  final RxString newPasswordDraft = ''.obs;
  final RxString confirmPasswordDraft = ''.obs;
  final RxString deleteConfirmText = ''.obs;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  String get displayName {
    final String name = profile.value?.fullName.trim() ?? '';
    return name.isEmpty ? 'Italian Learner' : name;
  }

  String get primaryContact {
    final UserSettingsProfileModel? value = profile.value;
    return value?.email ?? value?.phone ?? 'No contact added';
  }

  String get selectedContactValue {
    final UserSettingsProfileModel? value = profile.value;
    if (editProfileTab.value == 'phone') {
      return value?.phone ?? 'No phone number added';
    }
    return value?.email ?? 'No email address added';
  }

  bool get selectedContactVerified {
    final UserSettingsProfileModel? value = profile.value;
    if (editProfileTab.value == 'phone') {
      return value?.isPhoneVerified == true;
    }
    return value?.isEmailVerified == true;
  }

  bool get canDeleteAccount =>
      deleteConfirmText.value.trim().toUpperCase() == 'DELETE';

  bool get hasValidNewPassword {
    final String password = newPasswordDraft.value;
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[@$!%*?&#]').hasMatch(password);
  }


  bool get hasPasswordMinimumLength => newPasswordDraft.value.length >= 8;

  bool get hasPasswordNumber => RegExp(r'\d').hasMatch(newPasswordDraft.value);

  bool get hasPasswordUppercase =>
      RegExp(r'[A-Z]').hasMatch(newPasswordDraft.value);

  bool get hasPasswordSpecialCharacter =>
      RegExp(r'[@$!%*?&#]').hasMatch(newPasswordDraft.value);

  bool get passwordsMatch =>
      newPasswordDraft.value.isNotEmpty &&
      newPasswordDraft.value == confirmPasswordDraft.value;

  Future<void> loadProfile({bool showError = true}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final ApiResult<UserSettingsProfileModel> result =
          await ApiErrorHandler.call<UserSettingsProfileModel>(
            _userSettingsService.getProfile,
            showError: showError,
            errorTitle: 'Profile',
          );

      if (!result.isSuccess || result.data == null) return;
      _applyProfile(result.data!);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveFullName() async {
    final String fullName = fullNameController.text.trim();
    if (fullName.length < 2) {
      Get.snackbar('Full Name', 'Please enter at least 2 characters.');
      return false;
    }

    isSavingName.value = true;
    try {
      final ApiResult<UserSettingsProfileResponseModel> result =
          await ApiErrorHandler.call<UserSettingsProfileResponseModel>(
            () => _userSettingsService.updateFullName(fullName),
            errorTitle: 'Update Profile',
          );

      if (!result.isSuccess || result.data == null) return false;
      _applyProfile(result.data!.profile);
      return true;
    } finally {
      isSavingName.value = false;
    }
  }

  Future<bool> pickAvatar(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 1400,
        maxHeight: 1400,
      );

      if (image == null) return false;
      selectedAvatar.value = image;
      return true;
    } catch (error) {
      Get.snackbar('Profile Photo', ApiErrorHandler.getErrorMessage(error));
      return false;
    }
  }

  Future<bool> uploadSelectedAvatar() async {
    final XFile? image = selectedAvatar.value;
    if (image == null) {
      Get.snackbar('Profile Photo', 'Please choose a photo first.');
      return false;
    }

    isUploadingAvatar.value = true;
    try {
      final ApiResult<UserSettingsProfileResponseModel> result =
          await ApiErrorHandler.call<UserSettingsProfileResponseModel>(
            () => _userSettingsService.uploadAvatar(image),
            errorTitle: 'Profile Photo',
          );

      if (!result.isSuccess || result.data == null) return false;
      _applyProfile(result.data!.profile);
      selectedAvatar.value = null;
      return true;
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<bool> submitPasswordChange() async {
    final String currentPassword = currentPasswordController.text;
    final String newPassword = newPasswordController.text;
    final String confirmPassword = confirmPasswordController.text;

    if (currentPassword.isEmpty) {
      Get.snackbar('Change Password', 'Enter your current password.');
      return false;
    }
    if (!hasValidNewPassword) {
      Get.snackbar(
        'Change Password',
        'Use 8+ characters with an uppercase letter, number, and special character.',
      );
      return false;
    }
    if (newPassword != confirmPassword) {
      Get.snackbar('Change Password', 'The new passwords do not match.');
      return false;
    }

    final ChangeUserPasswordPayloadModel payload =
        ChangeUserPasswordPayloadModel(
          currentPassword: currentPassword,
          newPassword: newPassword,
          confirmNewPassword: confirmPassword,
        );

    isChangingPassword.value = true;
    try {
      final ApiResult<UserSettingsMessageModel> result =
          await ApiErrorHandler.call<UserSettingsMessageModel>(
            () => _userSettingsService.changePassword(payload),
            errorTitle: 'Change Password',
          );

      if (!result.isSuccess) return false;
      clearPasswordFields();
      return true;
    } finally {
      isChangingPassword.value = false;
    }
  }

  void clearPasswordFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    newPasswordDraft.value = '';
    confirmPasswordDraft.value = '';
    obscureCurrentPassword.value = true;
    obscureNewPassword.value = true;
    obscureConfirmPassword.value = true;
  }

  void onNewPasswordChanged(String value) {
    newPasswordDraft.value = value;
  }

  void onConfirmPasswordChanged(String value) {
    confirmPasswordDraft.value = value;
  }

  void toggleHaptics() {
    hapticsEnabled.toggle();
  }

  void toggleCurrentPasswordVisibility() {
    obscureCurrentPassword.toggle();
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }

  void setEditProfileTab(String tab) {
    editProfileTab.value = tab;
  }

  void onSettingsTap() => Get.toNamed(AppRoutes.settings);

  void openProfileSecurity() => Get.toNamed(AppRoutes.profileSecurity);

  void changePassword() => Get.toNamed(AppRoutes.changePassword);

  void deleteAccount() => Get.toNamed(AppRoutes.deleteAccountConfirm);

  void rateUs() {
    Get.snackbar('Rate Us', 'Store rating page will open here.');
  }

  void openReports() {
    Get.snackbar('Reports', 'Reports page will open here.');
  }

  void openPrivacyPolicy() {
    Get.snackbar('Privacy Policy', 'Privacy policy page will open here.');
  }

  void openTerms() {
    Get.snackbar('Terms of Service', 'Terms page will open here.');
  }

  void _applyProfile(UserSettingsProfileModel value) {
    profile.value = value;
    fullNameController.text = value.fullName;
  }
}
