import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/ai_chat/ai_chat_view.dart';
import '../../../features/cv_generation/views/cv_home_view.dart';
import '../../../features/home/views/home_view.dart';
import '../../../features/leaderboard/views/leaderboard_view.dart';
import '../../../features/messages/controllers/messages_controller.dart';
import '../../../features/messages/sub-feature/call/service/incoming_call_coordinator.dart';
import '../../../features/practice_hub/views/practice_hub_view.dart';

import '../../controllers/user_session_controller.dart';
import '../app_home_bottom_navigation_bar.dart';
import '../app_home_top_bar.dart';
import '../custom_drawer.dart';
import 'navbar_and_appbar_wrapper_controller.dart';

const MethodChannel _systemInsetsChannel =
MethodChannel('italir_pothe/system_insets');

class NavbarAndAppbarWrapper
    extends GetView<NavbarAndAppbarWrapperController> {
  const NavbarAndAppbarWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return _NativeBottomInsetBuilder(
      builder: (
          BuildContext context,
          double nativeBottomInset,
          ) {
        final MediaQueryData mediaQuery =
        MediaQuery.of(context);

        final bool isKeyboardVisible =
            mediaQuery.viewInsets.bottom > 0;

        /*
         * Use whichever inset is larger:
         *
         * 1. Flutter's MediaQuery inset.
         * 2. The native Android WindowInsets value.
         *
         * This prevents Samsung and other Android three-button
         * navigation bars from covering the app navigation bar.
         */
        final double systemBottomInset = math.max(
          mediaQuery.viewPadding.bottom,
          nativeBottomInset,
        );

        final GlobalKey<ScaffoldState> scaffoldKey =
        GlobalKey<ScaffoldState>();

        final UserSessionController session =
        Get.find<UserSessionController>();

        final MessagesController messagesController =
        Get.find<MessagesController>();

        final IncomingCallCoordinator? callCoordinator =
        Get.isRegistered<IncomingCallCoordinator>()
            ? Get.find<IncomingCallCoordinator>()
            : null;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (
              bool didPop,
              Object? result,
              ) async {
            if (didPop) {
              return;
            }

            final bool shouldPop =
            await controller.onWillPop();

            if (shouldPop) {
              Get.back<void>();
            }
          },
          child: Stack(
            children: <Widget>[
              Scaffold(
                key: scaffoldKey,

                // Allows forms and chat inputs to move above the keyboard.
                resizeToAvoidBottomInset: true,

                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(
                    AppHomeTopBar.preferredHeight,
                  ),
                  child: Obx(
                        () => AppHomeTopBar(
                          greeting: controller.greetingKey.value.tr,
                      userName: session.displayName.trim(),
                      avatarUrl: session.avatarUrl,
                      streakLabel:
                      '${session.currentStreakDays}d',
                      showNotificationDot:
                      controller
                          .hasUnreadNotifications
                          .value,
                      messageCount:
                      messagesController
                          .totalUnreadMessageCount,
                      onNotificationTap:
                      controller.openNotifications,
                      onMessageTap:
                      controller.openMessages,
                      onProfileTap: () {
                        FocusManager.instance.primaryFocus
                            ?.unfocus();

                        scaffoldKey.currentState
                            ?.openDrawer();
                      },
                    ),
                  ),
                ),

                onDrawerChanged:
                controller.onDrawerChanged,

                drawer: Obx(
                      () => AppDrawer(
                    onLanguageTap: () {
                      controller.onLanguageTap(context);
                    },
                    onShopTap: controller.onShopTap,
                    onLogoutTap:
                    controller.onLogoutTap,
                    isLoggingOut:
                    controller.isLoggingOut.value,
                  ),
                ),

                body: Obx(
                      () => Stack(
                    fit: StackFit.expand,
                    children: List<Widget>.generate(
                      5,
                          (int index) {
                        final bool isVisited =
                        controller.visitedTabs
                            .contains(index);

                        if (!isVisited) {
                          return const SizedBox.shrink();
                        }

                        final bool isCurrentTab =
                            controller
                                .currentIndex.value ==
                                index;

                        return Offstage(
                          offstage: !isCurrentTab,
                          child: TickerMode(
                            enabled: isCurrentTab,
                            child: _buildTab(index),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                /*
                 * Do not wrap this with SafeArea.
                 *
                 * The native Android inset is applied directly,
                 * avoiding incorrect SafeArea values on affected
                 * Android devices.
                 */
                bottomNavigationBar: isKeyboardVisible
                    ? null
                    : Obx(
                      () => AppHomeBottomNavigationBar(
                    selectedIndex:
                    controller.currentIndex.value,
                    items:
                    AppHomeBottomNavigationBar.defaultItems,
                    onTap: controller.onBottomNavTap,
                  ),
                ),
              ),

              if (callCoordinator != null)
                Obx(
                      () => callCoordinator
                      .isCallTransitioning
                      .value
                      ? const Positioned.fill(
                    child:
                    _CallTransitionBlocker(),
                  )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return const _TabNavigator(
          id: 0,
          content: HomeView(),
        );

      case 1:
        return const _TabNavigator(
          id: 1,
          content: PracticeHubView(),
        );

      case 2:
        return const _TabNavigator(
          id: 2,
          content: AiChatView(),
        );

      case 3:
        return const _TabNavigator(
          id: 3,
          content: LeaderboardView(),
        );

      case 4:
        return const _TabNavigator(
          id: 4,
          content: CvHomeView(),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/*
 * Reads the native Android navigation-bar inset.
 *
 * It refreshes when Android reports a metrics change, such as:
 *
 * - Switching between gesture and three-button navigation.
 * - Rotating the device.
 * - Showing or hiding system bars.
 */
class _NativeBottomInsetBuilder extends StatefulWidget {
  const _NativeBottomInsetBuilder({
    required this.builder,
  });

  final Widget Function(
      BuildContext context,
      double nativeBottomInset,
      ) builder;

  @override
  State<_NativeBottomInsetBuilder> createState() =>
      _NativeBottomInsetBuilderState();
}

class _NativeBottomInsetBuilderState
    extends State<_NativeBottomInsetBuilder>
    with WidgetsBindingObserver {
  double _nativeBottomInset = 0;
  bool _requestInProgress = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        _loadNativeBottomInset();
      },
    );
  }

  @override
  void didChangeMetrics() {
    _loadNativeBottomInset();
  }

  Future<void> _loadNativeBottomInset() async {
    if (_requestInProgress ||
        defaultTargetPlatform !=
            TargetPlatform.android) {
      return;
    }

    _requestInProgress = true;

    try {
      final num? result =
      await _systemInsetsChannel.invokeMethod<num>(
        'getNavigationBarBottomInset',
      );

      final double updatedInset =
      (result?.toDouble() ?? 0)
          .clamp(0, 200)
          .toDouble();

      if (!mounted ||
          updatedInset == _nativeBottomInset) {
        return;
      }

      setState(() {
        _nativeBottomInset = updatedInset;
      });
    } on MissingPluginException {
      // Keep using Flutter's MediaQuery inset.
    } on PlatformException {
      // Keep using Flutter's MediaQuery inset.
    } finally {
      _requestInProgress = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _nativeBottomInset,
    );
  }
}

class _CallTransitionBlocker extends StatelessWidget {
  const _CallTransitionBlocker();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme;

    return Material(
      color: Colors.black45,
      child: AbsorbPointer(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 150,
              maxWidth: 260,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius:
              BorderRadius.circular(18),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'loading'.tr,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabNavigator extends StatelessWidget {
  const _TabNavigator({
    required this.id,
    required this.content,
  });

  final int id;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(id),
      onGenerateRoute: (
          RouteSettings settings,
          ) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => content,
        );
      },
    );
  }
}

class CustomPlaceHolder extends StatelessWidget {
  const CustomPlaceHolder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'placeholder'.tr,
        textAlign: TextAlign.center,
      ),
    );
  }
}