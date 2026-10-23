import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../routes/app_route_arguments.dart';
import '../../../routes/app_routes.dart';
import '../models/course_device_access_models.dart';
import '../models/course_models.dart';
import '../services/course_device_access_service.dart';
import '../services/courses_api_service.dart';

class CourseDetailController extends GetxController {
  static const String _deviceProofRequiredCode =
      'COURSE_DEVICE_ACCESS_REQUIRED';

  final String controllerTag;
  final CourseCardModel course;
  final HomeChapterRouteArguments? resumeChapter;
  final CoursesApiService _coursesApiService;
  final CourseDeviceAccessService _courseDeviceAccessService;

  CourseDetailController({
    required this.controllerTag,
    required this.course,
    this.resumeChapter,
    required CoursesApiService coursesApiService,
    required CourseDeviceAccessService courseDeviceAccessService,
  }) : // Keep public dependency names for route bindings.
       // ignore: prefer_initializing_formals
       _coursesApiService = coursesApiService,
       // ignore: prefer_initializing_formals
       _courseDeviceAccessService = courseDeviceAccessService;

  final RxBool isLoading = false.obs;
  final RxBool isProSubmitting = false.obs;
  final Rxn<CourseDetailModel> detail = Rxn<CourseDetailModel>();
  final Rx<CourseDeviceAccessState> deviceAccessState =
      CourseDeviceAccessState.checking.obs;
  final Rxn<CourseDeviceAccessResult> deviceAccess =
      Rxn<CourseDeviceAccessResult>();
  final RxString deviceAccessError = ''.obs;
  final RxBool isRequestingDeviceAccess = false.obs;
  bool _didResumeChapter = false;

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  Future<void> loadDetail() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      if (!await _verifyDeviceAccess()) return;
      await _loadVerifiedDetail(canRecoverRejectedProof: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _verifyDeviceAccess() async {
    deviceAccessState.value = CourseDeviceAccessState.checking;
    deviceAccessError.value = '';
    try {
      final CourseDeviceAccessResult access = await _courseDeviceAccessService
          .verifyCourse(course.id);
      deviceAccess.value = access;
      deviceAccessState.value = access.authorized
          ? CourseDeviceAccessState.authorized
          : CourseDeviceAccessState.blocked;
      return access.authorized;
    } catch (error) {
      deviceAccessState.value = CourseDeviceAccessState.error;
      deviceAccessError.value = _deviceErrorMessage(error);
      return false;
    }
  }

  Future<void> _loadVerifiedDetail({
    required bool canRecoverRejectedProof,
  }) async {
    final ApiResult<CourseDetailModel> result =
        await ApiErrorHandler.call<CourseDetailModel>(
          () => _coursesApiService.fetchCourseDetail(courseId: course.id),
          errorTitle: 'course_details'.tr,
          suppressedErrorCodes: const <String>{_deviceProofRequiredCode},
        );

    if (result.isSuccess && result.data != null) {
      detail.value = result.data;
      _resumeChapterIfRequested(result.data!);
      return;
    }

    if (result.errorCode != _deviceProofRequiredCode) return;

    // A concurrent verification may have rotated the proof between the
    // verification and detail calls. Re-check once so the page resolves to
    // either the course or the blocked-device request UI instead of a snackbar
    // followed by an empty page.
    if (canRecoverRejectedProof && await _verifyDeviceAccess()) {
      await _loadVerifiedDetail(canRecoverRejectedProof: false);
      return;
    }

    if (deviceAccessState.value == CourseDeviceAccessState.authorized) {
      deviceAccessState.value = CourseDeviceAccessState.error;
      deviceAccessError.value =
          result.error ?? 'The verified device proof could not be accepted.';
    }
  }

  void _resumeChapterIfRequested(CourseDetailModel courseDetail) {
    final HomeChapterRouteArguments? target = resumeChapter;
    if (_didResumeChapter || target == null) return;

    CourseChapterModel? matchingChapter;
    for (final CourseChapterModel chapter in courseDetail.chapters) {
      if (chapter.id == target.lessonId) {
        matchingChapter = chapter;
        break;
      }
    }
    if (matchingChapter == null ||
        matchingChapter.state == CourseChapterState.locked) {
      return;
    }

    _didResumeChapter = true;
    final CourseChapterModel chapter = matchingChapter;
    unawaited(Future<void>.delayed(Duration.zero, () => openChapter(chapter)));
  }

  Future<void> requestDeviceAccess() async {
    final CourseDeviceAccessResult? access = deviceAccess.value;
    if (access == null ||
        access.authorized ||
        access.isPending ||
        isRequestingDeviceAccess.value) {
      return;
    }

    isRequestingDeviceAccess.value = true;
    try {
      await _courseDeviceAccessService.requestAccess(
        courseId: course.id,
        deviceKeyId: access.deviceKeyId,
      );
      deviceAccess.value = CourseDeviceAccessResult(
        authorized: false,
        deviceKeyId: access.deviceKeyId,
        requestedDeviceLabel: access.requestedDeviceLabel,
        currentDeviceLabel: access.currentDeviceLabel,
        requestStatus: 'pending',
      );
      Get.snackbar(
        'Device request submitted',
        'An administrator will review this course device request.',
      );
    } catch (error) {
      Get.snackbar('Device request failed', _deviceErrorMessage(error));
    } finally {
      isRequestingDeviceAccess.value = false;
    }
  }

  String _deviceErrorMessage(Object error) {
    if (error is DioException) {
      final dynamic data = error.response?.data;
      if (data is Map && data['message'] != null) {
        final dynamic message = data['message'];
        return message is List ? message.join(', ') : message.toString();
      }
      return error.message ?? 'Device verification failed.';
    }
    if (error is PlatformException) {
      return error.message ?? 'Device verification failed.';
    }
    return error.toString().replaceFirst('Bad state: ', '');
  }

  Future<void> refreshAfterPurchase() async {
    await loadDetail();
  }

  Future<void> openProOrderSummary() async {
    final String tag =
        'pro_checkout_${course.id}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.proOrderSummary,
      arguments: ProOrderSummaryRouteArguments(
        controllerTag: tag,
        courseDetailControllerTag: controllerTag,
        courseId: course.id,
        courseName: detail.value?.title ?? course.title,
        lessonCount: detail.value?.lessonCount ?? 0,
      ),
    );
  }

