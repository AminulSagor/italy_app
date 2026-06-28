import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../core/controllers/user_session_controller.dart';
import '../../../core/models/current_user_summary.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_drawer_controller.dart';
import '../../../routes/routes.dart';
import 'models/user_settings_models.dart';
import 'services/user_settings_service.dart';

enum ProfileSaveResult { failed, saved, verificationStarted, noChanges }

class SettingsController extends GetxController {
  SettingsController({
    required UserSettingsService userSettingsService,
    required AuthService authService,
  }) : _userSettingsService = userSettingsService,
       _authService = authService;

  final UserSettingsService _userSettingsService;
  final AuthService _authService;
  final ImagePicker _imagePicker = ImagePicker();

  final Rxn<UserSettingsProfileModel> profile =
      Rxn<UserSettingsProfileModel>();
  final Rxn<XFile> selectedAvatar = Rxn<XFile>();
  final RxBool isLoading = false.obs;
  final RxBool isSavingName = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool isRequestingContactOtp = false.obs;
  final RxBool isVerifyingContactOtp = false.obs;
  final RxBool isResendingContactOtp = false.obs;
  final RxBool isDeletingAccount = false.obs;
  final RxBool obscureCurrentPassword = true.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString editProfileTab = 'email'.obs;
  final RxString emailDraft = ''.obs;
  final RxString phoneDraft = ''.obs;
  final RxString newPasswordDraft = ''.obs;
  final RxString confirmPasswordDraft = ''.obs;
  final RxString deleteConfirmText = ''.obs;
  final RxString pendingContactType = ''.obs;
  final RxString pendingContactValue = ''.obs;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    for (final TextEditingController controller in otpControllers) {
      controller.dispose();
    }
    for (final FocusNode focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }

  String get displayName {
    final String name = profile.value?.fullName.trim() ?? '';
    return name.isEmpty ? 'Italian Learner' : name;
  }

  int get streakFreezeCount => profile.value?.streakFreezeCount ?? 0;

  String get primaryContact {
    final UserSettingsProfileModel? value = profile.value;
    return value?.email ?? value?.phone ?? 'No contact added';
  }

  bool get selectedContactIsEmail => editProfileTab.value == 'email';

  TextEditingController get selectedContactController =>
      selectedContactIsEmail ? emailController : phoneController;

  String get selectedContactValue => selectedContactController.text.trim();

  bool get selectedContactVerified {
    final UserSettingsProfileModel? value = profile.value;
    return selectedContactIsEmail
        ? value?.isEmailVerified == true
        : value?.isPhoneVerified == true;
  }

  bool get selectedContactChanged {
    final UserSettingsProfileModel? value = profile.value;
    if (value == null) return false;

    if (selectedContactIsEmail) {
      return emailDraft.value.trim().toLowerCase() !=
          (value.email ?? '').trim().toLowerCase();
    }
    return phoneDraft.value.trim() != (value.phone ?? '').trim();
  }

  String get pendingContactDescription => pendingContactType.value == 'phone'
      ? 'phone number'
      : 'email address';

  String get otpCode => otpControllers.map((item) => item.text).join();

  bool get isOtpComplete => RegExp(r'^\d{4}$').hasMatch(otpCode);

  bool get canDeleteAccount =>
      _normalizeName(deleteConfirmText.value) == _normalizeName(displayName);

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

  Future<ProfileSaveResult> saveProfileAndContinue() async {
    final UserSettingsProfileModel? current = profile.value;
    if (current == null) return ProfileSaveResult.failed;

    final String fullName = fullNameController.text.trim();
    final bool nameChanged = fullName != current.fullName.trim();
    final bool contactChanged = selectedContactChanged;
    final bool contactIsEmail = selectedContactIsEmail;
    final String contactValue = selectedContactValue;

    if (nameChanged && !await saveFullName()) {
      return ProfileSaveResult.failed;
    }

    if (contactChanged) {
      final bool requested = await requestSelectedContactChange(
        isEmailOverride: contactIsEmail,
        valueOverride: contactValue,
      );
      return requested
          ? ProfileSaveResult.verificationStarted
          : ProfileSaveResult.failed;
    }

    return nameChanged ? ProfileSaveResult.saved : ProfileSaveResult.noChanges;
  }

