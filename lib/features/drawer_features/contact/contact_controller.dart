import 'dart:developer' as dev;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactController extends GetxController {
  late final String supportPhoneDisplay;
  late final String supportPhoneInternational;
  late final String supportEmail;
  late final String facebookCommunityUrl;
  late final String whatsappNumber;

  @override
  void onInit() {
    super.onInit();

    supportPhoneDisplay = _readEnvironmentValue(
      key: 'SUPPORT_PHONE_DISPLAY',
      fallback: '+39 351 006 6920',
    );

    supportPhoneInternational =
        _normalizeInternationalPhone(
          _readEnvironmentValue(
            key: 'SUPPORT_PHONE_INTERNATIONAL',
            fallback: '+393510066920',
          ),
        );

    supportEmail = _readEnvironmentValue(
      key: 'SUPPORT_EMAIL',
      fallback: 'hello@italirpothe.com',
    ).toLowerCase();

    facebookCommunityUrl = _readEnvironmentValue(
      key: 'FACEBOOK_COMMUNITY_URL',
      fallback:
      'https://www.facebook.com/groups/1816913385931720',
    );

    whatsappNumber = supportPhoneInternational.replaceAll(
      RegExp(r'\D'),
      '',
    );
  }

  void onContactTap() {
    Get.toNamed('/contact-support');
  }

  Future<void> chatOnWhatsapp() async {
    final Uri whatsappUri = Uri.https(
      'wa.me',
      '/$whatsappNumber',
      <String, String>{
        'text':
        'Hello, I need help with Italir Pothe.',
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
      Uri(
        scheme: 'tel',
        path: supportPhoneInternational,
      ),
      failureTitle: 'phone_unavailable'.tr,
      failureMessage:
      'No phone application is available. You can call $supportPhoneDisplay manually.',
    );
  }

  Future<void> sendEmail() async {
    await _launchExternal(
      Uri(
        scheme: 'mailto',
        path: supportEmail,
        queryParameters: <String, String>{
          'subject':
          'Italir Pothe Support Request',
        },
      ),
      failureTitle: 'email_unavailable'.tr,
      failureMessage:
      'No email application is available. You can email $supportEmail manually.',
    );
  }

  Future<void> joinFacebookCommunity() async {
    final Uri? communityUri = Uri.tryParse(
      facebookCommunityUrl,
    );

    if (communityUri == null ||
        !communityUri.hasScheme) {
      _showFailure(
        'facebook_unavailable'.tr,
        'The Facebook community link is invalid.',
      );
      return;
    }

    await _launchExternal(
      communityUri,
      failureTitle: 'facebook_unavailable'.tr,
      failureMessage:
      'could_not_open_the_facebook_community_link'
          .tr,
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
        _showFailure(
          failureTitle,
          failureMessage,
        );
      }
    } catch (error, stackTrace) {
      dev.log(
        'Failed to launch external support action: $uri',
        name: 'ContactController',
        error: error,
        stackTrace: stackTrace,
      );

      _showFailure(
        failureTitle,
        failureMessage,
      );
    }
  }

  String _readEnvironmentValue({
    required String key,
    required String fallback,
  }) {
    final String? value =
    dotenv.env[key]?.trim();

    if (value == null || value.isEmpty) {
      dev.log(
        '$key is missing from .env. Using fallback.',
        name: 'ContactController',
      );

      return fallback;
    }

    return value;
  }

  String _normalizeInternationalPhone(
      String value,
      ) {
    final String digits = value.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (digits.isEmpty) {
      return '+393510066920';
    }

    return '+$digits';
  }

  void _showFailure(
      String title,
      String message,
      ) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}