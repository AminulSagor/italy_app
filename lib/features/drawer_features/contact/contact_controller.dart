import 'package:get/get.dart';

class ContactController extends GetxController {
  void onContactTap() {
    Get.toNamed('/contact-support');
  }

  void chatOnWhatsapp() {
    Get.snackbar(
      'WhatsApp',
      'WhatsApp chat will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void callSupport() {
    Get.snackbar(
      'Call Support',
      'Phone dialer will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void sendEmail() {
    Get.snackbar(
      'Email',
      'Email app will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void joinFacebookCommunity() {
    Get.snackbar(
      'Facebook Community',
      'Facebook community will open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
