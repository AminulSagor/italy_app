import 'dart:async';
import 'package:italir_pothe/core/utils/app_logger.dart';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../features/messages/views/message_chat_view.dart';
import '../../features/messages/controllers/message_chat_controller.dart';
import '../../features/messages/models/message_models.dart';
import '../../features/messages/services/messages_service.dart';
import 'notification_deep_link_service.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  static const String _channelId = 'admin_notifications';
  static const String _channelName = 'Admin Notifications';
  static const String _channelDescription =
      'Notifications sent from the Italir Pothe admin panel';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _isListening = false;

  /// Conversation IDs that should NOT show local notifications because the
  /// user is actively viewing that conversation in the chat screen.
  final Set<String> _suppressedConversationIds = <String>{};

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    importance: Importance.max,
  );

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    _isInitialized = true;

    AppLogger.log(
      'Local notification service initialized',
      name: 'LocalNotificationService',
    );
  }

  void listenToForegroundMessages() {
    if (_isListening) {
      return;
    }

    _isListening = true;

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        AppLogger.log(
          'Foreground FCM received: '
          'title=${message.notification?.title}, '
          'body=${message.notification?.body}, '
          'data=${message.data}',
          name: 'LocalNotificationService',
        );

        final String moderationDeepLink =
            message.data['deepLink']?.toString().trim() ?? '';

        if (await NotificationDeepLinkService.openAccountRestriction(
          moderationDeepLink,
        )) {
          return;
        }

        // Reward notifications are sent only after the backend has granted
        // the reward, so use the push as an immediate cache-refresh signal.
        unawaited(
          NotificationDeepLinkService.refreshRewardDataIfNeeded(
            moderationDeepLink,
          ).catchError((Object error, StackTrace stackTrace) {
            AppLogger.log(
              'Reward push refresh failed',
              error: error,
              stackTrace: stackTrace,
              name: 'LocalNotificationService',
            );
          }),
        );

        // Skip displaying the notification if the user is currently viewing
        // the conversation that this message belongs to.
        final String? conversationId = message.data['conversationId']
            ?.toString();
        if (conversationId != null &&
            _suppressedConversationIds.contains(conversationId)) {
          AppLogger.log(
            'Suppressing notification for active conversation: '
            '$conversationId',
            name: 'LocalNotificationService',
          );
          return;
        }

        await showRemoteMessage(message);
      },
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.log(
          'Foreground FCM listener failed',
          error: error,
          stackTrace: stackTrace,
          name: 'LocalNotificationService',
        );
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.log(
        'FCM Notification tapped from background: data=${message.data}',
        name: 'LocalNotificationService',
      );
      _handleFCMTap(message);
    });

    _checkInitialMessage();
  }

  Future<void> _checkInitialMessage() async {
    try {
      final RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        AppLogger.log(
          'FCM Notification tapped from terminated state: data=${initialMessage.data}',
          name: 'LocalNotificationService',
        );
        // Add a slight delay to allow the app to finish bootstrapping before navigating
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleFCMTap(initialMessage);
        });
      }
    } catch (e) {
      AppLogger.log('Error checking initial message: $e');
    }
  }

  void _handleFCMTap(RemoteMessage message) {
    final String deepLink = message.data['deepLink']?.toString().trim() ?? '';
    final String conversationId =
        message.data['conversationId']?.toString().trim() ?? '';
    final String contactId = message.data['senderId']?.toString().trim() ?? '';
    final String contactName =
        message.data['senderName']?.toString().trim() ?? 'User';

    if (conversationId.isNotEmpty) {
      final String payloadString = jsonEncode({
        'conversationId': conversationId,
        'contactId': contactId,
        'contactName': contactName,
        'deepLink': deepLink,
      });
      // Mock a NotificationResponse with the payload and call our existing handler
      _handleNotificationTap(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: payloadString,
        ),
      );
    } else if (deepLink.isNotEmpty) {
      _handleNotificationTap(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: deepLink,
        ),
      );
    }
  }

  Future<void> showRemoteMessage(RemoteMessage message) async {
    final String title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'Italir Pothe';

    final String body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';

    if (body.isEmpty) {
      return;
    }

    final String imageUrl = _extractImageUrl(message);

    final String? localImagePath = imageUrl.isEmpty
        ? null
        : await _downloadImage(imageUrl);

    final String conversationId =
        message.data['conversationId']?.toString().trim() ?? '';

    final bool showReplyAction = conversationId.isNotEmpty;

    final AndroidNotificationDetails androidDetails = _createAndroidDetails(
      title: title,
      body: body,
      localImagePath: localImagePath,
      showReplyAction: showReplyAction,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: localImagePath == null
          ? null
          : <DarwinNotificationAttachment>[
              DarwinNotificationAttachment(localImagePath),
            ],
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String deepLink = message.data['deepLink']?.toString().trim() ?? '';

    final String contactId = message.data['senderId']?.toString().trim() ?? '';
    final String contactName =
        message.data['senderName']?.toString().trim() ?? title;

    // We pass a JSON payload if we have a conversationId, otherwise just the deepLink
    String? payloadString;
    if (conversationId.isNotEmpty) {
      payloadString = jsonEncode({
        'conversationId': conversationId,
        'contactId': contactId,
        'contactName': contactName,
        'deepLink': deepLink,
      });
    } else if (deepLink.isNotEmpty) {
      payloadString = deepLink;
    }

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payloadString,
    );
  }

  AndroidNotificationDetails _createAndroidDetails({
    required String title,
    required String body,
    required String? localImagePath,
    required bool showReplyAction,
  }) {
    final List<AndroidNotificationAction> actions = showReplyAction
        ? <AndroidNotificationAction>[
            AndroidNotificationAction(
              'REPLY_ACTION',
              'Reply',
              icon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              inputs: <AndroidNotificationActionInput>[
                AndroidNotificationActionInput(label: 'gen_type_a_message'.tr),
              ],
            ),
          ]
        : <AndroidNotificationAction>[];

    if (localImagePath == null) {
      return AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        actions: actions,
      );
    }

    return AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      actions: actions,
      styleInformation: BigPictureStyleInformation(
        FilePathAndroidBitmap(localImagePath),
        contentTitle: title,
        summaryText: body,
        hideExpandedLargeIcon: true,
      ),
    );
  }

  String _extractImageUrl(RemoteMessage message) {
    final String dataImageUrl =
        message.data['imageUrl']?.toString().trim() ?? '';

    if (dataImageUrl.isNotEmpty) {
      return dataImageUrl;
    }

    final String androidImageUrl =
        message.notification?.android?.imageUrl?.trim() ?? '';

    if (androidImageUrl.isNotEmpty) {
      return androidImageUrl;
    }

    return message.notification?.apple?.imageUrl?.trim() ?? '';
  }

  Future<String?> _downloadImage(String imageUrl) async {
    final Uri? uri = Uri.tryParse(imageUrl);

    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      AppLogger.log(
        'Invalid notification image URL: $imageUrl',
        name: 'LocalNotificationService',
      );

      return null;
    }

    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    try {
      final HttpClientRequest request = await client.getUrl(uri);

      request.headers.set(HttpHeaders.acceptHeader, 'image/*');

      final HttpClientResponse response = await request.close();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        AppLogger.log(
          'Notification image download failed. '
          'Status=${response.statusCode}',
          name: 'LocalNotificationService',
        );

        return null;
      }

      final List<int> bytes = await response.fold<List<int>>(<int>[], (
        List<int> collectedBytes,
        List<int> chunk,
      ) {
        collectedBytes.addAll(chunk);
        return collectedBytes;
      });

      if (bytes.isEmpty) {
        return null;
      }

      final Directory temporaryDirectory = await getTemporaryDirectory();

      final String extension = _resolveImageExtension(
        uri: uri,
        contentType: response.headers.contentType,
      );

      final File imageFile = File(
        '${temporaryDirectory.path}/'
        'notification_${DateTime.now().millisecondsSinceEpoch}'
        '$extension',
      );

      await imageFile.writeAsBytes(bytes, flush: true);

      AppLogger.log(
        'Notification image downloaded: ${imageFile.path}',
        name: 'LocalNotificationService',
      );

      return imageFile.path;
    } catch (error, stackTrace) {
      AppLogger.log(
        'Failed to download notification image',
        error: error,
        stackTrace: stackTrace,
        name: 'LocalNotificationService',
      );

      return null;
    } finally {
      client.close(force: true);
    }
  }

  String _resolveImageExtension({
    required Uri uri,
    required ContentType? contentType,
  }) {
    final String mimeType = contentType?.mimeType.toLowerCase() ?? '';

    if (mimeType == 'image/png') {
      return '.png';
    }

    if (mimeType == 'image/gif') {
      return '.gif';
    }

    if (mimeType == 'image/webp') {
      return '.webp';
    }

    if (mimeType == 'image/jpeg' || mimeType == 'image/jpg') {
      return '.jpg';
    }

    final String path = uri.path.toLowerCase();

    if (path.endsWith('.png')) {
      return '.png';
    }

    if (path.endsWith('.gif')) {
      return '.gif';
    }

    if (path.endsWith('.webp')) {
      return '.webp';
    }

    if (path.endsWith('.jpeg')) {
      return '.jpeg';
    }

    return '.jpg';
  }

  void _handleNotificationTap(NotificationResponse response) {
    AppLogger.log(
      'Notification tapped. payload=${response.payload}',
      name: 'LocalNotificationService',
    );

    final String rawPayload = response.payload?.trim() ?? '';

    if (rawPayload.isEmpty) {
      return;
    }

    String deepLink = rawPayload;

    try {
      if (rawPayload.startsWith('{')) {
        final dynamic decoded = jsonDecode(rawPayload);

        if (decoded is! Map) {
          return;
        }

        final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);

        final String conversationId =
            data['conversationId']?.toString().trim() ?? '';

        if (conversationId.isNotEmpty) {
          final String contactId = data['contactId']?.toString().trim() ?? '';

          final String contactName =
              data['contactName']?.toString().trim() ?? 'User';

          final MessageThreadModel thread = MessageThreadModel(
            id: conversationId,
            learnerName: contactName,
            lastMessage: '',
            timeLabel: '',
            unreadCount: 0,
            isOnline: false,
            isHighlighted: false,
            isDelivered: true,
            avatarUrl: '',
            contactId: contactId,
          );

          Get.to<void>(
            () => const MessageChatView(),
            binding: BindingsBuilder(() {
              Get.put<MessageChatController>(
                MessageChatController(
                  thread: thread,
                  messagesMockService: Get.find<MessagesMockService>(),
                ),
              );
            }),
            transition: Transition.rightToLeft,
          );

          return;
        }

        deepLink = data['deepLink']?.toString().trim() ?? '';
      }
    } catch (error, stackTrace) {
      AppLogger.log(
        'Error parsing notification payload',
        error: error,
        stackTrace: stackTrace,
        name: 'LocalNotificationService',
      );

      return;
    }

    if (deepLink.isEmpty) {
      return;
    }

    unawaited(_openNotificationDeepLink(deepLink));
  }

  Future<void> _openNotificationDeepLink(String deepLink) async {
    final bool handled = await NotificationDeepLinkService.open(deepLink);

    if (handled) {
      return;
    }

    final Uri? uri = Uri.tryParse(deepLink);

    if (uri == null) {
      return;
    }

    final String routePath;

    if (uri.scheme.isEmpty) {
      routePath = uri.path;
    } else if (uri.host.isNotEmpty) {
      routePath = '/${uri.host}${uri.path}';
    } else {
      routePath = uri.path;
    }

    if (routePath.isEmpty || !routePath.startsWith('/')) {
      return;
    }

    try {
      await Get.toNamed<void>(routePath, parameters: uri.queryParameters);
    } catch (error, stackTrace) {
      AppLogger.log(
        'Unable to open notification deep link: $deepLink',
        error: error,
        stackTrace: stackTrace,
        name: 'LocalNotificationService',
      );
    }
  }

  /// Mark a conversation as suppressed — no local notifications will be shown
  /// for FCM messages belonging to this conversation.
  void suppressConversation(String conversationId) {
    _suppressedConversationIds.add(conversationId);
  }

  /// Remove suppression for a conversation — notifications will be shown
  /// again for messages in this conversation.
  void unsuppressConversation(String conversationId) {
    _suppressedConversationIds.remove(conversationId);
  }
}
