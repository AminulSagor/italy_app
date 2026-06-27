import 'package:get/get.dart';

import '../controllers/user_session_controller.dart';

class AppDrawerController extends GetxController {
  AppDrawerController({required UserSessionController userSessionController})
    : _userSessionController = userSessionController;

  final UserSessionController _userSessionController;

  RxBool get isLoading => _userSessionController.isLoading;

  String get displayName => _userSessionController.displayName;
  String get levelLabel => _userSessionController.levelLabel;
  String? get avatarUrl => _userSessionController.avatarUrl;

  @override
  void onInit() {
    super.onInit();
    _userSessionController.loadUser();
  }

  Future<void> refreshProfile({bool showError = false}) async {
    await _userSessionController.loadUser(
      forceRefresh: true,
      showError: showError,
    );
  }

  void clear() => _userSessionController.clear();
}
