import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/api_error_handler.dart';
import '../../../../../routes/app_route_arguments.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../courses/models/course_catalog_models.dart';
import '../../../../courses/models/course_models.dart';
import '../../../../courses/services/course_catalog_api_service.dart';

class CourseCatalogController extends GetxController {
  CourseCatalogController({
    required CourseCatalogApiService courseCatalogApiService,
  }) : _courseCatalogApiService = courseCatalogApiService;

  static const int _pageSize = 10;

  final CourseCatalogApiService _courseCatalogApiService;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxList<CourseCardModel> courses = <CourseCardModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  late final Worker _searchWorker;
  int _currentPage = 0;
  int _totalPages = 1;
  int _requestVersion = 0;

  bool get hasMore => _currentPage < _totalPages;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_handleScroll);
    _searchWorker = debounce<String>(
      searchQuery,
      (_) => loadCourses(reset: true),
      time: const Duration(milliseconds: 400),
    );
    loadCourses(reset: true);
  }

  void onSearchChanged(String value) {
    searchQuery.value = value.trim();
  }

  Future<void> refreshCourses() {
    return loadCourses(reset: true, showError: true);
  }

  Future<void> loadCourses({
    required bool reset,
    bool showError = false,
  }) async {
    final int requestVersion;
    if (reset) {
      requestVersion = ++_requestVersion;
      isLoading.value = true;
      isLoadingMore.value = false;
      errorMessage.value = '';
      _currentPage = 0;
      _totalPages = 1;
      courses.clear();
    } else {
      if (isLoading.value || isLoadingMore.value || !hasMore) return;
      requestVersion = _requestVersion;
      isLoadingMore.value = true;
    }

    final int page = reset ? 1 : _currentPage + 1;

    try {
      final ApiResult<CourseCatalogPageModel> result =
          await ApiErrorHandler.call<CourseCatalogPageModel>(
            () => _courseCatalogApiService.fetchCourses(
              page: page,
              limit: _pageSize,
              search: searchQuery.value,
            ),
            showError: showError,
            errorTitle: 'Courses',
          );

      if (requestVersion != _requestVersion) return;
      if (!result.isSuccess || result.data == null) {
        errorMessage.value = result.error ?? 'Unable to load courses.';
        return;
      }

      final CourseCatalogPageModel pageData = result.data!;
      if (reset) {
        courses.assignAll(pageData.items);
      } else {
        final Set<String> existingIds = courses
            .map((CourseCardModel item) => item.id)
            .toSet();
        courses.addAll(
          pageData.items.where(
            (CourseCardModel item) => !existingIds.contains(item.id),
          ),
        );
      }
      _currentPage = pageData.meta.page;
      _totalPages = pageData.meta.totalPages;
      unawaited(_loadProgress(pageData.items, requestVersion));
    } finally {
      if (requestVersion == _requestVersion) {
        if (reset) {
          isLoading.value = false;
        } else {
          isLoadingMore.value = false;
        }
      }
    }
  }


  Future<void> _loadProgress(
    List<CourseCardModel> pageItems,
    int requestVersion,
  ) async {
    await Future.wait(
      pageItems.map((CourseCardModel course) async {
        final ApiResult<CourseCardModel> result =
            await ApiErrorHandler.call<CourseCardModel>(
              () => _courseCatalogApiService.fetchCourseProgress(course),
              showError: false,
            );
        if (requestVersion != _requestVersion ||
            !result.isSuccess ||
            result.data == null) {
          return;
        }

        final int index = courses.indexWhere(
          (CourseCardModel item) => item.id == course.id,
        );
        if (index >= 0) {
          courses[index] = result.data!;
        }
      }),
    );
  }

  Future<void> onCourseTap(CourseCardModel course) async {
    if (course.state == CourseCardState.locked) return;

    final String controllerTag =
        'course_${course.id}_${DateTime.now().millisecondsSinceEpoch}';
    await Get.toNamed(
      AppRoutes.courseDetail,
      arguments: CourseDetailRouteArguments(
        course: course,
        controllerTag: controllerTag,
      ),
    );
  }

  void _handleScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.extentAfter < 240) {
      loadCourses(reset: false);
    }
  }

  @override
  void onClose() {
    _searchWorker.dispose();
    scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    searchController.dispose();
    super.onClose();
  }
}