  Future<bool> requestSelectedContactChange({
    bool? isEmailOverride,
    String? valueOverride,
  }) async {
    final bool isEmail = isEmailOverride ?? selectedContactIsEmail;
    final String value = valueOverride?.trim() ?? selectedContactValue;
    if (!_validateContact(value, isEmail: isEmail)) return false;

    isRequestingContactOtp.value = true;
    try {
      final ApiResult<ContactOtpResponseModel> result =
          await ApiErrorHandler.call<ContactOtpResponseModel>(
            () => isEmail
                ? _userSettingsService.requestEmailChangeOtp(value)
                : _userSettingsService.requestPhoneChangeOtp(value),
            errorTitle: 'Verify Contact',
          );

      if (!result.isSuccess || result.data == null) return false;

      pendingContactType.value = result.data!.contactType;
      pendingContactValue.value = result.data!.destination;
      clearOtpFields();

      final String? devOtp = result.data!.devOtp;
      if (devOtp != null && devOtp.isNotEmpty) {
        Get.snackbar('OTP', devOtp);
      }

      Get.toNamed(AppRoutes.verifyContact);
      return true;
    } finally {
      isRequestingContactOtp.value = false;
    }
  }

  Future<bool> verifyPendingContact() async {
    if (!isOtpComplete) {
      Get.snackbar('Verification Code', 'Enter the complete 4-digit code.');
      return false;
    }

    final String type = pendingContactType.value;
    final String destination = pendingContactValue.value;
    if (type.isEmpty || destination.isEmpty) {
      Get.snackbar('Verify Contact', 'The verification request has expired.');
      return false;
    }

    isVerifyingContactOtp.value = true;
    try {
      final ApiResult<UserSettingsProfileResponseModel> result =
          await ApiErrorHandler.call<UserSettingsProfileResponseModel>(
            () => type == 'phone'
                ? _userSettingsService.verifyPhoneChangeOtp(
                    phone: destination,
                    otp: otpCode,
                  )
                : _userSettingsService.verifyEmailChangeOtp(
                    email: destination,
                    otp: otpCode,
                  ),
            errorTitle: 'Verify Contact',
          );

      if (!result.isSuccess || result.data == null) return false;
      _applyProfile(result.data!.profile);
      clearPendingContact();

      Get.offNamed(
        AppRoutes.profileSuccess,
        arguments: <String, String>{
          'type': type == 'phone' ? 'phoneUpdated' : 'emailUpdated',
        },
      );
      return true;
    } finally {
      isVerifyingContactOtp.value = false;
    }
  }

  Future<void> resendPendingContactOtp() async {
    if (pendingContactValue.value.isEmpty || isResendingContactOtp.value) {
      return;
    }

    isResendingContactOtp.value = true;
    try {
      final bool isPhone = pendingContactType.value == 'phone';
      final ApiResult<ContactOtpResponseModel> result =
          await ApiErrorHandler.call<ContactOtpResponseModel>(
            () => isPhone
                ? _userSettingsService.requestPhoneChangeOtp(
                    pendingContactValue.value,
                  )
                : _userSettingsService.requestEmailChangeOtp(
                    pendingContactValue.value,
                  ),
            errorTitle: 'Resend Code',
          );

      if (!result.isSuccess || result.data == null) return;
      clearOtpFields();
      final String? devOtp = result.data!.devOtp;
      Get.snackbar(
        'Verification Code',
        devOtp == null || devOtp.isEmpty
            ? result.data!.message
            : '${result.data!.message}\nCode: $devOtp',
      );
    } finally {
      isResendingContactOtp.value = false;
    }
  }

