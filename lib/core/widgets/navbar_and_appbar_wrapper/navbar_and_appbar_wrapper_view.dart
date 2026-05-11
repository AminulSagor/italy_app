import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/features/home/views/home_view.dart';
import '../../themes/app_theme.dart';
import '../app_home_top_bar.dart';
import '../app_home_bottom_navigation_bar.dart';
import 'navbar_and_appbar_wrapper_controller.dart';

class NavbarAndAppbarWrapper extends GetView<NavbarAndAppbarWrapperController> {
  const NavbarAndAppbarWrapper({super.key});

  static const List<AppBottomNavItem> _navItems = <AppBottomNavItem>[
    AppBottomNavItem(icon: Icons.home_rounded, semanticLabel: 'Home'),
    AppBottomNavItem(icon: Icons.menu_book_outlined, semanticLabel: 'Lessons'),
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
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await controller.onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Obx(
              () => Stack(
                children: List.generate(5, (index) {
                  final isVisited = controller.visitedTabs.contains(index);

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

        // bottomNavigationBar: Obx(
        //   () => AppHomeBottomNavigationBar(
        //     selectedIndex: controller.currentIndex.value,
        //     items: _navItems,
        //     onTap: controller.onBottomNavTap,
        //   ),
        // ),
      ),
    );
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return _tabNavigator(id: 0, content: const HomeView());
      case 1:
        return _tabNavigator(id: 1, content: const CustomPlaceHolder());
      case 2:
        return _tabNavigator(id: 2, content: const CustomPlaceHolder());
      case 3:
        return _tabNavigator(id: 3, content: const CustomPlaceHolder());
      case 4:
        return _tabNavigator(id: 4, content: const CustomPlaceHolder());
      default:
        return const CustomPlaceHolder();
    }
  }
}

class _tabNavigator extends StatelessWidget {
  final int id;
  final Widget content;

  const _tabNavigator({required this.id, required this.content});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(id),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => AppBarWrapper(id: id, child: content),
      ),
    );
  }
}

class AppBarWrapper extends StatelessWidget {
  final int id;
  final Widget child;
  const AppBarWrapper({super.key, required this.id, required this.child});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHomeTopBar(
        greeting: 'Buongiorno,',
        userName: 'Arif!',
        streakLabel: '🔥 5',
        notificationCount: 3,
        messageCount: 1,
      ),
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
