import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_error_handler.dart';
import '../../../core/widgets/app_pdf_viewer.dart';
import '../../courses/models/course_models.dart';
import '../../courses/services/courses_api_service.dart';
import '../views/important_verbs/important_verbs_view.dart';
import '../views/important_verbs/saved_verbs_view.dart';
import 'package:italir_pothe/routes/routes.dart';
import 'package:italir_pothe/core/themes/app_colors.dart';
import '../views/daily_challenges/daily_chest_unlocked_view.dart';
import '../models/daily_challenge_models.dart';
import '../models/practice_hub_models.dart';
import '../models/practice_hub_pdf_model.dart';
import '../models/survival_italian_models.dart';
import '../services/practice_hub_api_service.dart';

class PracticeHubController extends GetxController {
  PracticeHubController({
    required CoursesApiService coursesApiService,
    required PracticeHubApiService practiceHubApiService,
  }) : _coursesApiService = coursesApiService,
        _practiceHubApiService = practiceHubApiService;

  final CoursesApiService _coursesApiService;
  final PracticeHubApiService _practiceHubApiService;

  final RxInt selectedCourseIndex = 0.obs;
  final RxBool isCoursesLoading = false.obs;
  int _courseRequestVersion = 0;

  /// Synced with the currently selected course progress.
  final RxBool isFinalExamReady = false.obs;

