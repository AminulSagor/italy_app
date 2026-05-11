import 'package:get/get.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/home/services/home_mock_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeMockService>(() => HomeMockService());
    Get.lazyPut<HomeController>(
      () => HomeController(homeMockService: Get.find<HomeMockService>()),
    );
  }
}
