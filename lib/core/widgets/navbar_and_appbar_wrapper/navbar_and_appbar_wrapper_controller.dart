import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../features/drawer_features/language/language_switch_dialogue.dart';
import '../../../features/home/controllers/home_controller.dart';
import '../../../features/leaderboard/controllers/leaderboard_controller.dart';
import '../../../features/messages/controllers/messages_controller.dart';
import '../../../features/messages/controllers/messages_controller_navigation.dart';
import '../../../features/messages/controllers/message_chat_controller.dart';
import '../../../features/messages/services/messages_service.dart';
import '../../../features/messages/services/chat_socket_service.dart';
import '../../../features/messages/services/presence_service.dart';
import '../../../features/messages/models/message_models.dart';
import '../../../features/messages/sub-feature/call/controllers/message_call_controller.dart';
import '../../../features/messages/sub-feature/call/service/call_socket_service.dart';
import '../../../features/messages/sub-feature/call/service/incoming_call_coordinator.dart';
import '../../../features/practice_hub/controllers/practice_hub_controller.dart';
import '../../services/api_client.dart';
import '../../controllers/user_session_controller.dart';
import '../../services/api_error_handler.dart';
import '../../services/learning_activity_tracker_service.dart';
import '../../services/notification_deep_link_service.dart';
import '../../services/notification_summary_service.dart';
import '../../services/token_service.dart';
import '../../../features/notifications/controllers/notifications_controller.dart';
import '../../../features/notifications/models/notification_models.dart';
import '../../../features/notifications/services/notifications_api_service.dart';
import '../../../features/notifications/views/notifications_bottom_sheet.dart';
import '../../localization/translation_service.dart';
import '../../services/auth_service.dart';
import '../../themes/app_colors.dart';
import '../app_drawer_controller.dart';
import '../../../routes/routes.dart';