  final RxList<CourseCardModel> courses = <CourseCardModel>[].obs;
  final RxBool isFinalExamsLoading = false.obs;
  final RxList<PracticeFinalExamCourseModel> finalExamCourses =
      <PracticeFinalExamCourseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
    loadFinalExamCourses();
    loadPracticeHubOverview();
  }

  Future<void> loadCourses() async {
    if (isCoursesLoading.value) {
      return;
    }

    isCoursesLoading.value = true;
    try {
      final ApiResult<CoursesDashboardModel> result =
      await ApiErrorHandler.call<CoursesDashboardModel>(
            () => _coursesApiService.fetchDashboard(),
        showError: false,
      );

      if (!result.isSuccess || result.data == null) {
        return;
      }

      final int requestVersion = ++_courseRequestVersion;
      courses.assignAll(result.data!.courses);
      unawaited(_loadCourseProgress(result.data!.courses, requestVersion));

      if (selectedCourseIndex.value >= courses.length) {
        selectedCourseIndex.value = 0;
      }

      _syncFinalExamState();
    } finally {
      isCoursesLoading.value = false;
    }
  }


  Future<void> _loadCourseProgress(
      List<CourseCardModel> loadedCourses,
      int requestVersion,
      ) async {
    await Future.wait(
      loadedCourses.map((CourseCardModel course) async {
        final ApiResult<CourseCardModel> result =
        await ApiErrorHandler.call<CourseCardModel>(
              () => _coursesApiService.fetchCourseProgress(course),
          showError: false,
        );
        if (requestVersion != _courseRequestVersion ||
            !result.isSuccess ||
            result.data == null) {
          return;
        }

        final int index = courses.indexWhere(
              (CourseCardModel item) => item.id == course.id,
        );
        if (index >= 0) {
          courses[index] = result.data!;
          if (index == selectedCourseIndex.value) {
            _syncFinalExamState();
          }
        }
      }),
    );
  }

  void _syncFinalExamState() {
    if (courses.isEmpty) {
      isFinalExamReady.value = false;
      return;
    }

    isFinalExamReady.value = courses[selectedCourseIndex.value].progress >= 0.8;
  }

  final RxBool isPracticeHubOverviewLoading = false.obs;
  final RxString practiceHubOverviewError = ''.obs;
  final RxList<PracticeHubSkillBuilderModel> skillBuilders =
      <PracticeHubSkillBuilderModel>[].obs;
  final Rxn<PracticeHubWebinarModel> featuredWebinar =
  Rxn<PracticeHubWebinarModel>();

  Future<void> loadPracticeHubOverview({bool showError = false}) async {
    if (isPracticeHubOverviewLoading.value) return;

    isPracticeHubOverviewLoading.value = true;
    practiceHubOverviewError.value = '';
    try {
      final ApiResult<PracticeHubOverviewModel> result =
      await ApiErrorHandler.call<PracticeHubOverviewModel>(
            () => _practiceHubApiService.fetchOverview(),
        showError: showError,
      );

      if (!result.isSuccess || result.data == null) {
        practiceHubOverviewError.value =
            result.error ?? 'unable_to_load_practice_hub_information'.tr;
        return;
      }

      skillBuilders.assignAll(result.data!.skillBuilders);
      featuredWebinar.value = result.data!.featuredWebinar;
    } finally {
      isPracticeHubOverviewLoading.value = false;
    }
  }

  Future<void> refreshPracticeHub() async {
    await Future.wait<void>(<Future<void>>[
      loadCourses(),
      loadFinalExamCourses(showError: true),
      loadPracticeHubOverview(showError: true),
    ]);
  }

  void onViewAllCoursesTap() {
    Get.toNamed(AppRoutes.courseCatalog);
  }

  Future<void> onCourseTap(int index) async {
    if (index < 0 || index >= courses.length) {
      return;
    }

    selectedCourseIndex.value = index;
    _syncFinalExamState();

    final CourseCardModel course = courses[index];
    if (course.state == CourseCardState.locked) {
      return;
    }

    final String tag =
        'course_${course.id}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.courseDetail,
      arguments: CourseDetailRouteArguments(course: course, controllerTag: tag),
    );
  }

  void onSkillBuilderTap(PracticeHubSkillBuilderType type) {
    switch (type) {
      case PracticeHubSkillBuilderType.importantVerbs:
        onImportantVerbsTap();
        return;
      case PracticeHubSkillBuilderType.survivalItalian:
        onSurvivalItalianTap();
        return;
      case PracticeHubSkillBuilderType.jobSentences:
        onJobSentencesTap();
        return;
      case PracticeHubSkillBuilderType.dailyChallenges:
        onDailyChallengesTap();
        return;
    }
  }

  Future<void> loadFinalExamCourses({bool showError = false}) async {
    if (isFinalExamsLoading.value) return;

    isFinalExamsLoading.value = true;
    try {
      final ApiResult<List<PracticeFinalExamCourseModel>> result =
      await ApiErrorHandler.call<List<PracticeFinalExamCourseModel>>(
        _practiceHubApiService.fetchCurrentCourseFinalExams,
        showError: showError,
        errorTitle: 'final_exams'.tr,
      );
      if (result.isSuccess && result.data != null) {
        finalExamCourses.assignAll(result.data!);
      }
    } finally {
      isFinalExamsLoading.value = false;
    }
  }

  Future<void> onFinalExamCardTap(
      PracticeFinalExamCourseModel item,
      ) async {
    switch (item.action) {
      case PracticeFinalExamAction.locked:
        _showFinalExamLockedMessage(item);
        return;

      case PracticeFinalExamAction.startExam:
      case PracticeFinalExamAction.retakeExam:
        await openFinalExam(item);
        return;

      case PracticeFinalExamAction.resultPending:
        Get.snackbar(
          'gen_final_exam_result'.tr,
          item.message.isNotEmpty
              ? item.message
              : 'final_exam_review_in_progress'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black87,
        );
        return;

      case PracticeFinalExamAction.viewResult:
        await openFinalExamResult(item);
        return;

      case PracticeFinalExamAction.viewCertificate:
        await openFinalExamCertificate(item);
        return;
    }
  }

  void _showFinalExamLockedMessage(
      PracticeFinalExamCourseModel item,
      ) {
    Get.snackbar(
      'final_exam_locked_1'.tr,
      item.message.isEmpty
          ? 'complete_course_percent_to_unlock_final_exam'
          .trParams(
        <String, String>{
          'percent':
          item.unlockCompletionPercent.toString(),
          'course': item.courseName,
        },
      )
          : item.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  Future<void> openFinalExamResult(
      PracticeFinalExamCourseModel item,
      ) async {
    final String attemptId = item.attemptId.trim();

    if (attemptId.isEmpty) {
      Get.snackbar(
        'gen_final_exam_result'.tr,
        'final_exam_attempt_not_found'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final String tag =
        'final_exam_result_${attemptId}_'
        '${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed<void>(
      AppRoutes.finalExamResult,
      arguments: FinalExamResultRouteArguments(
        controllerTag: tag,
        courseId: item.courseId,
        attemptId: attemptId,
      ),
    );

    await loadFinalExamCourses();
  }

  Future<void> openFinalExamCertificate(
      PracticeFinalExamCourseModel item,
      ) async {
    final String attemptId = item.attemptId.trim();

    if (attemptId.isEmpty) {
      Get.snackbar(
        'final_exam_view_certificate'.tr,
        'final_exam_attempt_not_found'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final String tag =
        'course_certificate_${attemptId}_'
        '${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed<void>(
      AppRoutes.courseCertificate,
      arguments: CourseCertificateRouteArguments(
        controllerTag: tag,
        attemptId: attemptId,
      ),
    );

    await loadFinalExamCourses();
  }

  Future<void> openFinalExam(
      PracticeFinalExamCourseModel item,
      ) async {
    if (!item.isUnlocked) return;

    final String tag =
        'final_exam_${item.courseId}_'
        '${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed<void>(
      AppRoutes.finalExamOverview,
      arguments: FinalExamRouteArguments(
        controllerTag: tag,
        courseId: item.courseId,
      ),
    );

    await loadFinalExamCourses();
  }

  Future<void> openCourseFromFinalExam(
      PracticeFinalExamCourseModel item,
      ) async {
    final int courseIndex = courses.indexWhere(
          (CourseCardModel course) => course.id == item.courseId,
    );
    if (courseIndex >= 0) {
      await onCourseTap(courseIndex);
      return;
    }

    await loadCourses();
    final int refreshedIndex = courses.indexWhere(
          (CourseCardModel course) => course.id == item.courseId,
    );
    if (refreshedIndex >= 0) {
      await onCourseTap(refreshedIndex);
    }
  }

  void onViewAllSessionsTap() {
    Get.toNamed(AppRoutes.webinar);
  }

  void onNotifyMeTap() {
    Get.snackbar(
      'notification_set'.tr,
      'webinar_start_notification_set'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  final TextEditingController importantVerbSearchController =
  TextEditingController();
  final TextEditingController savedVerbSearchController =
  TextEditingController();

  final RxString importantVerbSearchQuery = ''.obs;
  final RxString savedVerbSearchQuery = ''.obs;

  final RxString selectedImportantVerbFilter = 'All Verbs'.obs;
  final RxString selectedSavedVerbFilter = 'All Verbs'.obs;

  final RxBool showSavedVerbPreview = false.obs;

  final List<String> verbFilters = <String>[
    'All Verbs',
    'Regular',
    'Irregular',
  ];

  final RxSet<String> savedVerbIds = <String>{
    'parlare',
    'leggere',
    'dormire',
    'andare',
    'mangiare',
    'lavorare',
  }.obs;

  final List<Map<String, dynamic>> verbItems = <Map<String, dynamic>>[
    {
      'id': 'parlare',
      'title': 'parlare',
      'english': 'to speak',
      'bangla': 'কথা বলা',
      'type': 'regular',
      'ending': '-ARE',
    },
    {
      'id': 'leggere',
      'title': 'leggere',
      'english': 'to read',
      'bangla': 'পড়া',
      'type': 'regular',
      'ending': '-ERE',
    },
    {
      'id': 'dormire',
      'title': 'dormire',
      'english': 'to sleep',
      'bangla': 'ঘুমানো',
      'type': 'regular',
      'ending': '-IRE',
    },
    {
      'id': 'andare',
      'title': 'andare',
      'english': 'to go',
      'bangla': 'যাওয়া',
      'type': 'irregular',
      'ending': '-ARE',
    },
    {
      'id': 'mangiare',
      'title': 'mangiare',
      'english': 'to eat',
      'bangla': 'খাওয়া',
      'type': 'regular',
      'ending': '-ARE',
    },
    {
      'id': 'lavorare',
      'title': 'lavorare',
      'english': 'to work',
      'bangla': 'কাজ করা',
      'type': 'regular',
      'ending': '-ARE',
    },
    {
      'id': 'partire',
      'title': 'partire',
      'english': 'to leave, to depart',
      'bangla': 'প্রস্থান করা',
      'type': 'regular',
      'ending': '-IRE',
    },
    {
      'id': 'pagare',
      'title': 'pagare',
      'english': 'to pay',
      'bangla': 'প্রদান করা',
      'type': 'regular',
      'ending': '-ARE',
    },
    {
      'id': 'passare',
      'title': 'passare',
      'english': 'to pass, to spend time',
      'bangla': 'অতিবাহিত করা',
      'type': 'regular',
      'ending': '-ARE',
    },
  ];

  List<Map<String, dynamic>> get filteredImportantVerbItems {
    return _filterVerbsByType(verbItems, selectedImportantVerbFilter.value);
  }

  List<Map<String, dynamic>> get filteredSavedVerbItems {
    final String query = savedVerbSearchQuery.value.trim().toLowerCase();

    final List<Map<String, dynamic>> savedItems = verbItems
        .where((Map<String, dynamic> verb) => savedVerbIds.contains(verb['id']))
        .toList();

    final List<Map<String, dynamic>> typeFiltered = _filterVerbsByType(
      savedItems,
      selectedSavedVerbFilter.value,
    );

    if (query.isEmpty) return typeFiltered;

    return typeFiltered.where((Map<String, dynamic> verb) {
      final String title = (verb['title'] as String).toLowerCase();
      final String english = (verb['english'] as String).toLowerCase();
      final String bangla = (verb['bangla'] as String).toLowerCase();

      return title.contains(query) ||
          english.contains(query) ||
          bangla.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get importantVerbSearchResults {
    final String query = importantVerbSearchQuery.value.trim().toLowerCase();

    if (query.isEmpty) return <Map<String, dynamic>>[];

    return verbItems
        .where((Map<String, dynamic> verb) {
      final String title = (verb['title'] as String).toLowerCase();
      final String english = (verb['english'] as String).toLowerCase();
      final String bangla = (verb['bangla'] as String).toLowerCase();

      return title.contains(query) ||
          english.contains(query) ||
          bangla.contains(query);
    })
        .take(4)
        .toList();
  }

  List<Map<String, dynamic>> get savedVerbPreviewItems {
    return verbItems
        .where((Map<String, dynamic> verb) => savedVerbIds.contains(verb['id']))
        .take(6)
        .toList();
  }

  List<Map<String, dynamic>> _filterVerbsByType(
      List<Map<String, dynamic>> source,
      String filter,
      ) {
    if (filter == 'all_verbs'.tr) return source;

    final String expectedType = filter.toLowerCase();

    return source.where((Map<String, dynamic> verb) {
      return verb['type'] == expectedType;
    }).toList();
  }

  void onImportantVerbsTap() {
    Get.to<void>(
          () => const ImportantVerbsView(),
      transition: Transition.rightToLeft,
    );
  }

  void onViewAllSavedVerbsTap() {
    Get.to<void>(
          () => const SavedVerbsView(),
      transition: Transition.rightToLeft,
    );
  }

  void toggleSavedVerbPreview() {
    showSavedVerbPreview.toggle();
  }

  void selectImportantVerbFilter(String filter) {
    selectedImportantVerbFilter.value = filter;
  }

  void selectSavedVerbFilter(String filter) {
    selectedSavedVerbFilter.value = filter;
  }

  void onImportantVerbSearchChanged(String value) {
    importantVerbSearchQuery.value = value;
  }

  void onSavedVerbSearchChanged(String value) {
    savedVerbSearchQuery.value = value;
  }

  void clearImportantVerbSearch() {
    importantVerbSearchController.clear();
    importantVerbSearchQuery.value = '';
  }

  void clearSavedVerbSearch() {
    savedVerbSearchController.clear();
    savedVerbSearchQuery.value = '';
  }

  bool isVerbSaved(String id) {
    return savedVerbIds.contains(id);
  }

  void toggleVerbSaved(String id) {
    if (savedVerbIds.contains(id)) {
      savedVerbIds.remove(id);
    } else {
      savedVerbIds.add(id);
    }

    savedVerbIds.refresh();
  }

  void onVerbSuggestionTap(Map<String, dynamic> verb) {
    importantVerbSearchController.text = verb['title'] as String;
    importantVerbSearchQuery.value = verb['title'] as String;
    openVerbDetails(verb);
  }

  void onViewAllSearchResultsTap() {
    Get.snackbar(
      'search_results'.tr,
      'showing_all_matched_verbs'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  final RxMap<String, dynamic> selectedVerbDetails = <String, dynamic>{}.obs;

  final RxBool isVerbInfoExpanded = true.obs;
  final RxString expandedVerbTenseTitle = 'Present'.obs;

  Map<String, dynamic> get currentVerbDetails {
    if (selectedVerbDetails.isNotEmpty) {
      return Map<String, dynamic>.from(selectedVerbDetails);
    }

    return _buildVerbDetailsMap(verbItems.first);
  }

  String get selectedVerbTenseSubtitle {
    return currentVerbDetails['tensesubtitle'.tr] as String? ?? 'presente'.tr;
  }

  List<Map<String, dynamic>> get selectedVerbPresentForms {
    final Object? rawForms = currentVerbDetails['presentForms'];

    if (rawForms is List) {
      return rawForms
          .whereType<Map>()
          .map((Map form) => Map<String, dynamic>.from(form))
          .toList();
    }

    return <Map<String, dynamic>>[];
  }

  void setSelectedVerbForDetails(Map<String, dynamic> verb) {
    final Map<String, dynamic> details = _buildVerbDetailsMap(verb);

    selectedVerbDetails
      ..clear()
      ..addAll(details);

    isVerbInfoExpanded.value = true;
    expandedVerbTenseTitle.value = 'Present';
  }

  void onVerbDetailBackTap() {
    Get.back<void>();
  }

  void toggleVerbInformation() {
    isVerbInfoExpanded.toggle();
  }

  void toggleVerbTense(String title) {
    if (expandedVerbTenseTitle.value == title) {
      expandedVerbTenseTitle.value = '';
      return;
    }

    expandedVerbTenseTitle.value = title;
  }

  bool isVerbTenseExpanded(String title) {
    return expandedVerbTenseTitle.value == title;
  }

  void toggleSelectedVerbSaved() {
    final String id = currentVerbDetails['id'] as String? ?? '';

    if (id.isEmpty) return;

    toggleVerbSaved(id);
  }

  void playSelectedVerbAudio() {
    final String title = currentVerbDetails['title'] as String? ?? 'verb'.tr;

    Get.snackbar(
      'audio'.tr,
      'playing_pronunciation_for'.trParams(<String, String>{'text': title}),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  void playVerbFormAudio(String text) {
    if (text.trim().isEmpty) return;

    Get.snackbar(
      'audio'.tr,
      'playing_text'.trParams(<String, String>{'text': text}),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  void onVerbTranslateTap() {
    Get.snackbar(
      'translation'.tr,
      'language_helper_will_open_here'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  Map<String, dynamic> _buildVerbDetailsMap(Map<String, dynamic> verb) {
    final String id = verb['id'] as String? ?? 'parlare';
    final String title = verb['title'] as String? ?? 'parlare';
    final String english = verb['english'] as String? ?? 'to speak';
    final String bangla = verb['bangla'] as String? ?? 'কথা বলা';
    final String type = verb['type'] as String? ?? 'regular';
    final String ending = verb['ending'] as String? ?? '-ARE';

    final Map<String, dynamic> override =
        _verbDetailOverrides[id] ?? <String, dynamic>{};

    final bool isIrregular = type == 'irregular';

    return <String, dynamic>{
      ...verb,
      'id': id,
      'title': title,
      'english': english,
      'bangla': bangla,
      'type': type,
      'ending': ending,
      'typeLabel':
      override['typeLabel'] ??
          (isIrregular ? 'irregular_verb'.tr : 'regular_verb'.tr),
      'endingLabel': override['endingLabel'] ?? '${ending.toLowerCase()} Verb',
      'information':
      override['information'] ??
          (isIrregular
              ? 'an_irregular_verb_used_often_in_everyday_italian'.tr
              : 'A regular ${ending.toLowerCase()} verb used for daily communication.'),
      'tenseSubtitle': override['tenseSubtitle'] ?? 'presente'.tr,
      'presentForms':
      override['presentForms'] ??
          _buildDefaultPresentForms(
            title: title,
            english: english,
            bangla: bangla,
            ending: ending,
          ),
    };
  }

  List<Map<String, dynamic>> _buildDefaultPresentForms({
    required String title,
    required String english,
    required String bangla,
    required String ending,
  }) {
    final String lowerEnding = ending.toLowerCase();
    final String stem = _verbStem(title);

    final List<String> endings = lowerEnding == '-ere'
        ? <String>['o', 'i', 'e', 'iamo', 'ete', 'ono']
        : lowerEnding == '-ire'
        ? <String>['o', 'i', 'e', 'iamo', 'ite', 'ono']
        : <String>['o', 'i', 'a', 'iamo', 'ate', 'ano'];

    final List<String> pronouns = <String>[
      'io',
      'tu',
      'lui/lei',
      'noi',
      'voi',
      'loro',
    ];

    final List<String> banglaMeanings = <String>[
      'আমি $bangla',
      'তুমি $bangla',
      'সে $bangla',
      'আমরা $bangla',
      'তোমরা $bangla',
      'তারা $bangla',
    ];

    final List<String> englishMeanings = <String>[
      'I ${english.replaceFirst('to ', '')}',
      'You ${english.replaceFirst('to ', '')}',
      'He/She ${english.replaceFirst('to ', '')}',
      'We ${english.replaceFirst('to ', '')}',
      'You all ${english.replaceFirst('to ', '')}',
      'They ${english.replaceFirst('to ', '')}',
    ];

    return List<Map<String, dynamic>>.generate(pronouns.length, (int index) {
      final String form = '$stem${endings[index]}';

      return <String, dynamic>{
        'pronoun': pronouns[index],
        'form': form,
        'bangla': banglaMeanings[index],
        'english': englishMeanings[index],
        'examples': index == 0
            ? <Map<String, dynamic>>[
          <String, dynamic>{
            'italian': 'Io $form italiano.',
            'bangla': 'আমি ইতালিয়ান বলি',
            'english': 'i_speak_italian'.tr,
          },
          <String, dynamic>{
            'italian': 'Io $form con te.',
            'bangla': 'আমি তোমার সাথে কথা বলি',
            'english': 'i_speak_with_you'.tr,
          },
        ]
            : <Map<String, dynamic>>[],
      };
    });
  }

  String _verbStem(String title) {
    if (title.length <= 3) return title;

    final String lowerTitle = title.toLowerCase();

    if (lowerTitle.endsWith('are') ||
        lowerTitle.endsWith('ere') ||
        lowerTitle.endsWith('ire')) {
      return title.substring(0, title.length - 3);
    }

    return title;
  }

  final Map<String, Map<String, dynamic>> _verbDetailOverrides =
  <String, Map<String, dynamic>>{
    'parlare': <String, dynamic>{
      'typeLabel': 'regular_verb'.tr,
      'endingLabel': '-are Verb',
      'information': 'a_regular_are_verb_used_for_speaking_or_talking'.tr,
      'tenseSubtitle': 'presente_i_speak'.tr,
      'presentForms': <Map<String, dynamic>>[
        <String, dynamic>{
          'pronoun': 'io',
          'form': 'parlo',
          'bangla': 'আমি বলি',
          'english': 'i_speak'.tr,
          'examples': <Map<String, dynamic>>[
            <String, dynamic>{
              'italian': 'io_parlo_italiano'.tr,
              'bangla': 'আমি ইতালিয়ান বলি',
              'english': 'i_speak_italian'.tr,
            },
            <String, dynamic>{
              'italian': 'io_parlo_con_te'.tr,
              'bangla': 'আমি তোমার সাথে কথা বলি',
              'english': 'i_speak_with_you'.tr,
            },
          ],
        },
        <String, dynamic>{
          'pronoun': 'tu',
          'form': 'parli',
          'bangla': 'তুমি বল',
          'english': 'you_speak'.tr,
          'examples': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'pronoun': 'lui/lei',
          'form': 'parla',
          'bangla': 'সে বলে',
          'english': 'he_she_speaks'.tr,
          'examples': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'pronoun': 'noi',
          'form': 'parliamo',
          'bangla': 'আমরা বলি',
          'english': 'we_speak'.tr,
          'examples': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'pronoun': 'voi',
          'form': 'parlate',
          'bangla': 'তোমরা বল',
          'english': 'you_all_speak'.tr,
          'examples': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'pronoun': 'loro',
          'form': 'parlano',
          'bangla': 'তারা বলে',
          'english': 'they_speak'.tr,
          'examples': <Map<String, dynamic>>[],
        },
      ],
    },
    'essere': <String, dynamic>{
      'typeLabel': 'irregular_verb'.tr,
      'endingLabel': '-ere Verb',
      'information':
      'An irregular verb used for being, identity, and state.',
      'tenseSubtitle': 'presente_i_am'.tr,
      'presentForms': <Map<String, dynamic>>[
        <String, dynamic>{
          'pronoun': 'io',
          'form': 'sono',
          'bangla': 'আমি আছি',
          'english': 'i_am'.tr,
          'examples': <Map<String, dynamic>>[
            <String, dynamic>{
              'italian': 'io_sono_felice'.tr,
              'bangla': 'আমি খুশি',
              'english': 'i_am_happy'.tr,
            },
            <String, dynamic>{
              'italian': 'io_sono_uno_studente'.tr,
              'bangla': 'আমি একজন ছাত্র',
              'english': 'i_am_a_student'.tr,
            },
          ],
        },
        <String, dynamic>{
          'pronoun': 'tu',
          'form': 'sei',
          'bangla': 'তুমি আছ',
          'english': 'you_are'.tr,
          'examples': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'pronoun': 'lui/lei',
          'form': 'è',
          'bangla': 'সে আছে',
          'english': 'he_she_is'.tr,
          'examples': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'pronoun': 'noi',
          'form': 'siamo',
          'bangla': 'আমরা আছি',
          'english': 'we_are'.tr,
          'examples': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'pronoun': 'voi',
          'form': 'siete',
          'bangla': 'তোমরা আছ',
          'english': 'you_all_are'.tr,
          'examples': <Map<String, dynamic>>[],
        },
        <String, dynamic>{
          'pronoun': 'loro',
          'form': 'sono',
          'bangla': 'তারা আছে',
          'english': 'they_are'.tr,
          'examples': <Map<String, dynamic>>[],
        },
      ],
    },
  };
  void openVerbDetails(Map<String, dynamic> verb) {
    setSelectedVerbForDetails(verb);

    Get.toNamed(
      AppRoutes.verbDetails,
      arguments: Map<String, dynamic>.from(currentVerbDetails),
    );
  }

  final RxBool isSurvivalLoading = false.obs;
  final RxBool isOpeningSurvivalPdf = false.obs;
  final RxString survivalError = ''.obs;
  final RxList<SurvivalSituationModel> survivalItalianItems =
      <SurvivalSituationModel>[].obs;
  final Rxn<SurvivalProgressSummaryModel> survivalProgress =
  Rxn<SurvivalProgressSummaryModel>();
  final Rxn<PracticeHubPdfDocumentModel> selectedPracticePdf =
  Rxn<PracticeHubPdfDocumentModel>();
  final RxInt currentSurvivalPdfPage = 1.obs;
  final RxInt currentSurvivalPdfTotalPages = 1.obs;
  final Set<String> _survivalCompletionRequests = <String>{};

  SurvivalSituationModel? get survivalHeroItem {
    if (survivalItalianItems.isEmpty) return null;

    return survivalItalianItems.firstWhere(
          (SurvivalSituationModel item) =>
      item.cardVariant == SurvivalCardVariant.hero,
      orElse: () => survivalItalianItems.first,
    );
  }

  List<SurvivalSituationModel> get survivalNormalItems {
    final String? heroId = survivalHeroItem?.id;
    return survivalItalianItems
        .where(
          (SurvivalSituationModel item) =>
      item.id != heroId && item.cardVariant != SurvivalCardVariant.wide,
    )
        .toList(growable: false);
  }

  List<SurvivalSituationModel> get survivalWideItems {
    final String? heroId = survivalHeroItem?.id;
    return survivalItalianItems
        .where(
          (SurvivalSituationModel item) =>
      item.id != heroId && item.cardVariant == SurvivalCardVariant.wide,
    )
        .toList(growable: false);
  }

  int get survivalTotalSituations =>
      survivalProgress.value?.totalCount ?? survivalItalianItems.length;

  int get survivalSituationsLearned =>
      survivalProgress.value?.completedCount ??
          survivalItalianItems
              .where((SurvivalSituationModel item) => item.isCompleted)
              .length;

  double get survivalLearningProgress =>
      survivalProgress.value?.completionRate ?? 0;

  PracticeHubPdfDocumentModel? get currentPracticePdf =>
      selectedPracticePdf.value;

  bool get canGoPreviousSurvivalPdfPage => currentSurvivalPdfPage.value > 1;

  bool get canGoNextSurvivalPdfPage =>
      currentSurvivalPdfPage.value < currentSurvivalPdfTotalPages.value;

  Future<void> loadSurvivalItalian({bool showError = true}) async {
    if (isSurvivalLoading.value) return;

    isSurvivalLoading.value = true;
    survivalError.value = '';
    try {
      final ApiResult<SurvivalSituationsResponseModel> result =
      await ApiErrorHandler.call<SurvivalSituationsResponseModel>(
            () => _practiceHubApiService.fetchSurvivalSituations(),
        showError: showError,
      );

      if (!result.isSuccess || result.data == null) {
        survivalError.value =
            result.error ?? 'unable_to_load_survival_italian_situations'.tr;
        return;
      }

      survivalItalianItems.assignAll(result.data!.items);
      survivalProgress.value = result.data!.progress;
    } finally {
      isSurvivalLoading.value = false;
    }
  }

  void onSurvivalItalianTap() {
    loadSurvivalItalian(showError: false);
    Get.toNamed(AppRoutes.survivalItalian);
  }

  void onSurvivalBackTap() {
    Get.back<void>();
  }

  Future<void> openSurvivalPdf(SurvivalSituationModel item) async {
    if (isOpeningSurvivalPdf.value) return;

    isOpeningSurvivalPdf.value = true;
    try {
      final ApiResult<SurvivalSituationDetailModel> result =
      await ApiErrorHandler.call<SurvivalSituationDetailModel>(
            () => _practiceHubApiService.fetchSurvivalSituationDetails(
          situationId: item.id,
        ),
      );

      final SurvivalResourceModel? resource = result.data?.resource;
      if (!result.isSuccess ||
          resource == null ||
          resource.signedReadUrl.isEmpty) {
        Get.snackbar(
          'resource_unavailable'.tr,
          'no_pdf_resource_for_situation'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black87,
        );
        return;
      }

      final PracticeHubPdfDocumentModel document =
      PracticeHubPdfDocumentModel(
        title:
        result.data!.situation.title,
        source:
        resource.signedReadUrl,
        sourceType:
        PracticeHubPdfSourceType.network,
        pageCount:
        resource.pageCount,
        situationId:
        result.data!.situation.id,
        isSituationCompleted:
        result.data!.situation.isCompleted,
      );

      selectedPracticePdf.value = document;

      currentSurvivalPdfPage.value = 1;
      currentSurvivalPdfTotalPages.value =
      document.pageCount > 0 ? document.pageCount : 1;

      await Get.to<void>(
            () => AppPdfViewer(
          title: document.title,
          source: document.source,
          sourceType:
          AppPdfSourceType.network,
          sourceId:
          'survival_italian_pdf_viewer',
          initialPageCount:
          document.pageCount,

          // Required for completing the
          // situation after the final page.
          onDocumentLoaded:
          onSurvivalPdfDocumentLoaded,
          onPageChanged:
          onSurvivalPdfPageChanged,
        ),
      );
    } finally {
      isOpeningSurvivalPdf.value = false;
    }
  }

  void onSurvivalPdfDocumentLoaded(int totalPages) {
    currentSurvivalPdfPage.value = 1;
    currentSurvivalPdfTotalPages.value = totalPages > 0 ? totalPages : 1;
    _completeCurrentSurvivalSituationIfNeeded();
  }

  void onSurvivalPdfPageChanged(int pageNumber) {
    currentSurvivalPdfPage.value = pageNumber;
    _completeCurrentSurvivalSituationIfNeeded();
  }

  void onPdfViewerCloseTap() {
    Get.back<void>();
  }

  Future<void> _completeCurrentSurvivalSituationIfNeeded() async {
    final PracticeHubPdfDocumentModel? document = currentPracticePdf;
    final String? situationId = document?.situationId;

    if (document == null ||
        situationId == null ||
        document.isSituationCompleted ||
        currentSurvivalPdfPage.value < currentSurvivalPdfTotalPages.value ||
        _survivalCompletionRequests.contains(situationId)) {
      return;
    }

    _survivalCompletionRequests.add(situationId);
    try {
      final ApiResult<void> result = await ApiErrorHandler.call<void>(
            () => _practiceHubApiService.completeSurvivalSituation(
          situationId: situationId,
        ),
        showError: false,
      );
      if (!result.isSuccess) return;

      selectedPracticePdf.value = document.copyWith(isSituationCompleted: true);
      final int index = survivalItalianItems.indexWhere(
            (SurvivalSituationModel item) => item.id == situationId,
      );
      if (index >= 0 && !survivalItalianItems[index].isCompleted) {
        survivalItalianItems[index] = survivalItalianItems[index].copyWith(
          isCompleted: true,
        );
        final SurvivalProgressSummaryModel current =
            survivalProgress.value ??
                SurvivalProgressSummaryModel(
                  completedCount: 0,
                  totalCount: survivalItalianItems.length,
                );
        survivalProgress.value = current.copyWith(
          completedCount: (current.completedCount + 1)
              .clamp(0, current.totalCount)
              .toInt(),
        );
        survivalItalianItems.refresh();
        loadPracticeHubOverview();
      }
    } finally {
      _survivalCompletionRequests.remove(situationId);
    }
  }

  final TextEditingController jobPhraseSearchController =
  TextEditingController();

  final RxString jobPhraseSearchQuery = ''.obs;
  final RxMap<String, dynamic> selectedJobTrack = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> selectedJobPhraseCategory =
      <String, dynamic>{}.obs;
  final RxString currentPlayingJobPhraseId = ''.obs;
  final RxDouble currentJobPhraseAudioProgress = 0.31.obs;

  final RxList<Map<String, dynamic>> jobTracks = <Map<String, dynamic>>[
    {
      'id': 'restaurant',
      'title': 'restaurant_njob'.tr,
      'detailsTitle': 'gen_restaurant_job'.tr,
      'bangla': 'রেস্টুরেন্ট এর কাজ',
      'icon': Icons.restaurant_rounded,
      'background': const Color(0xFFFFF0E6),
      'iconBackground': const Color(0xFFFFF8F2),
      'color': const Color(0xFF9B5C00),
      'theoryBackground': const Color(0xFFFCF2E8),
      'videoProgress': 60,
      'videoImage': 'assets/heroes/job_intro_waitering.png',
      'theoryPdfAsset': 'assets/pdfs/job_sentences/restaurant_basics.pdf',
    },
    {
      'id': 'kitchen',
      'title': 'kitchen_job'.tr,
      'detailsTitle': 'example_job'.tr,
      'bangla': 'রান্নাঘরের কাজ',
      'icon': Icons.kitchen_rounded,
      'background': const Color(0xFFE8F7EA),
      'iconBackground': const Color(0xFFF8FFF8),
      'color': AppColors.primaryGreen,
      'theoryBackground': const Color(0xFFEAF8EA),
      'videoProgress': 60,
      'videoImage': 'assets/heroes/job_intro_waitering.png',
      'theoryPdfAsset': 'assets/pdfs/job_sentences/kitchen_basics.pdf',
    },
    {
      'id': 'supermarket',
      'title': 'supermarket'.tr,
      'detailsTitle': 'supermarket'.tr,
      'bangla': 'সুপারমার্কেট এর কাজ',
      'icon': Icons.shopping_bag_rounded,
      'background': const Color(0xFFE1F2FF),
      'iconBackground': const Color(0xFFF5FBFF),
      'color': const Color(0xFF006CA8),
      'theoryBackground': const Color(0xFFEAF5FF),
      'videoProgress': 60,
      'videoImage': 'assets/heroes/job_intro_waitering.png',
      'theoryPdfAsset': 'assets/pdfs/job_sentences/supermarket_basics.pdf',
    },
    {
      'id': 'cleaning',
      'title': 'cleaning_nservices'.tr,
      'detailsTitle': 'cleaning_services'.tr,
      'bangla': 'ক্লিনিং সার্ভিস এর কাজ',
      'icon': Icons.cleaning_services_rounded,
      'background': const Color(0xFFF4E2F5),
      'iconBackground': const Color(0xFFFFF6FF),
      'color': const Color(0xFF8A2DB5),
      'theoryBackground': const Color(0xFFF6E8F8),
      'videoProgress': 60,
      'videoImage': 'assets/heroes/job_intro_waitering.png',
      'theoryPdfAsset': 'assets/pdfs/job_sentences/cleaning_basics.pdf',
    },
  ].obs;

  final List<Map<String, dynamic>> jobPhraseCategories = <Map<String, dynamic>>[
    {
      'id': 'taking_orders',
      'title': 'taking_orders'.tr,
      'bangla': 'অর্ডার নেওয়া',
      'icon': Icons.format_list_bulleted_rounded,
      'learned': 12,
      'total': 25,
      'showIcon': true,
    },
    {
      'id': 'talking_to_chef',
      'title': 'talking_to_chef'.tr,
      'bangla': 'শেফের সাথে কথা',
      'icon': Icons.room_service_rounded,
      'learned': 8,
      'total': 20,
      'showIcon': true,
    },
    {
      'id': 'payments',
      'title': 'payments'.tr,
      'bangla': 'পেমেন্ট নেওয়া',
      'icon': Icons.receipt_long_rounded,
      'learned': 7,
      'total': 18,
      'showIcon': true,
    },
    {
      'id': 'cleaning_tables',
      'title': 'cleaning_tables'.tr,
      'bangla': 'টেবিল পরিষ্কার করা',
      'icon': Icons.cleaning_services_rounded,
      'learned': 6,
      'total': 15,
      'showIcon': true,
    },
  ];

  final Map<String, List<Map<String, dynamic>>> jobPhrasesByCategory =
  <String, List<Map<String, dynamic>>>{
    'taking_orders': <Map<String, dynamic>>[
      {
        'id': 'order_1',
        'italian': 'un_tavolo_per_ndue_per_nfavore'.tr,
        'bangla': 'দুইজনের জন্য একটি\nটেবিল, দয়া\nকরে।',
      },
      {
        'id': 'order_2',
        'italian': 'buongiorno_ncosa_desidera_nordinare'.tr,
        'bangla': 'শুভ সকাল, আপনি কি\nঅর্ডার করতে\nচান?',
      },
      {
        'id': 'order_3',
        'italian': 'il_conto_per_nfavore'.tr,
        'bangla': 'বিলটা দিন, দয়া করে।',
      },
      {
        'id': 'order_4',
        'italian': 'avete_opzioni_nvegetariane'.tr,
        'bangla': 'আপনার কি নিরামিষ\nকোনো পদ\nআছে?',
      },
    ],
    'talking_to_chef': <Map<String, dynamic>>[
      {
        'id': 'chef_1',
        'italian': 'chef_il_tavolo_ncinque_aspetta'.tr,
        'bangla': 'শেফ, পাঁচ নম্বর টেবিল\nঅপেক্ষা করছে।',
      },
      {
        'id': 'chef_2',
        'italian': 'questo_piatto_npronto'.tr,
        'bangla': 'এই খাবারটি কি প্রস্তুত?',
      },
      {
        'id': 'chef_3',
        'italian': 'serve_pi_sale'.tr,
        'bangla': 'আরও লবণ লাগবে।',
      },
    ],
    'payments': <Map<String, dynamic>>[
      {
        'id': 'payment_1',
        'italian': 'paga_in_contanti_no_con_carta'.tr,
        'bangla': 'আপনি নগদ নাকি কার্ডে\nপেমেন্ট করবেন?',
      },
      {
        'id': 'payment_2',
        'italian': 'ecco_lo_scontrino'.tr,
        'bangla': 'এই নিন রসিদ।',
      },
      {
        'id': 'payment_3',
        'italian': 'il_totale_venti_neuro'.tr,
        'bangla': 'মোট বিশ ইউরো।',
      },
    ],
    'cleaning_tables': <Map<String, dynamic>>[
      {
        'id': 'clean_1',
        'italian': 'pulisco_il_tavolo_nsubito'.tr,
        'bangla': 'আমি এখনই টেবিল পরিষ্কার\nকরছি।',
      },
      {
        'id': 'clean_2',
        'italian': 'serve_un_nuovo_nbicchiere'.tr,
        'bangla': 'নতুন গ্লাস লাগবে?',
      },
      {
        'id': 'clean_3',
        'italian': 'porto_via_i_piatti'.tr,
        'bangla': 'আমি প্লেটগুলো নিয়ে যাচ্ছি।',
      },
    ],
  };

  Map<String, dynamic> get currentJobTrack {
    if (selectedJobTrack.isNotEmpty) {
      return Map<String, dynamic>.from(selectedJobTrack);
    }

    return Map<String, dynamic>.from(jobTracks.first);
  }

  List<Map<String, dynamic>> get currentJobCategories {
    final String jobId = currentJobTrack['id'] as String? ?? 'restaurant';

    return jobPhraseCategories.map((Map<String, dynamic> category) {
      return <String, dynamic>{...category, 'jobid'.tr: jobId};
    }).toList();
  }

  Map<String, dynamic> get currentJobPhraseCategory {
    if (selectedJobPhraseCategory.isNotEmpty) {
      return Map<String, dynamic>.from(selectedJobPhraseCategory);
    }

    return Map<String, dynamic>.from(jobPhraseCategories.first);
  }

  List<Map<String, dynamic>> get currentJobPhrases {
    final String categoryId =
        currentJobPhraseCategory['id'] as String? ?? 'taking_orders';

    return jobPhrasesByCategory[categoryId] ?? <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> get filteredJobPhrases {
    final String query = jobPhraseSearchQuery.value.trim().toLowerCase();

    if (query.isEmpty) return currentJobPhrases;

    return currentJobPhrases.where((Map<String, dynamic> phrase) {
      final String italian = (phrase['italian'] as String).toLowerCase();
      final String bangla = (phrase['bangla'] as String).toLowerCase();

      return italian.contains(query) || bangla.contains(query);
    }).toList();
  }

  void onJobSentencesTap() {
    Get.toNamed(AppRoutes.jobSentences);
  }

  void onJobSentencesBackTap() {
    Get.back<void>();
  }

  void openJobTrackDetails(Map<String, dynamic> item) {
    selectedJobTrack
      ..clear()
      ..addAll(Map<String, dynamic>.from(item));

    selectedJobPhraseCategory.clear();
    currentPlayingJobPhraseId.value = '';
    clearJobPhraseSearch();

    Get.toNamed(AppRoutes.jobDetails);
  }

  void onJobDetailsBackTap() {
    Get.back<void>();
  }

  void onJobIntroVideoTap() {
    Get.snackbar(
      'video_1'.tr,
      'opening_introduction_video'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  void openJobPhraseCategory(Map<String, dynamic> item) {
    selectedJobPhraseCategory
      ..clear()
      ..addAll(Map<String, dynamic>.from(item));

    currentPlayingJobPhraseId.value = 'order_1';
    currentJobPhraseAudioProgress.value = 0.31;
    clearJobPhraseSearch();

    Get.toNamed(AppRoutes.jobPhraseDetails);
  }

  void onJobPhraseBackTap() {
    Get.back<void>();
  }

  void onJobPhraseSearchChanged(String value) {
    jobPhraseSearchQuery.value = value;
  }

  void clearJobPhraseSearch() {
    jobPhraseSearchController.clear();
    jobPhraseSearchQuery.value = '';
  }

  void playJobPhrase(String id) {
    if (currentPlayingJobPhraseId.value == id) {
      currentPlayingJobPhraseId.value = '';
      return;
    }

    currentPlayingJobPhraseId.value = id;
    currentJobPhraseAudioProgress.value = 0.31;
  }

  void openJobTheoryBook() {
    final Map<String, dynamic> job =
        currentJobTrack;

    final String source =
    (job['theoryPdfAsset']
    as String? ??
        '')
        .trim();

    if (source.isEmpty) {
      Get.snackbar(
        'gen_theory_book'.tr,
        'theory_resource_is_not_available'.tr,
      );
      return;
    }

    final String title =
    'lesson_basics_title'.trParams(
      <String, String>{
        'lesson':
        (job['detailsTitle']
        as String? ??
            '')
            .toString(),
      },
    );

    Get.to<void>(
          () => AppPdfViewer(
        title: title,
        source: source,
        sourceType:
        AppPdfSourceType.asset,
        sourceId:
        'job_theory_asset_pdf_viewer',
      ),
    );
  }

  final RxBool isDailyChallengesLoading = false.obs;
  final RxBool isClaimingDailyTask = false.obs;
  final RxBool isOpeningDailyChest = false.obs;
  final RxString dailyChallengesError = ''.obs;
  final Rxn<DailyChallengeDashboardModel> dailyChallengeDashboard =
  Rxn<DailyChallengeDashboardModel>();
  final RxList<DailyChallengeTaskModel> dailyChallengeTasks =
      <DailyChallengeTaskModel>[].obs;
  final Rxn<DailyChestRewardModel> lastDailyChestReward =
  Rxn<DailyChestRewardModel>();

  int get dailyChallengeXp => dailyChallengeDashboard.value?.totalXp ?? 0;
  int get dailyStreakDays =>
      dailyChallengeDashboard.value?.streak.currentDays ?? 0;
  String get dailyChallengeLevelLabel =>
      dailyChallengeDashboard.value?.levelLabel ?? 'level_1_explorer'.tr;
  int get dailyCompletedTaskCount =>
      dailyChallengeDashboard.value?.completedTaskCount ?? 0;
  bool get isDailyChestUnlocked =>
      dailyChallengeDashboard.value?.chest.isUnlocked ?? false;
  bool get isDailyChestOpened =>
      dailyChallengeDashboard.value?.chest.isOpened ?? false;

  Future<void> loadDailyChallenges({bool showError = true}) async {
    if (isDailyChallengesLoading.value) return;

    isDailyChallengesLoading.value = true;
    dailyChallengesError.value = '';
    try {
      final ApiResult<DailyChallengeDashboardModel> result =
      await ApiErrorHandler.call<DailyChallengeDashboardModel>(
            () => _practiceHubApiService.fetchDailyChallenges(),
        showError: showError,
      );
      if (!result.isSuccess || result.data == null) {
        dailyChallengesError.value =
            result.error ?? 'unable_to_load_daily_challenges'.tr;
        return;
      }

      _applyDailyChallengeDashboard(result.data!);
    } finally {
      isDailyChallengesLoading.value = false;
    }
  }

  void _applyDailyChallengeDashboard(DailyChallengeDashboardModel dashboard) {
    dailyChallengeDashboard.value = dashboard;
    dailyChallengeTasks.assignAll(dashboard.tasks);
    if (dashboard.chest.reward != null) {
      lastDailyChestReward.value = dashboard.chest.reward;
    }
  }

  void onDailyChallengesTap() {
    loadDailyChallenges(showError: false);
    Get.toNamed(AppRoutes.dailyChallenges);
  }

  void onDailyChallengesBackTap() {
    Get.back<void>();
  }

  Future<void> claimDailyChallengeTask(DailyChallengeTaskModel task) async {
    if (isClaimingDailyTask.value || task.isClaimed) return;

    if (!task.canClaim) {
      Get.snackbar(
        'challenge_not_completed'.tr,
        'finish_task_first_claim_xp'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
      return;
    }

    final DailyChallengeDashboardModel? dashboard =
        dailyChallengeDashboard.value;
    if (dashboard == null) return;

    isClaimingDailyTask.value = true;
    try {
      final ApiResult<DailyChallengeDashboardModel> result =
      await ApiErrorHandler.call<DailyChallengeDashboardModel>(
            () => _practiceHubApiService.claimDailyChallengeTask(
          taskKey: task.taskKey,
          challengeDate: dashboard.challengeDate,
        ),
      );
      if (!result.isSuccess || result.data == null) return;

      _applyDailyChallengeDashboard(result.data!);
      loadPracticeHubOverview();
    } finally {
      isClaimingDailyTask.value = false;
    }
  }

  Future<void> onDailyChestTap() async {
    final DailyChallengeDashboardModel? dashboard =
        dailyChallengeDashboard.value;
    if (dashboard == null || isOpeningDailyChest.value) return;

    if (!dashboard.chest.isUnlocked) {
      Get.snackbar(
        'chest_locked'.tr,
        'complete_daily_tasks_before_chest'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
      return;
    }

    if (dashboard.chest.isOpened && dashboard.chest.reward != null) {
      lastDailyChestReward.value = dashboard.chest.reward;
      Get.to<void>(() => const DailyChestUnlockedView());
      return;
    }

    isOpeningDailyChest.value = true;
    try {
      final ApiResult<DailyChestRewardModel> result =
      await ApiErrorHandler.call<DailyChestRewardModel>(
            () => _practiceHubApiService.openDailyChest(
          challengeDate: dashboard.challengeDate,
        ),
      );
      if (!result.isSuccess || result.data == null) return;

      lastDailyChestReward.value = result.data;
      await loadDailyChallenges(showError: false);
      Get.to<void>(() => const DailyChestUnlockedView());
    } finally {
      isOpeningDailyChest.value = false;
    }
  }

  @override
  void onClose() {
    importantVerbSearchController.dispose();
    savedVerbSearchController.dispose();
    jobPhraseSearchController.dispose();
    super.onClose();
  }
}