  Future<void> openFinalExam() async {
    final CourseDetailModel? currentDetail = detail.value;
    if (currentDetail == null) return;

    final CourseFinalExamModel finalExam = currentDetail.finalExam;

    // Result is available: open result page directly.
    if (finalExam.canViewResult) {
      final String attemptId = finalExam.attemptId.trim();

      if (attemptId.isEmpty) {
        Get.snackbar(
          'gen_final_exam_result'.tr,
          'Result attempt was not found.',
        );
        return;
      }

      final String tag =
          'final_exam_result_${attemptId}_'
          '${DateTime.now().millisecondsSinceEpoch}';

      await Get.toNamed(
        AppRoutes.finalExamResult,
        arguments: FinalExamResultRouteArguments(
          controllerTag: tag,
          courseId: course.id,
          attemptId: attemptId,
        ),
      );

      await loadDetail();
      return;
    }

    // Exam submitted, but teacher review is incomplete.
    if (finalExam.hasAttempted && !finalExam.resultReady) {
      Get.snackbar(
        'gen_final_exam_result'.tr,
        finalExam.helperLabel.isNotEmpty
            ? finalExam.helperLabel
            : 'Your final examination result is being processed.',
      );
      return;
    }

    // User cannot start the exam.
    if (!finalExam.canStart) {
      Get.snackbar('gen_final_exam'.tr, finalExam.helperLabel);
      return;
    }

    // User is eligible: open the exam overview.
    final String tag =
        'final_exam_${course.id}_'
        '${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.finalExamOverview,
      arguments: FinalExamRouteArguments(
        controllerTag: tag,
        courseId: course.id,
      ),
    );

    await loadDetail();
  }

  Future<void> handleFinalExamTap() async {
    final CourseFinalExamModel? finalExam = detail.value?.finalExam;

    if (finalExam == null) return;

    // View Result
    if (finalExam.canViewResult) {
      await openFinalExam();
      return;
    }

    // Preserve existing certificate navigation
    if (finalExam.hasCertificate) {
      final String resolvedAttemptId = finalExam.attemptId.trim();

      if (resolvedAttemptId.isEmpty) {
        Get.snackbar(
          'Certificate unavailable',
          'Final exam attempt was not found.',
        );
        return;
      }

      final String tag =
          'course_certificate_'
          '${DateTime.now().millisecondsSinceEpoch}';

      await Get.toNamed(
        AppRoutes.courseCertificate,
        arguments: CourseCertificateRouteArguments(
          controllerTag: tag,
          attemptId: resolvedAttemptId,
        ),
      );
      return;
    }

    // Start Exam
    if (finalExam.canStart) {
      await openFinalExam();
    }
  }

  Future<void> openChapter(CourseChapterModel chapter) async {
    if (chapter.state == CourseChapterState.locked) {
      return;
    }

    final String tag =
        'chapter_${chapter.id}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.chapterDetail,
      arguments: ChapterDetailRouteArguments(
        chapter: chapter,
        controllerTag: tag,
      ),
    );

    await loadDetail();
  }
}
