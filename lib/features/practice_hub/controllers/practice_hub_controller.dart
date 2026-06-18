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

class PracticeHubController extends GetxController {
  final CoursesApiService _coursesApiService;

  PracticeHubController({required CoursesApiService coursesApiService})
    : _coursesApiService = coursesApiService;

  final RxInt selectedCourseIndex = 0.obs;
  final RxBool isCoursesLoading = false.obs;

  /// Synced with the currently selected course progress.
  final RxBool isFinalExamReady = false.obs;

  final RxList<CourseCardModel> courses = <CourseCardModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
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

  final RxList<Map<String, dynamic>> skillBuilders = <Map<String, dynamic>>[
    {
      'title': 'Important Verbs',
      'icon': Icons.bolt_rounded,
      'background': const Color(0xFFD9FFE8),
      'accent': const Color(0xFFB4F8D0),
      'iconColor': const Color(0xFF006532),
      'textColor': const Color(0xFF006532),
    },
    {
      'title': 'Survival Italian',
      'icon': Icons.work_rounded,
      'background': const Color(0xFFFFF9C9),
      'accent': const Color(0xFFFFD930),
      'iconColor': const Color(0xFF875000),
      'textColor': const Color(0xFF875000),
    },
    {
      'title': 'Job Sentences',
      'icon': Icons.desktop_windows_rounded,
      'background': const Color(0xFFDDF3FF),
      'accent': const Color(0xFFB8E7FF),
      'iconColor': const Color(0xFF00618C),
      'textColor': const Color(0xFF00618C),
    },
    {
      'title': 'Daily Challenges',
      'icon': Icons.gps_fixed_rounded,
      'background': const Color(0xFFFFE2F3),
      'accent': const Color(0xFFFFB9DE),
      'iconColor': const Color(0xFFAF1555),
      'textColor': const Color(0xFFAF1555),
    },
  ].obs;

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

