import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:get/get.dart';

import '../../../features/drawer_features/language/language_switch_dialogue.dart';
import '../../../features/messages/controllers/messages_controller.dart';
import '../../../features/messages/controllers/message_chat_controller.dart';
import '../../../features/messages/services/messages_service.dart';
import '../../../features/messages/services/chat_socket_service.dart';
import '../../../features/messages/services/presence_service.dart';
import '../../../features/messages/models/message_models.dart';
import '../../services/api_client.dart';
import '../../services/token_service.dart';
import '../../../features/notifications/controllers/notifications_controller.dart';
import '../../../features/notifications/services/notifications_mock_service.dart';
import '../../../features/notifications/views/notifications_bottom_sheet.dart';
import '../../localization/translation_service.dart';
import '../../services/auth_service.dart';
import '../../themes/app_colors.dart';
import '../../../routes/routes.dart';

class NavbarAndAppbarWrapperController extends GetxController
    with WidgetsBindingObserver {
  final TranslationService _translationService = Get.find<TranslationService>();
  final AuthService _authService = Get.find<AuthService>();
  final RxInt currentIndex = 0.obs;
  final RxBool isMessagesPageOpen = false.obs;
  final RxSet<int> visitedTabs = <int>{0}.obs;
  // Presence listener registration flag
  bool _presenceInitialized = false;
  String? _currentUserId;

  void onBottomNavTap(int index) {
    isMessagesPageOpen.value = false;

    if (index == currentIndex.value) {
      return;
    }

    currentIndex.value = index;
    visitedTabs.add(index);
  }

  void openNotifications() {
    if (!Get.isRegistered<NotificationsMockService>()) {
      Get.lazyPut<NotificationsMockService>(() => NotificationsMockService());
    }

    if (Get.isRegistered<NotificationsController>()) {
      Get.delete<NotificationsController>();
    }

    Get.put<NotificationsController>(
      NotificationsController(
        notificationsMockService: Get.find<NotificationsMockService>(),
      ),
    );

    Get.bottomSheet<void>(
      const NotificationsBottomSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.45),
      isDismissible: true,
      enableDrag: true,
    ).whenComplete(() {
      if (Get.isRegistered<NotificationsController>()) {
        Get.delete<NotificationsController>();
      }
    });
  }

  void openMessages() {
    if (!Get.isRegistered<MessagesMockService>()) {
      if (!Get.isRegistered<ChatSocketService>()) {
        Get.lazyPut<ChatSocketService>(
          () => ChatSocketService(tokenService: Get.find<TokenService>()),
        );
      }

      Get.lazyPut<MessagesMockService>(
        () => MessagesMockService(
          apiClient: Get.find<ApiClient>(),
          tokenService: Get.find<TokenService>(),
          chatSocketService: Get.find<ChatSocketService>(),
        ),
      );
    }

    if (!Get.isRegistered<MessagesController>()) {
      Get.put<MessagesController>(
        MessagesController(
          messagesMockService: Get.find<MessagesMockService>(),
        ),
      );
    }

    isMessagesPageOpen.value = true;
    // Ensure a global presence listener is active so threads update in real-time
    _ensurePresenceListener();
  }

  void closeMessages() {
    isMessagesPageOpen.value = false;
  }

  void backToHome() {
    isMessagesPageOpen.value = false;
    onBottomNavTap(0);
  }

  Future<bool> onWillPop() async {
    if (isMessagesPageOpen.value) {
      isMessagesPageOpen.value = false;
      return false;
    }

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
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && isMessagesPageOpen.value) {
      try {
        if (Get.isRegistered<MessagesController>()) {
          Get.find<MessagesController>().refreshMessages();
        }
      } catch (_) {}
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
        String avatar = 'https://i.pravatar.cc/120?img=12';
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

  // drawer callbacks
  Future<void> onLanguageTap(BuildContext context) async {
    final BuildContext dialogContext = Get.context ?? context;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    final AppLanguage? selectedLanguage = await showLanguageDialog(
      context: dialogContext,
      initialLanguage: _translationService.currentLanguage,
    );

    if (selectedLanguage == null) {
      return;
    }

    _translationService.setLanguage(selectedLanguage);
  }

  void onShopTap() {
    Get.toNamed(AppRoutes.shop);
  }

  Future<void> onLogoutTap() async {
    try {
      if (Get.isRegistered<ChatSocketService>()) {
        await Get.find<ChatSocketService>().disconnect();
      }
    } catch (_) {}

    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  String _formatTimeLabel(String? iso) {
    if (iso == null) return '';
    try {
      final DateTime dt = DateTime.parse(iso).toLocal();
      final int hour = dt.hour == 0
          ? 12
          : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final String ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final String minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute $ampm';
    } catch (_) {
      return '';
    }
  }
}
