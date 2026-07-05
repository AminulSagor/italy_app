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
        'text': 'hello_i_need_help_with_italir_pothe'.tr,
      },
    );

    await _launchExternal(
      whatsappUri,
      failureTitle: 'whatsapp_unavailable'.tr,
      failureMessage:
          'Could not open WhatsApp. Please contact $supportPhoneDisplay.',
    );
  }

  Future<void> callSupport() async {
    await _launchExternal(
      Uri(scheme: 'tel', path: _supportPhoneInternational),
      failureTitle: 'phone_unavailable'.tr,
      failureMessage: 'no_phone_app_is_available_on_this_device'.tr,
    );
  }

  Future<void> sendEmail() async {
    await _launchExternal(
      Uri(
        scheme: 'mailto',
        path: supportEmail,
        queryParameters: <String, String>{
          'subject': 'italir_pothe_support_request'.tr,
        },
      ),
      failureTitle: 'email_unavailable'.tr,
      failureMessage:
          'No email app is available. You can email $supportEmail manually.',
    );
  }

  Future<void> joinFacebookCommunity() async {
    await _launchExternal(
      Uri.parse(facebookCommunityUrl),
      failureTitle: 'facebook_unavailable'.tr,
      failureMessage: 'could_not_open_the_facebook_community_link'.tr,
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
