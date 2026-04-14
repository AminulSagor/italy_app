import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../../routes/routes.dart';

class AppBootstrapController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  @override
  void onInit() {
    super.onInit();
    //_bootstrap();
  }

  @override 
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      if (_storageService.isLoggedIn) {
        // Fallback to login if home route is not yet registered.
        if (_isRouteRegistered(AppRoutes.home)) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          await _storageService.clearLoggedInData();
          Get.offAllNamed(AppRoutes.login);
        }
        return;
      }

      if (_storageService.isFirstTimeUser) {
        //await _storageService.setFirstTimeUser(false);
        Get.offAllNamed(AppRoutes.splash);
        return;
      }

      Get.offAllNamed(AppRoutes.login);
    } catch (err) {
      debugPrint('Bootstrap error: $err');
      // Never block users on bootstrap if any initialization path fails.
      Get.offAllNamed(AppRoutes.login);
    }
  }

  bool _isRouteRegistered(String routeName) {
    return AppPages.pages.any((GetPage<dynamic> page) => page.name == routeName);
  }
}