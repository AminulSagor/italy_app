import 'package:italir_pothe/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/controllers/user_session_controller.dart';
import '../../../core/models/current_user_summary.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/device_push_token_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/token_service.dart';
import '../../../core/services/learning_activity_tracker_service.dart';
import '../../../core/utils/otp_resend_cooldown.dart';
import '../../../core/widgets/app_drawer_controller.dart';
import '../../../routes/routes.dart';
import '../../messages/services/chat_socket_service.dart';
import '../../messages/services/presence_service.dart';
import '../../messages/sub-feature/call/service/incoming_call_coordinator.dart';
import 'models/settings_localization.dart';
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

  // Kept for constructor compatibility with the existing route binding.
  // ignore: unused_field
  final AuthService _authService;
  final ImagePicker _imagePicker = ImagePicker();

  static const int _maximumAvatarBytes = 5 * 1024 * 1024;

  final Rxn<UserSettingsProfileModel> profile = Rxn<UserSettingsProfileModel>();
  final Rxn<XFile> selectedAvatar = Rxn<XFile>();

  final RxBool isLoading = false.obs;
  final RxBool hasProfileLoadError = false.obs;
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
  final RxString otpDraft = ''.obs;

  final OtpResendCooldown contactOtpResendCooldown = OtpResendCooldown();

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
    for (final FocusNode node in otpFocusNodes) {
      node.dispose();
    }
    contactOtpResendCooldown.dispose();
    super.onClose();
  }

  String get displayName {
    final String name = profile.value?.fullName.trim() ?? '';
    return name.isEmpty ? SettingsL10n.text('italian_learner') : name;
  }

  String get primaryContact {
    final UserSettingsProfileModel? value = profile.value;
    return value?.email ?? value?.phone ?? SettingsL10n.text('no_contact');
  }

  String get appVersionLabel {
    final String version = dotenv.env['APP_VERSION']?.trim().isNotEmpty == true
        ? dotenv.env['APP_VERSION']!.trim()
        : '1.0.0';
    return SettingsL10n.text(
      'version',
      params: <String, String>{'version': version},
    );
  }

  int get streakFreezeCount => profile.value?.streakFreezeCount ?? 0;

  bool get selectedContactIsEmail => editProfileTab.value == 'email';

  bool get canChangeSelectedContact {
    final UserSettingsProfileModel? value = profile.value;
    if (value == null) return false;
    return selectedContactIsEmail ? value.canChangeEmail : value.canChangePhone;
  }

  TextEditingController get selectedContactController =>
      selectedContactIsEmail ? emailController : phoneController;

  String get selectedContactValue {
    final String value = selectedContactController.text.trim();
    return selectedContactIsEmail
        ? value.toLowerCase()
        : UserSettingsService.normalizePhone(value);
  }

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

    return UserSettingsService.normalizePhone(phoneDraft.value) !=
        UserSettingsService.normalizePhone(value.phone ?? '');
  }

  String get pendingContactDescription => pendingContactType.value == 'phone'
      ? SettingsL10n.text('phone')
      : SettingsL10n.text('email');

  String get otpCode => otpControllers.map((item) => item.text).join();

  bool get isOtpComplete => RegExp(r'^\d{4}$').hasMatch(otpDraft.value);

  bool get canDeleteAccount {
    final String name = profile.value?.fullName.trim() ?? '';
    if (name.isEmpty) return false;
    return _normalizeName(deleteConfirmText.value) == _normalizeName(name);
  }

  bool get hasValidNewPassword => newPasswordDraft.value.length >= 6;

  bool get hasPasswordMinimumLength => hasValidNewPassword;

  bool get passwordsMatch =>
      newPasswordDraft.value.isNotEmpty &&
      newPasswordDraft.value == confirmPasswordDraft.value;

  bool get isProfileBusy => isSavingName.value || isRequestingContactOtp.value;

  Future<void> loadProfile({bool showError = true}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasProfileLoadError.value = false;
    try {
      final ApiResult<UserSettingsProfileModel> result =
          await ApiErrorHandler.call<UserSettingsProfileModel>(
            _userSettingsService.getProfile,
            showError: showError,
            errorTitle: SettingsL10n.text('profile'),
          );

      if (!result.isSuccess || result.data == null) {
        hasProfileLoadError.value = true;
        return;
      }

      _applyProfile(result.data!);
    } catch (error, stackTrace) {
      hasProfileLoadError.value = true;
      AppLogger.log(
        'Failed to load user settings',
        name: 'SettingsController',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveFullName() async {
    final String fullName = fullNameController.text.trim();
    if (fullName.length < 2) {
      _showMessage('full_name', 'name_too_short');
      return false;
    }
    if (fullName.length > 120) {
      _showMessage('full_name', 'name_too_long');
      return false;
    }

    isSavingName.value = true;
    try {
      final ApiResult<UserSettingsProfileResponseModel> result =
          await ApiErrorHandler.call<UserSettingsProfileResponseModel>(
            () => _userSettingsService.updateFullName(fullName),
            errorTitle: SettingsL10n.text('update_profile'),
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
    if (current == null || isProfileBusy) return ProfileSaveResult.failed;

    final String fullName = fullNameController.text.trim();
    final bool nameChanged = fullName != current.fullName.trim();
    final bool contactChanged = selectedContactChanged;

    if (!nameChanged && !contactChanged) {
      Get.snackbar(
        SettingsL10n.text('edit_profile'),
        SettingsL10n.text('no_changes'),
        snackPosition: SnackPosition.BOTTOM,
      );
      return ProfileSaveResult.noChanges;
    }

    if (nameChanged && !await saveFullName()) {
      return ProfileSaveResult.failed;
    }

    if (contactChanged) {
      final bool requested = await requestSelectedContactChange();
      return requested
          ? ProfileSaveResult.verificationStarted
          : ProfileSaveResult.failed;
    }

    return ProfileSaveResult.saved;
  }

  Future<bool> requestSelectedContactChange({
    bool? isEmailOverride,
    String? valueOverride,
  }) async {
    final bool isEmail = isEmailOverride ?? selectedContactIsEmail;
    final UserSettingsProfileModel? current = profile.value;
    if (current == null || isRequestingContactOtp.value) return false;

    final bool isAllowed = isEmail
        ? current.canChangeEmail
        : current.canChangePhone;
    if (!isAllowed) {
      _showMessage(
        isEmail ? 'email' : 'phone',
        isEmail ? 'email_change_disabled' : 'phone_change_disabled',
      );
      return false;
    }

    final String rawValue = valueOverride?.trim() ?? selectedContactValue;
    final String value = isEmail
        ? rawValue.toLowerCase()
        : UserSettingsService.normalizePhone(rawValue);

    if (!_validateContact(value, isEmail: isEmail)) return false;

    isRequestingContactOtp.value = true;
    try {
      final ApiResult<ContactOtpResponseModel> result =
          await ApiErrorHandler.call<ContactOtpResponseModel>(
            () => isEmail
                ? _userSettingsService.requestEmailChangeOtp(value)
                : _userSettingsService.requestPhoneChangeOtp(value),
            errorTitle: SettingsL10n.text('verify_contact'),
          );

      if (!result.isSuccess || result.data == null) return false;

      pendingContactType.value = result.data!.contactType;
      pendingContactValue.value = result.data!.destination;
      clearOtpFields();
      contactOtpResendCooldown.start();

      final String? devOtp = result.data!.devOtp;
      if (devOtp != null && devOtp.isNotEmpty) {
        Get.snackbar(
          SettingsL10n.text('otp'),
          devOtp,
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      Get.toNamed<void>(AppRoutes.verifyContact);
      return true;
    } finally {
      isRequestingContactOtp.value = false;
    }
  }

  Future<bool> verifyPendingContact() async {
    if (!isOtpComplete) {
      _showMessage('verification_code', 'complete_otp');
      return false;
    }

    final String type = pendingContactType.value;
    final String destination = pendingContactValue.value;
    if ((type != 'email' && type != 'phone') || destination.isEmpty) {
      _showMessage('verify_contact', 'verification_expired');
      return false;
    }

    if (isVerifyingContactOtp.value) return false;
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
            errorTitle: SettingsL10n.text('verify_contact'),
          );

      if (!result.isSuccess || result.data == null) return false;

      _applyProfile(result.data!.profile);
      clearPendingContact();

      isVerifyingContactOtp.value = false;
      Get.offNamed<void>(
        AppRoutes.profileSuccess,
        arguments: <String, String>{
          'type': type == 'phone' ? 'phoneUpdated' : 'emailUpdated',
        },
      );
      return true;
    } finally {
      if (!isClosed && isVerifyingContactOtp.value) {
        isVerifyingContactOtp.value = false;
      }
    }
  }

  Future<void> resendPendingContactOtp() async {
    contactOtpResendCooldown.refresh();
    if (pendingContactValue.value.isEmpty ||
        isResendingContactOtp.value ||
        contactOtpResendCooldown.isActive) {
      return;
    }

    final String type = pendingContactType.value;
    if (type != 'email' && type != 'phone') {
      _showMessage('verify_contact', 'verification_expired');
      return;
    }

    isResendingContactOtp.value = true;
    try {
      final ApiResult<ContactOtpResponseModel> result =
          await ApiErrorHandler.call<ContactOtpResponseModel>(
            () => type == 'phone'
                ? _userSettingsService.requestPhoneChangeOtp(
                    pendingContactValue.value,
                  )
                : _userSettingsService.requestEmailChangeOtp(
                    pendingContactValue.value,
                  ),
            errorTitle: SettingsL10n.text('resend_code'),
          );

      if (!result.isSuccess || result.data == null) return;

      pendingContactType.value = result.data!.contactType;
      pendingContactValue.value = result.data!.destination;
      clearOtpFields();
      contactOtpResendCooldown.start();

      Get.snackbar(
        SettingsL10n.text('verification_code'),
        SettingsL10n.text('code_resent'),
        snackPosition: SnackPosition.BOTTOM,
      );

      final String? devOtp = result.data!.devOtp;
      if (devOtp != null && devOtp.isNotEmpty) {
        Get.snackbar(
          SettingsL10n.text('otp'),
          devOtp,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isResendingContactOtp.value = false;
    }
  }

  void onOtpDigitChanged(int index, String value) {
    otpDraft.value = otpCode;
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
    otpDraft.value = '';
  }

  void clearPendingContact() {
    pendingContactType.value = '';
    pendingContactValue.value = '';
    contactOtpResendCooldown.reset();
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
      if (!await _validateAvatar(image)) return false;
      selectedAvatar.value = image;
      return true;
    } catch (error, stackTrace) {
      AppLogger.log(
        'Could not pick a profile photo',
        name: 'SettingsController',
        error: error,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        SettingsL10n.text('profile_photo'),
        ApiErrorHandler.getErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> uploadSelectedAvatar() async {
    final XFile? image = selectedAvatar.value;
    if (image == null) {
      _showMessage('profile_photo', 'choose_photo_first');
      return false;
    }
    if (!await _validateAvatar(image) || isUploadingAvatar.value) return false;

    isUploadingAvatar.value = true;
    try {
      final ApiResult<UserSettingsProfileResponseModel> result =
          await ApiErrorHandler.call<UserSettingsProfileResponseModel>(
            () => _userSettingsService.uploadAvatar(image),
            errorTitle: SettingsL10n.text('profile_photo'),
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
      _showMessage('change_password', 'current_password_required');
      return false;
    }
    if (!hasValidNewPassword) {
      _showMessage('change_password', 'password_invalid');
      return false;
    }
    if (newPassword != confirmPassword) {
      _showMessage('change_password', 'passwords_do_not_match');
      return false;
    }
    if (isChangingPassword.value) return false;

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
            showError: false,
          );

      if (!result.isSuccess) {
        final String backendMessage = result.error?.trim() ?? '';

        Get.snackbar(
          SettingsL10n.text('change_password'),
          backendMessage.isNotEmpty
              ? backendMessage
              : SettingsL10n.text('request_failed'),
          snackPosition: SnackPosition.BOTTOM,
        );

        return false;
      }
      clearPasswordFields();
      return true;
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> deleteAccountPermanently() async {
    if (!canDeleteAccount || isDeletingAccount.value) {
      if (!canDeleteAccount) {
        _showMessage('delete_account', 'name_does_not_match');
      }
      return;
    }

    final String accountName = profile.value?.fullName.trim() ?? '';
    if (accountName.isEmpty) return;

    isDeletingAccount.value = true;
    bool navigationCompleted = false;

    try {
      final ApiResult<UserSettingsMessageModel> result =
          await ApiErrorHandler.call<UserSettingsMessageModel>(
            () => _userSettingsService.deleteAccount(accountName),
            errorTitle: SettingsL10n.text('delete_account'),
          );

      if (!result.isSuccess) return;

      await _stopAuthenticatedServices();
      await _clearLocalSessionAfterDeletion();

      if (Get.isRegistered<UserSessionController>()) {
        Get.find<UserSessionController>().clear();
      }
      if (Get.isRegistered<AppDrawerController>()) {
        Get.find<AppDrawerController>().clear();
      }

      navigationCompleted = true;
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        SettingsL10n.text('account_deleted'),
        SettingsL10n.text('account_deleted_desc'),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (!navigationCompleted && !isClosed) {
        isDeletingAccount.value = false;
      }
    }
  }

  Future<void> rateUs() async {
    final String configuredAndroidUrl =
        dotenv.env['ANDROID_STORE_URL']?.trim() ?? '';
    final String configuredIosUrl = dotenv.env['IOS_STORE_URL']?.trim() ?? '';

    final String url = defaultTargetPlatform == TargetPlatform.android
        ? (configuredAndroidUrl.isNotEmpty
              ? configuredAndroidUrl
              : 'https://play.google.com/store/apps/details?id=com.shafacode.italir_pothe')
        : configuredIosUrl;

    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      _showMessage('rate_unavailable', 'rate_unavailable_desc');
      return;
    }

    try {
      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        _showMessage('rate_unavailable', 'rate_unavailable_desc');
      }
    } catch (error, stackTrace) {
      AppLogger.log(
        'Could not open app store rating page',
        name: 'SettingsController',
        error: error,
        stackTrace: stackTrace,
      );
      _showMessage('rate_unavailable', 'rate_unavailable_desc');
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
  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.toggle();

  void setEditProfileTab(String tab) {
    if (tab != 'email' && tab != 'phone') return;
    editProfileTab.value = tab;
  }

  void onEmailChanged(String value) => emailDraft.value = value;
  void onPhoneChanged(String value) => phoneDraft.value = value;

  void onSettingsTap() => Get.toNamed(AppRoutes.settings);
  void openProfileSecurity() {
    if (profile.value != null) Get.toNamed(AppRoutes.profileSecurity);
  }

  void changePassword() => Get.toNamed(AppRoutes.changePassword);

  void deleteAccount() {
    if (profile.value == null) return;
    deleteConfirmText.value = '';
    Get.toNamed(AppRoutes.deleteAccountConfirm);
  }

  void openPrivacyPolicy() => Get.toNamed(AppRoutes.privacyPolicy);
  void openTerms() => Get.toNamed(AppRoutes.termsOfService);

  Future<bool> _validateAvatar(XFile image) async {
    final String name = image.name.toLowerCase();
    final String mime = image.mimeType?.toLowerCase() ?? '';
    final bool supported =
        mime == 'image/jpeg' ||
        mime == 'image/png' ||
        mime == 'image/webp' ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp');

    if (!supported) {
      _showMessage('profile_photo', 'unsupported_photo');
      return false;
    }

    final int bytes = await image.length();
    if (bytes <= 0 || bytes > _maximumAvatarBytes) {
      _showMessage('profile_photo', 'photo_too_large');
      return false;
    }
    return true;
  }

  bool _validateContact(String value, {required bool isEmail}) {
    if (isEmail) {
      if (!GetUtils.isEmail(value)) {
        _showMessage('email', 'invalid_email');
        return false;
      }
      return true;
    }

    if (!RegExp(r'^(?:\+8801\d{9}|\+39\d{8,11})$').hasMatch(value)) {
      _showMessage('phone', 'invalid_phone');
      return false;
    }
    return true;
  }

  Future<void> _clearLocalSessionAfterDeletion() async {
    try {
      if (Get.isRegistered<DevicePushTokenService>()) {
        final DevicePushTokenService pushService =
            Get.find<DevicePushTokenService>();
        pushService.disableBackendSync();
        await pushService.deleteLocalFcmToken();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<TokenService>()) {
        await Get.find<TokenService>().clearTokens();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<StorageService>()) {
        await Get.find<StorageService>().clearLoggedInData();
      }
    } catch (_) {}
  }

  Future<void> _stopAuthenticatedServices() async {
    try {
      if (Get.isRegistered<LearningActivityTrackerService>()) {
        await Get.find<LearningActivityTrackerService>().discardSession();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<IncomingCallCoordinator>()) {
        await Get.find<IncomingCallCoordinator>().resetForLogout();
      }
    } catch (_) {}

    bool presenceCleared = false;
    try {
      if (Get.isRegistered<PresenceService>()) {
        await Get.find<PresenceService>().clearForLogout();
        presenceCleared = true;
      }
    } catch (_) {}

    if (!presenceCleared) {
      try {
        if (Get.isRegistered<ChatSocketService>()) {
          await Get.find<ChatSocketService>().disconnect();
        }
      } catch (_) {}
    }
  }

  void _applyProfile(UserSettingsProfileModel value) {
    profile.value = value;
    hasProfileLoadError.value = false;
    fullNameController.text = value.fullName;
    emailController.text = value.email ?? '';
    phoneController.text = value.phone ?? '';
    emailDraft.value = emailController.text;
    phoneDraft.value = phoneController.text;

    if (!value.canChangeEmail && value.canChangePhone) {
      editProfileTab.value = 'phone';
    } else if (!value.canChangePhone && value.canChangeEmail) {
      editProfileTab.value = 'email';
    }

    if (Get.isRegistered<UserSessionController>()) {
      final UserSessionController session = Get.find<UserSessionController>();
      session.updateUser(
        CurrentUserSummary(
          id: value.id,
          fullName: value.fullName,
          learnerLevel: value.learnerLevel,
          currentStreakDays: value.currentStreakDays,
          aiVoiceSeconds: session.aiVoiceSeconds,
          aiTextTokens: session.aiTextTokens,
          avatarUrl: value.avatarUrl,
        ),
      );
    }
  }

  void _showMessage(String titleKey, String messageKey) {
    Get.snackbar(
      SettingsL10n.text(titleKey),
      SettingsL10n.text(messageKey),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _normalizeName(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}
