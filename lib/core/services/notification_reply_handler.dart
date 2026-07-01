import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) async {
  if (response.actionId == 'REPLY_ACTION') {
    final String? replyText = response.input;
    if (replyText == null || replyText.trim().isEmpty) {
      return;
    }

    final String? payloadStr = response.payload;
    if (payloadStr == null || payloadStr.isEmpty) {
      return;
    }

    String conversationId = payloadStr;
    
    try {
      await dotenv.load(fileName: '.env');
      final String apiBaseUrl = dotenv.env['API_BASE_URL']?.trim() ?? '';
      
      const FlutterSecureStorage storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      
      final String? token = await storage.read(key: 'access_token');
      final String? tokenType = await storage.read(key: 'token_type') ?? 'Bearer';
      
      if (token == null || token.isEmpty) {
        dev.log('No token found for background reply', name: 'NotificationReply');
        return;
      }
      
      final Dio dio = Dio(BaseOptions(
        baseUrl: apiBaseUrl,
        headers: {
          'Authorization': '$tokenType $token',
        },
      ));

      final clientMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      await dio.post(
        '/chat/conversations/$conversationId/messages',
        data: {
          'content': replyText,
          'clientMessageId': clientMessageId,
        },
      );
      dev.log('Background reply sent successfully.', name: 'NotificationReply');
    } catch (e, stackTrace) {
      dev.log('Failed to send background reply', error: e, stackTrace: stackTrace, name: 'NotificationReply');
    }
  }
}