  void onSkillBuilderTap(String title) {
    if (title == 'Important Verbs') {
      onImportantVerbsTap();
      return;
    }

    if (title == 'Survival Italian') {
      onSurvivalItalianTap();
      return;
    }

    if (title == 'Job Sentences') {
      onJobSentencesTap();
      return;
    }

    if (title == 'Daily Challenges') {
      onDailyChallengesTap();
      return;
    }

    Get.snackbar(
      title,
      'Opening $title practice...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  void onFinalExamCardTap() {
    if (isFinalExamReady.value) {
      onStartFinalExamTap();
      return;
    }

    Get.snackbar(
      'Final Exam Locked',
      'Complete 80% of the course to unlock the final exam.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  void onStartFinalExamTap() {
    openFinalExam();
  }

  Future<void> openFinalExam() async {
    if (courses.isEmpty) {
      Get.snackbar(
        'Final Exam',
        'No active course found for final exam.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
      return;
    }

    final CourseCardModel course = courses[selectedCourseIndex.value];
    final String tag =
        'final_exam_${course.id}_${DateTime.now().millisecondsSinceEpoch}';

    await Get.toNamed(
      AppRoutes.finalExamOverview,
      arguments: FinalExamRouteArguments(
        controllerTag: tag,
        courseId: course.id,
      ),
    );
  }

  void onViewAllSessionsTap() {
    Get.snackbar(
      'Webinars',
      'Opening webinar sessions...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
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

  void toggleFinalExamMockState() {
    isFinalExamReady.toggle();
  }

  void unlockFinalExamMock() {
    if (isFinalExamReady.value) {
      return;
    }

    isFinalExamReady.value = true;

    Get.snackbar(
      'Final Exam Unlocked',
      'Mock state updated. The final exam is now unlocked.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  void onWatchMoreLessonsFromGateway() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    unlockFinalExamMock();
  }

  void onBackToChapterFromGateway() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
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

  final RxMap<String, dynamic> selectedSurvivalPdf = <String, dynamic>{}.obs;

  final RxInt currentSurvivalPdfPage = 1.obs;
  final RxInt currentSurvivalPdfTotalPages = 12.obs;

  final RxList<Map<String, dynamic>> survivalItalianItems =
      <Map<String, dynamic>>[
        {
          'id': 'first_24_hours',
          'title': 'First 24 Hours',
          'subtitle': 'Everything you need to survive Day 1',
          'bangla': 'প্রথম ২৪ ঘণ্টা',
          'icon': Icons.work_outline_rounded,
          'pdfAsset': 'assets/pdfs/survival_italian/first_24_hours.pdf',
          'viewerTitle': 'Lesson: Italian for Beginners',
          'totalPages': 12,
          'isLearned': true,
          'isWide': false,
        },
        {
          'id': 'bus_tickets',
          'title': 'Bus &\nTickets',
          'subtitle': 'Transport basics',
          'bangla': '(বাস এবং মেট্রো)',
          'icon': Icons.directions_bus_rounded,
          'background': const Color(0xFFDDEBFF),
          'iconBackground': const Color(0xFFAFD4FF),
          'color': const Color(0xFF0B5B94),
          'pdfAsset': 'assets/pdfs/survival_italian/bus_tickets.pdf',
          'viewerTitle': 'Lesson: Bus & Tickets',
          'totalPages': 12,
          'isLearned': true,
          'isWide': false,
        },
        {
          'id': 'permesso_police',
          'title': 'Permesso /\nPolice',
          'subtitle': 'Police and immigration',
          'bangla': '(পুলিশ ও ইমিগ্রেশন)',
          'icon': Icons.admin_panel_settings_rounded,
          'background': const Color(0xFFF0E4FF),
          'iconBackground': const Color(0xFFDDBDFF),
          'color': const Color(0xFF6B1DA8),
          'pdfAsset': 'assets/pdfs/survival_italian/permesso_police.pdf',
          'viewerTitle': 'Lesson: Permesso / Police',
          'totalPages': 12,
          'isLearned': false,
          'isWide': false,
        },
        {
          'id': 'sim_card',
          'title': 'Buying a SIM\nCard',
          'subtitle': 'SIM card buying guide',
          'bangla': '(সিম কার্ড কেনা)',
          'icon': Icons.sim_card_rounded,
          'background': const Color(0xFFFFF1E1),
          'iconBackground': const Color(0xFFFFC983),
          'color': const Color(0xFF933115),
          'pdfAsset': 'assets/pdfs/survival_italian/buying_sim_card.pdf',
          'viewerTitle': 'Lesson: Buying a SIM Card',
          'totalPages': 12,
          'isLearned': false,
          'isWide': false,
        },
        {
          'id': 'market_cafe',
          'title': 'Market &\nCafe',
          'subtitle': 'Daily shopping words',
          'bangla': '(বাজার এবং কাফে)',
          'icon': Icons.shopping_basket_rounded,
          'background': const Color(0xFFE3F8E9),
          'iconBackground': const Color(0xFFAAF2C3),
          'color': const Color(0xFF125E35),
          'pdfAsset': 'assets/pdfs/survival_italian/market_cafe.pdf',
          'viewerTitle': 'Lesson: Market & Cafe',
          'totalPages': 12,
          'isLearned': false,
          'isWide': false,
        },
        {
          'id': 'hospital_help',
          'title': 'Hospital / Help',
          'subtitle': 'Emergency help words',
          'bangla': '(হাসপাতাল ও সাহায্য)',
          'icon': Icons.medical_services_outlined,
          'background': const Color(0xFFF8D3CD),
          'iconBackground': const Color(0xFFFF5638),
          'color': const Color(0xFFD43119),
          'pdfAsset': 'assets/pdfs/survival_italian/hospital_help.pdf',
          'viewerTitle': 'Lesson: Hospital / Help',
          'totalPages': 12,
          'isLearned': false,
          'isWide': true,
        },
      ].obs;

  Map<String, dynamic> get survivalHeroItem {
    return Map<String, dynamic>.from(survivalItalianItems.first);
  }

  List<Map<String, dynamic>> get survivalSmallCards {
    return survivalItalianItems
        .skip(1)
        .where((Map<String, dynamic> item) => item['isWide'] != true)
        .map((Map<String, dynamic> item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Map<String, dynamic> get survivalWideItem {
    return Map<String, dynamic>.from(
      survivalItalianItems.firstWhere(
        (Map<String, dynamic> item) => item['isWide'] == true,
        orElse: () => survivalItalianItems.last,
      ),
    );
  }

  int get survivalTotalSituations {
    return survivalItalianItems.length;
  }

  int get survivalSituationsLearned {
    return survivalItalianItems
        .where((Map<String, dynamic> item) => item['isLearned'] == true)
        .length;
  }

  double get survivalLearningProgress {
    if (survivalTotalSituations == 0) return 0;

    return survivalSituationsLearned / survivalTotalSituations;
  }

  Map<String, dynamic> get currentSurvivalPdf {
    if (selectedSurvivalPdf.isNotEmpty) {
      return Map<String, dynamic>.from(selectedSurvivalPdf);
    }

    return survivalHeroItem;
  }

  bool get canGoPreviousSurvivalPdfPage {
    return currentSurvivalPdfPage.value > 1;
  }

  bool get canGoNextSurvivalPdfPage {
    return currentSurvivalPdfPage.value < currentSurvivalPdfTotalPages.value;
  }

  void onSurvivalItalianTap() {
    Get.toNamed(AppRoutes.survivalItalian);
  }

  void onSurvivalBackTap() {
    Get.back<void>();
  }

  void openSurvivalPdf(Map<String, dynamic> item) {
    selectedSurvivalPdf
      ..clear()
      ..addAll(Map<String, dynamic>.from(item));

    currentSurvivalPdfPage.value = 1;
    currentSurvivalPdfTotalPages.value = item['totalPages'] as int? ?? 12;

    Get.toNamed(AppRoutes.practiceHubPdfViewer);
  }

  void onSurvivalPdfDocumentLoaded(int totalPages) {
    currentSurvivalPdfPage.value = 1;

    if (totalPages > 0) {
      currentSurvivalPdfTotalPages.value = totalPages;
    }
  }

  void onSurvivalPdfPageChanged(int pageNumber) {
    currentSurvivalPdfPage.value = pageNumber;
  }

  void onPdfViewerCloseTap() {
    Get.back<void>();
  }

  void markCurrentSurvivalPdfAsLearned() {
    final String id = currentSurvivalPdf['id'] as String? ?? '';

    if (id.isEmpty) return;

    final int index = survivalItalianItems.indexWhere(
      (Map<String, dynamic> item) => item['id'] == id,
    );

    if (index == -1) return;

    survivalItalianItems[index] = <String, dynamic>{
      ...survivalItalianItems[index],
      'isLearned': true,
    };

    survivalItalianItems.refresh();
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

    selectedSurvivalPdf
      ..clear()
      ..addAll(<String, dynamic>{
        'id': '${job['id']}_theory',
        'pdfAsset': job['theoryPdfAsset'] as String,
        'viewerTitle': 'Lesson: ${job['detailsTitle']} Basics',
        'totalPages': 12,
      });

    currentSurvivalPdfPage.value = 1;
    currentSurvivalPdfTotalPages.value = 12;

    Get.toNamed(AppRoutes.practiceHubPdfViewer);
  }

  final RxInt dailyChallengeXp = 1240.obs;
  final RxInt dailyStreakDays = 21.obs;
  final RxString dailyChallengeLevelLabel = 'Level 12 Explorer'.obs;
  final RxInt dailyChestSlideIndex = 0.obs;

  final RxList<Map<String, dynamic>> dailyChallengeTasks =
      <Map<String, dynamic>>[
        {
          'id': 'learn_15_min',
          'title': 'Spend 15 minutes actively\nlearning in the app',
          'current': 0,
          'target': 15,
          'unit': ' min',
          'xp': 15,
          'isClaimed': false,
        },
        {
          'id': 'review_words',
          'title': 'Review 20 Vocabulary\nWords total',
          'current': 0,
          'target': 20,
          'unit': '',
          'xp': 20,
          'isClaimed': false,
        },
        {
          'id': 'earn_100_xp',
          'title': 'Earn a total of 100 XP today\nto climb the Leaderboard',
          'current': 100,
          'target': 100,
          'unit': ' XP',
          'xp': 50,
          'isClaimed': true,
        },
      ].obs;

  void onDailyChallengesTap() {
    Get.toNamed(AppRoutes.dailyChallenges);
  }

  void onDailyChallengesBackTap() {
    Get.back<void>();
  }

  void claimDailyChallengeTask(String id) {
    final int index = dailyChallengeTasks.indexWhere(
      (Map<String, dynamic> task) => task['id'] == id,
    );

    if (index == -1) return;

    final Map<String, dynamic> task = dailyChallengeTasks[index];
    final bool isCompleted =
        (task['current'] as int) >= (task['target'] as int);

    if (!isCompleted) {
      Get.snackbar(
        'Challenge not completed',
        'Finish this task first to claim XP.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
      return;
    }

    if (task['isClaimed'] == true) return;

    dailyChallengeTasks[index] = <String, dynamic>{...task, 'isClaimed': true};

    dailyChallengeXp.value += task['xp'] as int;
    dailyChallengeTasks.refresh();
  }

  void onDailyChestTap() {
    Get.to(const DailyChestUnlockedView());
    final int completedTasks = dailyChallengeTasks.where((
      Map<String, dynamic> task,
    ) {
      return (task['current'] as int) >= (task['target'] as int);
    }).length;

    if (completedTasks < dailyChallengeTasks.length) {
      Get.snackbar(
        'Chest Locked',
        'Complete all 3 daily tasks to open the chest.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
      return;
    }

    Get.snackbar(
      'Daily Chest',
      'Opening your daily reward chest...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  void changeDailyChestSlide(int index) {
    dailyChestSlideIndex.value = index;
  }
}
