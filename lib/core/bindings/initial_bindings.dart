import 'package:get/get.dart';
import '../services/services.dart';
class InitialBindings extends Bindings {
  @override
  void dependencies() {
      Get.putAsync<StorageService>(() => StorageService().init());
  }
}