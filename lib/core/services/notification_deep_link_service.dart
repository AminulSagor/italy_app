import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../controllers/user_session_controller.dart';
import '../models/account_restriction_details.dart';
import 'auth_service.dart';

class NotificationDeepLinkService {
  NotificationDeepLinkService._();

  static Future<bool> open(String value) async {
    final String deepLink = value.trim();

    if (deepLink.isEmpty) {
      return false;
    }

    final Uri? uri = Uri.tryParse(deepLink);

    if (uri == null) {
      return false;
    }

    if (await openAccountRestriction(deepLink)) {
      return true;
    }

    final String? attemptId =
    _extractFinalExamAttemptId(uri);

    if (attemptId == null || attemptId.isEmpty) {
      return false;
    }

    final String controllerTag =
        'final_exam_result_${attemptId}_'
        '${DateTime.now().microsecondsSinceEpoch}';

    await Get.toNamed<void>(
      AppRoutes.finalExamResult,
      arguments: FinalExamResultRouteArguments(
        controllerTag: controllerTag,

        // The result controller loads directly with attemptId.
        // courseId is not needed for notification navigation.
        courseId: '',
        attemptId: attemptId,
      ),
    );

    return true;
  }
  static Future<bool> openAccountRestriction(
      String value,
      ) async {
    final Uri? uri = Uri.tryParse(value.trim());

    if (uri == null || !_isAccountRestrictionUri(uri)) {
      return false;
    }

    final String reason =
        uri.queryParameters['reason']?.trim() ?? '';

    final String effectiveAtValue =
        uri.queryParameters['effectiveAt']?.trim() ?? '';

    final String caseNumberValue =
        uri.queryParameters['caseNumber']?.trim() ?? '';

    final AccountRestrictionDetails restriction =
    AccountRestrictionDetails(
      reason: reason.isEmpty
          ? AccountRestrictionDetails.fallback.reason
          : reason,
      effectiveAt: effectiveAtValue.isEmpty
          ? null
          : DateTime.tryParse(effectiveAtValue),
      caseNumber:
      caseNumberValue.isEmpty ? null : caseNumberValue,
    );

    if (Get.isRegistered<AuthService>()) {
      await Get.find<AuthService>().logout();
    }

    if (Get.isRegistered<UserSessionController>()) {
      Get.find<UserSessionController>().clear();
    }

    if (Get.currentRoute != AppRoutes.accountSuspended) {
      Get.offAllNamed(
        AppRoutes.accountSuspended,
        arguments: restriction,
      );
    }

    return true;
  }

  static bool _isAccountRestrictionUri(Uri uri) {
    final String host = uri.host.toLowerCase();

    final List<String> segments = uri.pathSegments
        .map((String segment) => segment.toLowerCase())
        .toList(growable: false);

    return host == 'account-suspended' ||
        (segments.isNotEmpty &&
            segments.first == 'account-suspended');
  }

  static String? _extractFinalExamAttemptId(
      Uri uri,
      ) {
    final String host = uri.host.toLowerCase();

    final List<String> segments =
    uri.pathSegments.toList(growable: false);

    final List<String> normalizedSegments = segments
        .map((String segment) => segment.toLowerCase())
        .toList(growable: false);

    // Handles:
    // italirpothe://final-exams/attempts/{attemptId}/result
    if (host == 'final-exams' &&
        normalizedSegments.length >= 3 &&
        normalizedSegments[0] == 'attempts' &&
        normalizedSegments[2] == 'result') {
      return segments[1].trim();
    }

    // Also handles:
    // /final-exams/attempts/{attemptId}/result
    if (normalizedSegments.length >= 4 &&
        normalizedSegments[0] == 'final-exams' &&
        normalizedSegments[1] == 'attempts' &&
        normalizedSegments[3] == 'result') {
      return segments[2].trim();
    }

    return null;
  }
}