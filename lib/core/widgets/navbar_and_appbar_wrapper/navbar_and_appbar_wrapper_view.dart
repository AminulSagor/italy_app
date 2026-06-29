import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/home/views/home_view.dart';
import '../../controllers/user_session_controller.dart';
import '../../../features/messages/views/messages_view.dart';
import '../../../features/service_hub/views/service_hub_view.dart';
import '../app_home_bottom_navigation_bar.dart';
import '../app_home_top_bar.dart';
import 'navbar_and_appbar_wrapper_controller.dart';
import '../custom_drawer.dart';
import '../../../features/leaderboard/views/leaderboard_view.dart';
import '../../../features/ai_chat/ai_chat_view.dart';
import '../../../features/practice_hub/views/practice_hub_view.dart';

class NavbarAndAppbarWrapper extends GetView<NavbarAndAppbarWrapperController> {
  const NavbarAndAppbarWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool shouldPop = await controller.onWillPop();
        if (shouldPop) {
          Get.back<void>();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: scaffoldKey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Obx(() {
            final UserSessionController session =
                Get.find<UserSessionController>();
            return AppHomeTopBar(
              greeting: 'Buongiorno,',
              userName: session.displayName,
              avatarUrl: session.avatarUrl,
              streakLabel: '${session.currentStreakDays}d',
              showNotificationDot:
                  controller.hasUnreadNotifications.value,
              messageCount: 0,
              onNotificationTap: controller.openNotifications,
              onMessageTap: controller.openMessages,
              onProfileTap: () => scaffoldKey.currentState?.openDrawer(),
            );
          }),
        ),
        onDrawerChanged: controller.onDrawerChanged,
        drawer: AppDrawer(
          onLanguageTap: () => controller.onLanguageTap(context),
          onShopTap: controller.onShopTap,
          onLogoutTap: controller.onLogoutTap,
        ),
        body: Stack(
          children: <Widget>[
            Obx(
              () => Stack(
                children: List<Widget>.generate(5, (int index) {
                  final bool isVisited = controller.visitedTabs.contains(index);

                  if (!isVisited) {
                    return const SizedBox.shrink();
                  }

                  return Offstage(
                    offstage: controller.currentIndex.value != index,
                    child: TickerMode(
                      enabled: controller.currentIndex.value == index,
                      child: _buildTab(index),
                    ),
                  );
                }),
              ),
            ),
            Obx(
              () => controller.isMessagesPageOpen.value
                  ? Positioned.fill(
                      child: MessagesView(onBackTap: controller.closeMessages),
                    )
                  : const SizedBox.shrink(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Obx(
                () => AppHomeBottomNavigationBar(
                  selectedIndex: controller.currentIndex.value,
                  items: AppHomeBottomNavigationBar.defaultItems,
                  onTap: controller.onBottomNavTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return _TabNavigator(id: 0, content: const HomeView());
      case 1:
        return _TabNavigator(id: 1, content: const PracticeHubView());
      case 2:
        return _TabNavigator(id: 2, content: const AiChatView());
      case 3:
        return _TabNavigator(id: 3, content: const LeaderboardView());
      case 4:
        return _TabNavigator(id: 4, content: const ServiceHubView());
      default:
        return const CustomPlaceHolder();
    }
  }
}

class _TabNavigator extends StatelessWidget {
  final int id;
  final Widget content;

  const _TabNavigator({required this.id, required this.content});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(id),
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => content),
    );
  }
}

class CustomPlaceHolder extends StatelessWidget {
  const CustomPlaceHolder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Placeholder'));
  }
}
