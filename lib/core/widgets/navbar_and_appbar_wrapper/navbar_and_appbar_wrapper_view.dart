import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/home/views/home_view.dart';
import '../../../features/messages/views/messages_view.dart';
import '../app_home_bottom_navigation_bar.dart';
import '../app_home_top_bar.dart';
import 'navbar_and_appbar_wrapper_controller.dart';

class NavbarAndAppbarWrapper extends GetView<NavbarAndAppbarWrapperController> {
  const NavbarAndAppbarWrapper({super.key});

  static const List<AppBottomNavItem> _navItems = <AppBottomNavItem>[
    AppBottomNavItem(icon: Icons.home_rounded, semanticLabel: 'Home'),
    AppBottomNavItem(icon: Icons.menu_book_outlined, semanticLabel: 'Messages'),
    AppBottomNavItem(
      icon: Icons.auto_awesome_rounded,
      semanticLabel: 'AI Tutor',
    ),
    AppBottomNavItem(
      icon: Icons.emoji_events_outlined,
      semanticLabel: 'Progress',
    ),
    AppBottomNavItem(icon: Icons.handyman_outlined, semanticLabel: 'Tools'),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool shouldPop = await controller.onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
                  items: _navItems,
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
        return _TabNavigator(
          id: 0,
          content: const HomeView(),
          onNotificationTap: controller.openNotifications,
          onMessageTap: controller.openMessages,
        );
      case 1:
        return _TabNavigator(
          id: 1,
          content: const CustomPlaceHolder(),
          onNotificationTap: controller.openNotifications,
          onMessageTap: controller.openMessages,
        );
      case 2:
        return _TabNavigator(
          id: 2,
          content: const CustomPlaceHolder(),
          onNotificationTap: controller.openNotifications,
          onMessageTap: controller.openMessages,
        );
      case 3:
        return _TabNavigator(
          id: 3,
          content: const CustomPlaceHolder(),
          onNotificationTap: controller.openNotifications,
          onMessageTap: controller.openMessages,
        );
      case 4:
        return _TabNavigator(
          id: 4,
          content: const CustomPlaceHolder(),
          onNotificationTap: controller.openNotifications,
          onMessageTap: controller.openMessages,
        );
      default:
        return const CustomPlaceHolder();
    }
  }
}

class _TabNavigator extends StatelessWidget {
  final int id;
  final Widget content;
  final bool showTopBar;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMessageTap;

  const _TabNavigator({
    required this.id,
    required this.content,
    this.showTopBar = true,
    this.onNotificationTap,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(id),
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => AppBarWrapper(
          showTopBar: showTopBar,
          onNotificationTap: onNotificationTap,
          onMessageTap: onMessageTap,
          child: content,
        ),
      ),
    );
  }
}

class AppBarWrapper extends StatelessWidget {
  final Widget child;
  final bool showTopBar;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMessageTap;

  const AppBarWrapper({
    super.key,
    required this.child,
    this.showTopBar = true,
    this.onNotificationTap,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showTopBar
          ? AppHomeTopBar(
              greeting: 'Buongiorno,',
              userName: 'Arif!',
              streakLabel: '🔥 5',
              notificationCount: 3,
              messageCount: 1,
              onNotificationTap: onNotificationTap,
              onMessageTap: onMessageTap,
            )
          : null,
      body: child,
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
