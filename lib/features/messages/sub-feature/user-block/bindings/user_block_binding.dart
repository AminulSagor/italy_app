import 'package:get/get.dart';

import '../service/user_block_api_service.dart';
import '../controllers/user_block_controller.dart';
import '../../../../../core/services/api_client.dart';

class UserBlockBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UserBlockApiService>()) {
      Get.lazyPut<UserBlockApiService>(
        () => UserBlockApiService(apiClient: Get.find<ApiClient>()),
      );
    }

    Get.lazyPut<UserBlockController>(
      () => UserBlockController(apiService: Get.find<UserBlockApiService>()),
    );
  }
}