  void onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < otpFocusNodes.length - 1) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  void clearOtpFields() {
    for (final TextEditingController controller in otpControllers) {
      controller.clear();
    }
    if (otpFocusNodes.isNotEmpty) {
      otpFocusNodes.first.requestFocus();
    }
  }

  void clearPendingContact() {
    pendingContactType.value = '';
    pendingContactValue.value = '';
    clearOtpFields();
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

  Future<void> deleteAccountPermanently() async {
    if (!canDeleteAccount || isDeletingAccount.value) return;

    isDeletingAccount.value = true;
    try {
      final ApiResult<UserSettingsMessageModel> result =
          await ApiErrorHandler.call<UserSettingsMessageModel>(
            () => _userSettingsService.deleteAccount(displayName),
            errorTitle: 'Delete Account',
          );

      if (!result.isSuccess) return;
      await _authService.logout();
      if (Get.isRegistered<UserSessionController>()) {
        Get.find<UserSessionController>().clear();
      }
      if (Get.isRegistered<AppDrawerController>()) {
        Get.find<AppDrawerController>().clear();
      }
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar('Account Deleted', result.data?.message ?? 'Account deleted.');
    } finally {
      isDeletingAccount.value = false;
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

  void onNewPasswordChanged(String value) => newPasswordDraft.value = value;

  void onConfirmPasswordChanged(String value) =>
      confirmPasswordDraft.value = value;

  void toggleCurrentPasswordVisibility() => obscureCurrentPassword.toggle();

  void toggleNewPasswordVisibility() => obscureNewPassword.toggle();

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.toggle();

  void setEditProfileTab(String tab) {
    editProfileTab.value = tab;
  }

  void onEmailChanged(String value) => emailDraft.value = value;

  void onPhoneChanged(String value) => phoneDraft.value = value;

  void onSettingsTap() => Get.toNamed(AppRoutes.settings);

  void openProfileSecurity() => Get.toNamed(AppRoutes.profileSecurity);

  void changePassword() => Get.toNamed(AppRoutes.changePassword);

  void deleteAccount() {
    deleteConfirmText.value = '';
    Get.toNamed(AppRoutes.deleteAccountConfirm);
  }

  void rateUs() {
    Get.snackbar('Rate Us', 'Store rating page will open here.');
  }

  void openPrivacyPolicy() => Get.toNamed(AppRoutes.privacyPolicy);

  void openTerms() => Get.toNamed(AppRoutes.termsOfService);

  bool _validateContact(String value, {required bool isEmail}) {
    if (isEmail) {
      if (!GetUtils.isEmail(value)) {
        Get.snackbar('Email', 'Enter a valid email address.');
        return false;
      }
      return true;
    }

    if (!RegExp(r'^(?:\+8801\d{9}|\+39\d{8,11})$').hasMatch(value)) {
      Get.snackbar(
        'Phone Number',
        'Use a valid number such as +8801XXXXXXXXX or +39XXXXXXXXXX.',
      );
      return false;
    }
    return true;
  }

  void _applyProfile(UserSettingsProfileModel value) {
    profile.value = value;
    fullNameController.text = value.fullName;
    emailController.text = value.email ?? '';
    phoneController.text = value.phone ?? '';
    emailDraft.value = emailController.text;
    phoneDraft.value = phoneController.text;
    if (Get.isRegistered<UserSessionController>()) {
      Get.find<UserSessionController>().updateUser(
        CurrentUserSummary(
          id: value.id,
          fullName: value.fullName,
          learnerLevel: value.learnerLevel,
          currentStreakDays: value.currentStreakDays,
          aiVoiceSeconds: Get.find<UserSessionController>().aiVoiceSeconds,
          aiTextTokens: Get.find<UserSessionController>().aiTextTokens,
          avatarUrl: value.avatarUrl,
        ),
      );
    }
  }

  String _normalizeName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }
}
