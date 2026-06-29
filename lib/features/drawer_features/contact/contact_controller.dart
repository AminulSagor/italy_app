import 'dart:developer' as dev;

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactController extends GetxController {
  static const String supportPhoneDisplay = '+39 123 456 7890';
  static const String _supportPhoneInternational = '+391234567890';
  static const String supportEmail = 'support@lumina.it';
  static const String facebookCommunityUrl =
      'https://www.facebook.com/groups/1816913385931720';

  void onContactTap() {
    Get.toNamed('/contact-support');
  }

  Future<void> chatOnWhatsapp() async {
    final Uri whatsappUri = Uri.https(
      'wa.me',
      '/391234567890',
      <String, String>{
        'text': 'Hello, I need help with Italir Pothe.',
      },
    );

    await _launchExternal(
      whatsappUri,
      failureTitle: 'WhatsApp unavailable',
      failureMessage:
          'Could not open WhatsApp. Please contact $supportPhoneDisplay.',
    );
  }

  Future<void> callSupport() async {
    await _launchExternal(
      Uri(scheme: 'tel', path: _supportPhoneInternational),
      failureTitle: 'Phone unavailable',
      failureMessage: 'No phone app is available on this device.',
    );
  }

  Future<void> sendEmail() async {
    await _launchExternal(
      Uri(
        scheme: 'mailto',
        path: supportEmail,
        queryParameters: <String, String>{
          'subject': 'Italir Pothe support request',
        },
      ),
      failureTitle: 'Email unavailable',
      failureMessage:
          'No email app is available. You can email $supportEmail manually.',
    );
  }

  Future<void> joinFacebookCommunity() async {
    await _launchExternal(
      Uri.parse(facebookCommunityUrl),
      failureTitle: 'Facebook unavailable',
      failureMessage: 'Could not open the Facebook community link.',
    );
  }

  Future<void> _launchExternal(
    Uri uri, {
    required String failureTitle,
    required String failureMessage,
  }) async {
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showFailure(failureTitle, failureMessage);
      }
    } catch (error, stackTrace) {
      dev.log(
        'Failed to launch external support action: $uri',
        name: 'ContactController',
        error: error,
        stackTrace: stackTrace,
      );
      _showFailure(failureTitle, failureMessage);
    }
  }

  void _showFailure(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
