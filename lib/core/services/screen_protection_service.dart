import 'package:get/get.dart';
import 'package:screen_protector/screen_protector.dart';

class ScreenProtectionService extends GetxService {
  bool _isProtected = false;

  Future<void> updateForRoute(String? routeName) async {
    final String route = routeName?.trim() ?? '';

    // Keep the current protection state for unnamed nested routes.
    if (route.isEmpty) return;

    final bool shouldProtect =
        route == '/courses' || route.startsWith('/courses/');


    if (_isProtected == shouldProtect) return;

    _isProtected = shouldProtect;

    if (shouldProtect) {
      await ScreenProtector.preventScreenshotOn();
    } else {
      await ScreenProtector.preventScreenshotOff();
    }
  }

  Future<void> enable() async {
    if (_isProtected) return;
    _isProtected = true;
    await ScreenProtector.preventScreenshotOn();
  }

  Future<void> disable() async {
    if (!_isProtected) {
      return;
    }

    _isProtected = false;
    await ScreenProtector.preventScreenshotOff();
  }

  @override
  void onClose() {
    ScreenProtector.preventScreenshotOff();
    super.onClose();
  }
}