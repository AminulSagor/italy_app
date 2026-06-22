import 'dart:developer' as dev;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

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

    dev.log(
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
        dev.log(
          'Foreground FCM received: '
          'title=${message.notification?.title}, '
          'body=${message.notification?.body}, '
          'data=${message.data}',
          name: 'LocalNotificationService',
        );

        await showRemoteMessage(message);
      },
      onError: (Object error, StackTrace stackTrace) {
        dev.log(
          'Foreground FCM listener failed',
          error: error,
          stackTrace: stackTrace,
          name: 'LocalNotificationService',
        );
      },
    );
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

    final AndroidNotificationDetails androidDetails = _createAndroidDetails(
      title: title,
      body: body,
      localImagePath: localImagePath,
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

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: deepLink.isEmpty ? null : deepLink,
    );
  }

  AndroidNotificationDetails _createAndroidDetails({
    required String title,
    required String body,
    required String? localImagePath,
  }) {
    if (localImagePath == null) {
      return const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
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
      dev.log(
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
        dev.log(
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

      dev.log(
        'Notification image downloaded: ${imageFile.path}',
        name: 'LocalNotificationService',
      );

      return imageFile.path;
    } catch (error, stackTrace) {
      dev.log(
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
    dev.log(
      'Foreground notification tapped. '
      'payload=${response.payload}',
      name: 'LocalNotificationService',
    );

    // Deep-link navigation can be added here later.
  }
}