class NavbarAndAppbarWrapperController extends GetxController
    with WidgetsBindingObserver {
  final TranslationService _translationService = Get.find<TranslationService>();
  final AuthService _authService = Get.find<AuthService>();
  final RxInt currentIndex = 0.obs;
  final RxBool hasUnreadNotifications = false.obs;
  final RxSet<int> visitedTabs = <int>{0}.obs;
  final RxBool isLoggingOut = false.obs;
  // Presence listener registration flag
  bool _presenceInitialized = false;
  String? _currentUserId;
  int _notificationRefreshVersion = 0;

  void onBottomNavTap(int index) {
    if (index == currentIndex.value) {
      if (Get.isRegistered<LearningActivityTrackerService>()) {
        Get.find<LearningActivityTrackerService>().setShellTab(index);
      }
      if (index == 0) {
        unawaited(refreshHomeDashboard());
      }
      _refreshLeaderboardIfNeeded(index);
      return;
    }

    currentIndex.value = index;
    visitedTabs.add(index);
    if (Get.isRegistered<LearningActivityTrackerService>()) {
      Get.find<LearningActivityTrackerService>().setShellTab(index);
    }
    if (index == 0) {
      unawaited(refreshHomeDashboard());
    }
    _refreshLeaderboardIfNeeded(index);
  }

  void _refreshLeaderboardIfNeeded(int index) {
    if (index != 3) return;
    Future<void>.microtask(() async {
      if (Get.isRegistered<LeaderboardController>()) {
        await Get.find<LeaderboardController>().refreshLeaderboard();
      }
    });
  }

  Future<void> refreshHomeDashboard() async {
    await Future<void>.delayed(Duration.zero);
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().loadDashboard();
    }
  }

  void openNotifications() {
    if (!Get.isRegistered<NotificationsApiService>()) {
      Get.lazyPut<NotificationsApiService>(
        () => NotificationsApiService(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (Get.isRegistered<NotificationsController>()) {
      Get.delete<NotificationsController>();
    }
    final NotificationsController notificationsController =
        Get.put<NotificationsController>(
          NotificationsController(
            notificationsApiService: Get.find<NotificationsApiService>(),
            onNotificationOpen: _openNotificationDestination,
            onUnreadStateChanged: (bool hasUnread) {
              /*
   * The NotificationsController already knows the
   * latest state after mark-read/mark-all-read.
   * Update the app-bar dot immediately.
   */
              _notificationRefreshVersion++;

              hasUnreadNotifications.value = hasUnread;
            },
          ),
        );
    Get.bottomSheet<void>(
      NotificationsBottomSheet(controller: notificationsController),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.45),
      isDismissible: true,
      enableDrag: true,
    ).whenComplete(() async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (Get.isRegistered<NotificationsController>() &&
          identical(
            Get.find<NotificationsController>(),
            notificationsController,
          )) {
        Get.delete<NotificationsController>();
      }
      refreshNotificationState();
    });
  }

  Future<void> _openNotificationDestination(
    NotificationItemModel notification,
  ) async {
    final String deepLink = notification.deepLink.trim();
    if (Get.isBottomSheetOpen ?? false) {
      Get.back<void>();
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }
    if (deepLink.isEmpty) {
      return;
    }

    final bool handled = await NotificationDeepLinkService.open(deepLink);

    if (handled) {
      return;
    }

    final Uri? uri = Uri.tryParse(deepLink);
    final String path = uri?.path.toLowerCase() ?? deepLink.toLowerCase();
    final String host = uri?.host.toLowerCase() ?? '';

    if (path.startsWith('/messages') || host == 'messages') {
      final String conversationId =
          uri?.queryParameters['conversationId']?.trim() ?? '';
      openMessages();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (conversationId.isNotEmpty && Get.isRegistered<MessagesController>()) {
        final bool opened = await Get.find<MessagesController>()
            .openConversationById(conversationId);
        if (!opened) {
          Get.snackbar('Messages', 'The conversation could not be opened.');
        }
      }
      return;
    }

    if (path.startsWith('/daily-challenges') ||
        path.startsWith('/practice-hub') ||
        notification.eventType == 'streak_reminder') {
      onBottomNavTap(1);
      return;
    }

    if (path.startsWith('/webinar') || host == 'webinar') {
      await Get.toNamed(
        AppRoutes.webinar,
        parameters: uri?.queryParameters ?? const <String, String>{},
      );
      return;
    }

    if (path.startsWith('/courses') ||
        host == 'final-exams' ||
        host == 'certificates') {
      onBottomNavTap(1);
      return;
    }

    if (path.startsWith('/ai-tutor') ||
        path.startsWith('/ai-chat') ||
        host == 'ai-tutor') {
      onBottomNavTap(2);
      return;
    }
    if (path.startsWith('/leaderboard') || host == 'leaderboard') {
      onBottomNavTap(3);
      return;
    }

    if (path.startsWith('/service-hub') ||
        path.startsWith('/cv-builder') ||
        host == 'cv-builder') {
      onBottomNavTap(4);
      return;
    }
    if (path.startsWith('/rewards') || host == 'rewards') {
      await Get.toNamed(AppRoutes.rewards);
      return;
    }
    if (path.startsWith(AppRoutes.shop)) {
      await Get.toNamed(AppRoutes.shop);
      return;
    }
    if (path.startsWith(AppRoutes.settings)) {
      await Get.toNamed(AppRoutes.settings);
      return;
    }
    if (path.startsWith(AppRoutes.guide)) {
      await Get.toNamed(AppRoutes.guide);
      return;
    }
    if (path.startsWith(AppRoutes.contactSupport)) {
      await Get.toNamed(AppRoutes.contactSupport);
      return;
    }

    onBottomNavTap(0);
  }

  void openMessages() {
    Get.toNamed<void>(AppRoutes.messages);
  }

  Future<bool> onWillPop() async {
    if (currentIndex.value != 0) {
      onBottomNavTap(0);
      return false;
    }

    return true;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initCurrentUserId();
    _ensurePresenceListener();
    if (Get.isRegistered<UserSessionController>()) {
      Get.find<UserSessionController>().loadUser();
    }
    if (Get.isRegistered<LearningActivityTrackerService>()) {
      Get.find<LearningActivityTrackerService>().setShellTab(
        currentIndex.value,
      );
    }
    refreshNotificationState();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state != AppLifecycleState.resumed ||
        Get.currentRoute != AppRoutes.messages) {
      return;
    }

    if (Get.isRegistered<MessagesController>()) {
      Get.find<MessagesController>().refreshMessages();
    }
  }

  Future<void> _initCurrentUserId() async {
    try {
      final TokenService ts = Get.find<TokenService>();
      final String? token = await ts.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final List<String> parts = token.split('.');
        if (parts.length >= 2) {
          final String payload = parts[1];
          final String normalized = base64Url.normalize(payload);
          final String decoded = utf8.decode(base64Url.decode(normalized));
          final Map<String, dynamic> map =
              json.decode(decoded) as Map<String, dynamic>;
          _currentUserId = map['sub']?.toString();
        }
      }
    } catch (_) {
      _currentUserId = null;
    }
  }

  Future<void> _ensurePresenceListener() async {
    if (_presenceInitialized) return;
    _presenceInitialized = true;
    try {
      if (!Get.isRegistered<ChatSocketService>()) {
        Get.lazyPut<ChatSocketService>(
          () => ChatSocketService(tokenService: Get.find<TokenService>()),
        );
      }

      final ChatSocketService svc = Get.find<ChatSocketService>();

      String? deviceId;
      try {
        if (Get.isRegistered<PresenceService>()) {
          final PresenceService ps = Get.find<PresenceService>();
          // Wait briefly for deviceId initialization
          for (int i = 0; i < 20 && ps.deviceId.isEmpty; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
          deviceId = ps.deviceId.isNotEmpty ? ps.deviceId : null;
        }
      } catch (_) {
        deviceId = null;
      }

      await svc.connect(
        deviceId: deviceId,
        onMessage: (Map<String, dynamic> data) {
          _handleIncomingMessage(data);
        },
        onReceiveMessage: (Map<String, dynamic> data) {
          _handleIncomingMessage(data);
        },
        onNewMessage: (Map<String, dynamic> data) {
          _handleIncomingMessage(data);
        },
        onPresenceChange: (Map<String, dynamic> data) {
          try {
            if (Get.isRegistered<PresenceService>()) {
              Get.find<PresenceService>().updatePresenceFromSocket(data);
            }
          } catch (_) {}
        },
        onBlockChange: (Map<String, dynamic> data) {
          try {
            final String userId =
                data['userId']?.toString() ??
                data['blockedUserId']?.toString() ??
                '';
            final String status =
                data['status']?.toString() ??
                data['blockStatus']?.toString() ??
                '';
            if (Get.isRegistered<MessagesController>()) {
              final MessagesController mc = Get.find<MessagesController>();
              final int idx = mc.threads.indexWhere(
                (MessageThreadModel t) =>
                    t.id == userId || t.contactId == userId,
              );
              if (idx >= 0) {
                final MessageThreadModel oldThread = mc.threads[idx];
                final MessageThreadModel updatedThread = oldThread.copyWith(
                  blockStatus: status,
                );
                mc.threads[idx] = updatedThread;
                mc.threads.refresh();
              }
            }
          } catch (_) {}
        },
      );
    } catch (_) {}
  }

  void _handleIncomingMessage(Map<String, dynamic> data) {
    try {
      final String convId =
          data['conversationId']?.toString() ??
          data['conversation_id']?.toString() ??
          '';
      final String senderId =
          data['senderId']?.toString() ?? data['userId']?.toString() ?? '';
      final String content =
          data['content']?.toString() ?? data['text']?.toString() ?? '';
      final String createdAt =
          data['createdAt']?.toString() ??
          data['created_at']?.toString() ??
          DateTime.now().toIso8601String();
      final bool isMine =
          senderId.isNotEmpty && senderId == (_currentUserId ?? '');

      if (!Get.isRegistered<MessagesController>()) return;
      final MessagesController mc = Get.find<MessagesController>();

      int idx = mc.threads.indexWhere(
        (t) =>
            t.id == convId ||
            t.contactId == convId ||
            t.contactId == senderId ||
            t.id == senderId,
      );

      bool isChatOpenForThis = false;
      try {
        if (Get.isRegistered<MessageChatController>()) {
          final MessageChatController chatCtrl =
              Get.find<MessageChatController>();
          if (chatCtrl.thread.id == convId ||
              chatCtrl.thread.contactId == convId ||
              chatCtrl.thread.contactId == senderId ||
              chatCtrl.thread.id == senderId) {
            isChatOpenForThis = true;
          }
        }
      } catch (_) {}

      if (idx >= 0) {
        final MessageThreadModel oldThread = mc.threads[idx];
        int newUnread = oldThread.unreadCount;
        if (!isMine && !isChatOpenForThis) {
          newUnread = oldThread.unreadCount + 1;
        } else {
          newUnread = 0;
        }

        final MessageThreadModel updatedThread = oldThread.copyWith(
          lastMessage: content,
          timeLabel: _formatTimeLabel(createdAt),
          unreadCount: newUnread,
          isHighlighted: !isMine && newUnread > 0,
        );

        mc.threads.removeAt(idx);
        mc.threads.insert(0, updatedThread);
        mc.threads.refresh();
      } else {
        final String id = convId.isNotEmpty
            ? convId
            : (senderId.isNotEmpty
                  ? senderId
                  : DateTime.now().millisecondsSinceEpoch.toString());
        String avatar = '';
        String name = 'Conversation';

        final MessageThreadModel newThread = MessageThreadModel(
          id: id,
          learnerName: name,
          lastMessage: content,
          timeLabel: _formatTimeLabel(createdAt),
          unreadCount: isMine ? 0 : 1,
          isOnline: false,
          blockStatus: 'none',
          isHighlighted: !isMine,
          isDelivered: true,
          avatarUrl: avatar,
          contactId: senderId.isNotEmpty ? senderId : null,
        );

        mc.threads.insert(0, newThread);
        mc.threads.refresh();

        try {
          if (Get.isRegistered<MessagesMockService>()) {
            final MessagesMockService msvc = Get.find<MessagesMockService>();
            msvc
                .fetchUserProfile(
                  senderId,
                  fallbackName: name,
                  fallbackAvatarUrl: avatar,
                )
                .then((profile) {
                  try {
                    final int updateIndex = mc.threads.indexWhere(
                      (t) => t.id == id || t.contactId == senderId,
                    );
                    if (updateIndex >= 0) {
                      final MessageThreadModel existing =
                          mc.threads[updateIndex];
                      mc.threads[updateIndex] = existing.copyWith(
                        learnerName: profile.name,
                        avatarUrl: profile.avatarUrl,
                      );
                      mc.threads.refresh();
                    }
                  } catch (_) {}
                });
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _refreshLocalizedCardData() async {
    final List<Future<void>> refreshTasks = <Future<void>>[];

    if (Get.isRegistered<HomeController>()) {
      refreshTasks.add(
        Get.find<HomeController>().loadDashboard(
          force: true,
        ),
      );
    }

    if (Get.isRegistered<PracticeHubController>()) {
      refreshTasks.add(
        Get.find<PracticeHubController>().refreshPracticeHub(),
      );
    }

    if (refreshTasks.isEmpty) {
      return;
    }

    await Future.wait<void>(refreshTasks);
  }

  // drawer callbacks
  Future<void> onLanguageTap(BuildContext context) async {
    final BuildContext dialogContext =
        Get.context ?? context;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    final AppLanguage previousLanguage =
        _translationService.currentLanguage;

    final AppLanguage? selectedLanguage =
    await showLanguageDialog(
      context: dialogContext,
      initialLanguage: previousLanguage,
    );

    if (selectedLanguage == null ||
        selectedLanguage == previousLanguage) {
      return;
    }

    // Direct .tr widgets update immediately here.
    await _translationService.setLanguage(
      selectedLanguage,
    );

    // Rebuild model/service-generated translated card content.
    await _refreshLocalizedCardData();
  }

  void onShopTap() {
    Get.toNamed(AppRoutes.shop);
  }

  Future<void> refreshNotificationState() async {
    if (!Get.isRegistered<NotificationSummaryService>()) {
      return;
    }

    final int requestVersion = ++_notificationRefreshVersion;

    final ApiResult<bool> result = await ApiErrorHandler.call<bool>(
      Get.find<NotificationSummaryService>().hasUnreadNotifications,
      showError: false,
    );

    /*
   * Ignore an older request when a newer local
   * or server notification state already exists.
   */
    if (requestVersion != _notificationRefreshVersion) {
      return;
    }

    if (result.isSuccess && result.data != null) {
      hasUnreadNotifications.value = result.data!;
    }
  }

  void onDrawerChanged(bool isOpened) {
    if (!isOpened || !Get.isRegistered<AppDrawerController>()) return;
    unawaited(Get.find<AppDrawerController>().refreshProfile());
  }

  Future<void> onLogoutTap() async {
    if (isLoggingOut.value) {
      return;
    }

    isLoggingOut.value = true;

    try {
      /*
     * End an active call before removing the JWT.
     */
      try {
        if (Get.isRegistered<MessageCallController>()) {
          await Get.find<MessageCallController>().endCall().timeout(
            const Duration(seconds: 3),
            onTimeout: () {},
          );
        }
      } catch (_) {}

      /*
     * Close native CallKit screens and clear pending
     * incoming-call actions.
     */
      try {
        if (Get.isRegistered<IncomingCallCoordinator>()) {
          await Get.find<IncomingCallCoordinator>().resetForLogout();
        }
      } catch (_) {}

      /*
     * Disconnect the call socket.
     */
      try {
        if (Get.isRegistered<CallSocketService>()) {
          await Get.find<CallSocketService>().disconnect();
        }
      } catch (_) {}

      /*
     * Disconnect chat and clear cached presence.
     */
      try {
        if (Get.isRegistered<PresenceService>()) {
          await Get.find<PresenceService>().clearForLogout();
        } else if (Get.isRegistered<ChatSocketService>()) {
          await Get.find<ChatSocketService>().disconnect();
        }
      } catch (_) {}

      /*
     * End the learning session while the JWT is
     * still available.
     */
      try {
        if (Get.isRegistered<LearningActivityTrackerService>()) {
          await Get.find<LearningActivityTrackerService>().endSession();
        }
      } catch (_) {}

      /*
     * Calls POST /auth/logout before deleting
     * the local JWT.
     */
      await _authService.logout();
    } catch (_) {
      /*
     * Network failure must not prevent local logout.
     */
    } finally {
      /*
     * These are permanent/global controllers, so clear
     * their logged-in user information manually.
     */
      if (Get.isRegistered<UserSessionController>()) {
        Get.find<UserSessionController>().clear();
      }

      if (Get.isRegistered<AppDrawerController>()) {
        Get.find<AppDrawerController>().clear();
      }

      /*
     * Do not manually delete screen controllers here.
     *
     * GetX will dispose them after the wrapper route is
     * removed. Deleting them before navigation disposes
     * their TextEditingControllers while TextFields are
     * still mounted.
     */

      /*
     * The API interceptor might already have opened the
     * login route after receiving a 401. Avoid navigating
     * to login a second time.
     */
      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }

  String _formatTimeLabel(String? iso) {
    if (iso == null) return '';
    try {
      final DateTime dt = DateTime.parse(iso).toLocal();
      final int hour = dt.hour == 0
          ? 12
          : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final String ampm = dt.hour >= 12 ? 'pm'.tr : 'am'.tr;
      final String minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute $ampm';
    } catch (_) {
      return '';
    }
  }
}
