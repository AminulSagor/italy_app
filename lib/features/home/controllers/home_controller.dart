import 'package:get/get.dart';

import '../models/home_models.dart';
import '../services/home_mock_service.dart';

class HomeController extends GetxController {
  final HomeMockService _homeMockService;

  HomeController({required HomeMockService homeMockService})
    : _homeMockService = homeMockService;

  final RxBool isLoading = false.obs;
  final RxInt selectedNavIndex = 0.obs;
  final Rxn<HomeDashboardModel> dashboard = Rxn<HomeDashboardModel>();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      dashboard.value = await _homeMockService.fetchDashboard();
    } finally {
      isLoading.value = false;
    }
  }

  void onBottomNavTap(int index) {
    selectedNavIndex.value = index;
  }
}
