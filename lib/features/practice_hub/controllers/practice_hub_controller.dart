import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_error_handler.dart';
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

      courses.assignAll(result.data!.courses);

      if (selectedCourseIndex.value >= courses.length) {
        selectedCourseIndex.value = 0;
      }

      _syncFinalExamState();
    } finally {
      isCoursesLoading.value = false;
    }
  }

  void _syncFinalExamState() {
    if (courses.isEmpty) {
      isFinalExamReady.value = false;
      return;
    }

    isFinalExamReady.value =
        courses[selectedCourseIndex.value].progress >= 0.8;
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
            result.error ?? 'Unable to load Practice Hub information.';
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
    loadCourses();
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
      arguments: CourseDetailRouteArguments(
        course: course,
        controllerTag: tag,
      ),
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
        errorTitle: 'Final Exams',
      );
      if (result.isSuccess && result.data != null) {
        finalExamCourses.assignAll(result.data!);
      }
    } finally {
      isFinalExamsLoading.value = false;
    }
  }

  void onFinalExamCardTap(PracticeFinalExamCourseModel item) {
    if (item.isUnlocked) {
      openFinalExam(item);
      return;
    }

    Get.snackbar(
      'Final Exam Locked',
      item.message.isEmpty
          ? 'Complete ${item.unlockCompletionPercent}% of ${item.courseName} to unlock the final exam.'
          : item.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  Future<void> openFinalExam(PracticeFinalExamCourseModel item) async {
    if (!item.isUnlocked) return;

    final String tag =
        'final_exam_${item.courseId}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.finalExamOverview,
      arguments: FinalExamRouteArguments(
        controllerTag: tag,
        courseId: item.courseId,
      ),
    );
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
      'Notification Set',
      'We will notify you before the webinar starts.',
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
    if (filter == 'All Verbs') return source;

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
      'Search Results',
      'Showing all matched verbs.',
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
    return currentVerbDetails['tenseSubtitle'] as String? ?? 'Presente';
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
    final String title = currentVerbDetails['title'] as String? ?? 'Verb';

    Get.snackbar(
      'Audio',
      'Playing pronunciation for $title',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  void playVerbFormAudio(String text) {
    if (text.trim().isEmpty) return;

    Get.snackbar(
      'Audio',
      'Playing $text',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  void onVerbTranslateTap() {
    Get.snackbar(
      'Translation',
      'Language helper will open here.',
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
          (isIrregular ? 'Irregular Verb' : 'Regular Verb'),
      'endingLabel': override['endingLabel'] ?? '${ending.toLowerCase()} Verb',
      'information':
          override['information'] ??
          (isIrregular
              ? 'An irregular verb used often in everyday Italian.'
              : 'A regular ${ending.toLowerCase()} verb used for daily communication.'),
      'tenseSubtitle': override['tenseSubtitle'] ?? 'Presente',
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
                  'english': 'I speak Italian.',
                },
                <String, dynamic>{
                  'italian': 'Io $form con te.',
                  'bangla': 'আমি তোমার সাথে কথা বলি',
                  'english': 'I speak with you.',
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
          'typeLabel': 'Regular Verb',
          'endingLabel': '-are Verb',
          'information': 'A regular -are verb used for speaking or talking.',
          'tenseSubtitle': 'Presente (I speak)',
          'presentForms': <Map<String, dynamic>>[
            <String, dynamic>{
              'pronoun': 'io',
              'form': 'parlo',
              'bangla': 'আমি বলি',
              'english': 'I speak',
              'examples': <Map<String, dynamic>>[
                <String, dynamic>{
                  'italian': 'Io parlo italiano.',
                  'bangla': 'আমি ইতালিয়ান বলি',
                  'english': 'I speak Italian.',
                },
                <String, dynamic>{
                  'italian': 'Io parlo con te.',
                  'bangla': 'আমি তোমার সাথে কথা বলি',
                  'english': 'I speak with you.',
                },
              ],
            },
            <String, dynamic>{
              'pronoun': 'tu',
              'form': 'parli',
              'bangla': 'তুমি বল',
              'english': 'You speak',
              'examples': <Map<String, dynamic>>[],
            },
            <String, dynamic>{
              'pronoun': 'lui/lei',
              'form': 'parla',
              'bangla': 'সে বলে',
              'english': 'He/She speaks',
              'examples': <Map<String, dynamic>>[],
            },
            <String, dynamic>{
              'pronoun': 'noi',
              'form': 'parliamo',
              'bangla': 'আমরা বলি',
              'english': 'We speak',
              'examples': <Map<String, dynamic>>[],
            },
            <String, dynamic>{
              'pronoun': 'voi',
              'form': 'parlate',
              'bangla': 'তোমরা বল',
              'english': 'You all speak',
              'examples': <Map<String, dynamic>>[],
            },
            <String, dynamic>{
              'pronoun': 'loro',
              'form': 'parlano',
              'bangla': 'তারা বলে',
              'english': 'They speak',
              'examples': <Map<String, dynamic>>[],
            },
          ],
        },
        'essere': <String, dynamic>{
          'typeLabel': 'Irregular Verb',
          'endingLabel': '-ere Verb',
          'information':
              'An irregular verb used for being, identity, and state.',
          'tenseSubtitle': 'Presente (I am)',
          'presentForms': <Map<String, dynamic>>[
            <String, dynamic>{
              'pronoun': 'io',
              'form': 'sono',
              'bangla': 'আমি আছি',
              'english': 'I am',
              'examples': <Map<String, dynamic>>[
                <String, dynamic>{
                  'italian': 'Io sono felice.',
                  'bangla': 'আমি খুশি',
                  'english': 'I am happy.',
                },
                <String, dynamic>{
                  'italian': 'Io sono uno studente.',
                  'bangla': 'আমি একজন ছাত্র',
                  'english': 'I am a student.',
                },
              ],
            },
            <String, dynamic>{
              'pronoun': 'tu',
              'form': 'sei',
              'bangla': 'তুমি আছ',
              'english': 'You are',
              'examples': <Map<String, dynamic>>[],
            },
            <String, dynamic>{
              'pronoun': 'lui/lei',
              'form': 'è',
              'bangla': 'সে আছে',
              'english': 'He/She is',
              'examples': <Map<String, dynamic>>[],
            },
            <String, dynamic>{
              'pronoun': 'noi',
              'form': 'siamo',
              'bangla': 'আমরা আছি',
              'english': 'We are',
              'examples': <Map<String, dynamic>>[],
            },
            <String, dynamic>{
              'pronoun': 'voi',
              'form': 'siete',
              'bangla': 'তোমরা আছ',
              'english': 'You all are',
              'examples': <Map<String, dynamic>>[],
            },
            <String, dynamic>{
              'pronoun': 'loro',
              'form': 'sono',
              'bangla': 'তারা আছে',
              'english': 'They are',
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
              item.id != heroId &&
              item.cardVariant != SurvivalCardVariant.wide,
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

  bool get canGoPreviousSurvivalPdfPage =>
      currentSurvivalPdfPage.value > 1;

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
            result.error ?? 'Unable to load Survival Italian situations.';
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
      if (!result.isSuccess || resource == null || resource.signedReadUrl.isEmpty) {
        Get.snackbar(
          'Resource unavailable',
          'No PDF resource has been provided for this situation.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black87,
        );
        return;
      }

      selectedPracticePdf.value = PracticeHubPdfDocumentModel(
        title: result.data!.situation.title,
        source: resource.signedReadUrl,
        sourceType: PracticeHubPdfSourceType.network,
        situationId: result.data!.situation.id,
        isSituationCompleted: result.data!.situation.isCompleted,
      );
      currentSurvivalPdfPage.value = 1;
      currentSurvivalPdfTotalPages.value = 1;

      await Get.toNamed(AppRoutes.practiceHubPdfViewer);
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

      selectedPracticePdf.value = document.copyWith(
        isSituationCompleted: true,
      );
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
      'title': 'Restaurant\nJob',
      'detailsTitle': 'Restaurant Job',
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
      'title': 'Kitchen Job',
      'detailsTitle': 'Example Job',
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
      'title': 'Supermarket',
      'detailsTitle': 'Supermarket',
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
      'title': 'Cleaning\nServices',
      'detailsTitle': 'Cleaning Services',
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
      'title': 'Taking Orders',
      'bangla': 'অর্ডার নেওয়া',
      'icon': Icons.format_list_bulleted_rounded,
      'learned': 12,
      'total': 25,
      'showIcon': true,
    },
    {
      'id': 'talking_to_chef',
      'title': 'Talking to Chef',
      'bangla': 'শেফের সাথে কথা',
      'icon': Icons.room_service_rounded,
      'learned': 8,
      'total': 20,
      'showIcon': true,
    },
    {
      'id': 'payments',
      'title': 'Payments',
      'bangla': 'পেমেন্ট নেওয়া',
      'icon': Icons.receipt_long_rounded,
      'learned': 7,
      'total': 18,
      'showIcon': true,
    },
    {
      'id': 'cleaning_tables',
      'title': 'Cleaning Tables',
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
            'italian': 'Un tavolo per\ndue, per\nfavore.',
            'bangla': 'দুইজনের জন্য একটি\nটেবিল, দয়া\nকরে।',
          },
          {
            'id': 'order_2',
            'italian': 'Buongiorno,\ncosa desidera\nordinare?',
            'bangla': 'শুভ সকাল, আপনি কি\nঅর্ডার করতে\nচান?',
          },
          {
            'id': 'order_3',
            'italian': 'Il conto, per\nfavore.',
            'bangla': 'বিলটা দিন, দয়া করে।',
          },
          {
            'id': 'order_4',
            'italian': 'Avete opzioni\nvegetariane?',
            'bangla': 'আপনার কি নিরামিষ\nকোনো পদ\nআছে?',
          },
        ],
        'talking_to_chef': <Map<String, dynamic>>[
          {
            'id': 'chef_1',
            'italian': 'Chef, il tavolo\ncinque aspetta.',
            'bangla': 'শেফ, পাঁচ নম্বর টেবিল\nঅপেক্ষা করছে।',
          },
          {
            'id': 'chef_2',
            'italian': 'Questo piatto è\npronto?',
            'bangla': 'এই খাবারটি কি প্রস্তুত?',
          },
          {
            'id': 'chef_3',
            'italian': 'Serve più sale.',
            'bangla': 'আরও লবণ লাগবে।',
          },
        ],
        'payments': <Map<String, dynamic>>[
          {
            'id': 'payment_1',
            'italian': 'Paga in contanti\no con carta?',
            'bangla': 'আপনি নগদ নাকি কার্ডে\nপেমেন্ট করবেন?',
          },
          {
            'id': 'payment_2',
            'italian': 'Ecco lo scontrino.',
            'bangla': 'এই নিন রসিদ।',
          },
          {
            'id': 'payment_3',
            'italian': 'Il totale è venti\neuro.',
            'bangla': 'মোট বিশ ইউরো।',
          },
        ],
        'cleaning_tables': <Map<String, dynamic>>[
          {
            'id': 'clean_1',
            'italian': 'Pulisco il tavolo\nsubito.',
            'bangla': 'আমি এখনই টেবিল পরিষ্কার\nকরছি।',
          },
          {
            'id': 'clean_2',
            'italian': 'Serve un nuovo\nbicchiere?',
            'bangla': 'নতুন গ্লাস লাগবে?',
          },
          {
            'id': 'clean_3',
            'italian': 'Porto via i piatti.',
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
      return <String, dynamic>{...category, 'jobId': jobId};
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
      'Video',
      'Opening introduction video...',
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
    final Map<String, dynamic> job = currentJobTrack;

    selectedPracticePdf.value = PracticeHubPdfDocumentModel(
      title: 'Lesson: ${job['detailsTitle']} Basics',
      source: job['theoryPdfAsset'] as String,
      sourceType: PracticeHubPdfSourceType.asset,
    );
    currentSurvivalPdfPage.value = 1;
    currentSurvivalPdfTotalPages.value = 1;

    Get.toNamed(AppRoutes.practiceHubPdfViewer);
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
      dailyChallengeDashboard.value?.levelLabel ?? 'Level 1 Explorer';
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
            result.error ?? 'Unable to load daily challenges.';
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
        'Challenge not completed',
        'Finish this task first to claim XP.',
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
        'Chest Locked',
        'Complete all daily tasks before opening the chest.',
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
