import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

/// Controller for User Bottom Navigation
/// Tabs: Home, Properties, Appointments, My Deals, Profile
class NavbarAndAppbarWrapperController extends GetxController {
  /// Current selected tab index
  final RxInt currentIndex = 0.obs;

  /// Tracks tabs that have been opened at least once (for lazy tab build)
  final RxSet<int> visitedTabs = <int>{0}.obs;

  /// Change tab
  void onBottomNavTap(int index) {
    if (index == currentIndex.value) {
      return;
    }
    currentIndex.value = index;
    visitedTabs.add(index);
  }

  /// Navigate to notifications page (preserves current tab)
  void goToNotifications() {
    // Get.toNamed(AppRoutes.NOTIFICATIONS);
  }

  void goToMessages() {
    // Get.toNamed(AppRoutes.MESSAGES);
  }

  /// Handle back button - returns true if handled, false to let system handle
  Future<bool> onWillPop() async {
    if (currentIndex.value != 0) {
      onBottomNavTap(0);
      return false;
    }
    return true;
  }
}
