import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/course_models.dart';

class CoursesApiService {
  CoursesApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CoursesDashboardModel> fetchDashboard() async {
    final Response<dynamic> response = await _apiClient.dio.get('/courses');
    final List<Map<String, dynamic>> courseItems = _responseList(response.data);

    final List<CourseCardModel> courses = <CourseCardModel>[];

    for (final Map<String, dynamic> course in courseItems) {
      final CourseProgressModel? progress = await _safeFetchCourseProgress(
        courseId: _stringValue(course['id']),
      );

      courses.add(_courseCardFromApi(course, progress: progress));
    }

    return CoursesDashboardModel(
      courses: courses,
      skillBuilders: _defaultSkillBuilders,
      specializedLearning: _defaultSpecializedLearning,
    );
  }

  Future<CourseDetailModel> fetchCourseDetail({
    required String courseId,
  }) async {
    final List<Response<dynamic>> responses =
        await Future.wait(<Future<Response<dynamic>>>[
          _apiClient.dio.get('/courses/$courseId'),
          _apiClient.dio.get('/courses/$courseId/syllabus'),
        ]);

    final Map<String, dynamic> course = _responseMap(responses.first);
    final Map<String, dynamic> syllabus = _responseMap(responses.last);
    final CourseProgressModel? courseProgress = await _safeFetchCourseProgress(
      courseId: courseId,
    );
    final bool hasPurchasedAccess = await _safeFetchCourseAccess(
      courseId: courseId,
    );
    final Map<String, CourseLessonProgressModel> lessonProgressById =
        await _safeFetchLessonProgressById(syllabus);
    final Map<String, dynamic>? finalExamGateway =
        await _safeFetchFinalExamGateway(
      courseId: courseId,
      hasLinkedExam: _stringValue(course['finalExamTemplateId']).isNotEmpty,
    );

    return _courseDetailFromApi(
      course: course,
      syllabus: syllabus,
      courseProgress: courseProgress,
      lessonProgressById: lessonProgressById,
      finalExamGateway: finalExamGateway,
      isProEnabled: hasPurchasedAccess,
    );
  }

  Future<bool> _safeFetchCourseAccess({required String courseId}) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/course-enrollments/courses/$courseId/access',
      );
      final Map<String, dynamic> body = _responseMap(response);
      return _boolValue(body['hasAccess'], fallback: false);
    } on DioException {
      return false;
    }
  }

  Future<CourseProgressModel?> _safeFetchCourseProgress({
    required String courseId,
  }) async {
    if (courseId.trim().isEmpty) return null;

    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/learning-progress/courses/$courseId',
      );
      return CourseProgressModel.fromJson(_responseMap(response));
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _safeFetchFinalExamGateway({
    required String courseId,
    required bool hasLinkedExam,
  }) async {
    if (!hasLinkedExam || courseId.trim().isEmpty) return null;

    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/final-exams/courses/$courseId/gateway',
      );
      return _responseMap(response);
    } on DioException {
      return null;
    }
  }

  Future<Map<String, CourseLessonProgressModel>>
      _safeFetchLessonProgressById(Map<String, dynamic> syllabus) async {
    final List<String> lessonIds = _jsonList(syllabus['chapters'])
        .expand(
          (Map<String, dynamic> chapter) => _jsonList(chapter['lessons']),
        )
        .map((Map<String, dynamic> lesson) => _stringValue(lesson['id']))
        .where((String lessonId) => lessonId.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final List<MapEntry<String, CourseLessonProgressModel>> entries =
        await Future.wait(
          lessonIds.map((String lessonId) async {
            final CourseLessonProgressModel progress =
                await _safeFetchLessonProgress(lessonId: lessonId);
            return MapEntry<String, CourseLessonProgressModel>(
              lessonId,
              progress,
            );
          }),
        );

    return Map<String, CourseLessonProgressModel>.fromEntries(entries);
  }

  Future<CourseLessonProgressModel> _safeFetchLessonProgress({
    required String lessonId,
  }) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/learning-progress/lessons/$lessonId',
      );
      final CourseLessonProgressModel progress =
          CourseLessonProgressModel.fromJson(_responseMap(response));
      return progress.lessonId.isEmpty
          ? progress.copyWith(lessonId: lessonId)
          : progress;
    } on DioException {
      return CourseLessonProgressModel.empty(lessonId: lessonId);
    }
  }

  CourseCardModel _courseCardFromApi(
    Map<String, dynamic> json, {
    CourseProgressModel? progress,
  }) {
    final int percent = (progress?.completionPercent ?? 0).round();
    final String subtitle = _stringValue(json['subtitle']).isNotEmpty
        ? _stringValue(json['subtitle'])
        : _stringValue(json['description']);
    final String id = _stringValue(json['id']);

    return CourseCardModel(
      id: id,
      courseId: _fallbackString(json['courseId'], id),
      chapterId: _stringValue(json['chapterId']),
      title: _fallbackString(json['title'], 'Untitled Course'),
      subtitle: subtitle,
      progressLabel: '$percent%',
      progress: (percent / 100).clamp(0.0, 1.0).toDouble(),
      statusLabel: 'ACTIVE',
      state: CourseCardState.active,
    );
  }

  CourseDetailModel _courseDetailFromApi({
    required Map<String, dynamic> course,
    required Map<String, dynamic> syllabus,
    required bool isProEnabled,
    required Map<String, CourseLessonProgressModel> lessonProgressById,
    required Map<String, dynamic>? finalExamGateway,
    CourseProgressModel? courseProgress,
  }) {
    final Map<String, dynamic> sourceCourse = _jsonMapOr(
      syllabus['course'],
      course,
    );
    final bool courseIsFree = _boolValue(
      sourceCourse['isFree'] ?? course['isFree'],
      fallback: true,
    );
    final int lessonCount = _publishedLessonCount(syllabus);
    final int completedLessonCount = lessonProgressById.values
        .where((CourseLessonProgressModel progress) => progress.isCompleted)
        .length;
    final int percent = lessonCount > 0
        ? ((completedLessonCount / lessonCount) * 100).round()
        : (courseProgress?.completionPercent ?? 0).round();
    final String sourceCourseId = _fallbackString(
      sourceCourse['id'],
      course['id'],
    );

    return CourseDetailModel(
      id: sourceCourseId,
      courseId: _fallbackString(sourceCourse['courseId'], sourceCourseId),
      chapterId: _stringValue(sourceCourse['chapterId']),
      title: _fallbackString(sourceCourse['title'], 'Course Details'),
      progressLabel: '$percent%',
      isProEnabled: isProEnabled || courseIsFree,
      isFree: courseIsFree,
      lessonCount: lessonCount,
      isExamFinished: false,
      chapters: _learningItemsFromSyllabus(
        syllabus: syllabus,
        courseId: sourceCourseId,
        courseIsFree: courseIsFree,
        isProEnabled: isProEnabled,
        lessonProgressById: lessonProgressById,
      ),
      finalExam: _finalExamFromCourse(
        sourceCourse,
        gateway: finalExamGateway,
        completionPercent: percent,
      ),
    );
  }

  List<CourseChapterModel> _learningItemsFromSyllabus({
    required Map<String, dynamic> syllabus,
    required String courseId,
    required bool courseIsFree,
    required bool isProEnabled,
    required Map<String, CourseLessonProgressModel> lessonProgressById,
  }) {
    final List<CourseChapterModel> items = <CourseChapterModel>[];
    final List<Map<String, dynamic>> chapters = _jsonList(syllabus['chapters']);
    final List<_CourseLessonEntry> lessonEntries = <_CourseLessonEntry>[];

    for (final Map<String, dynamic> chapter in chapters) {
      for (final Map<String, dynamic> lesson in _jsonList(chapter['lessons'])) {
        final bool lessonIsFree = _boolValue(
          lesson['isFree'],
          fallback: true,
        );
        lessonEntries.add(
          _CourseLessonEntry(
            lesson: lesson,
            isAccessible: courseIsFree || lessonIsFree || isProEnabled,
          ),
        );
      }
    }

    final int currentLessonIndex = _currentLessonIndex(
      lessonEntries: lessonEntries,
      lessonProgressById: lessonProgressById,
    );
    int lessonIndex = 0;

    for (final Map<String, dynamic> chapter in chapters) {
      final String chapterTitle = _stringValue(chapter['title']);
      final List<Map<String, dynamic>> lessons = _jsonList(chapter['lessons']);

      if (lessons.isEmpty) {
        items.add(_chapterPlaceholderFromApi(chapter: chapter));
        continue;
      }

      for (final Map<String, dynamic> lesson in lessons) {
        final String lessonId = _stringValue(lesson['id']);
        final CourseLessonProgressModel lessonProgress =
            lessonProgressById[lessonId] ??
            CourseLessonProgressModel.empty(lessonId: lessonId);

        items.add(
          _lessonCardFromApi(
            lesson: lesson,
            fallbackCourseId: courseId,
            chapterTitle: chapterTitle,
            chapterId: _stringValue(chapter['id']),
            courseIsFree: courseIsFree,
            isProEnabled: isProEnabled,
            isCurrent: lessonIndex == currentLessonIndex,
            progress: lessonProgress,
          ),
        );
        lessonIndex++;
      }
    }

    return items;
  }

  int _currentLessonIndex({
    required List<_CourseLessonEntry> lessonEntries,
    required Map<String, CourseLessonProgressModel> lessonProgressById,
  }) {
    for (int index = 0; index < lessonEntries.length; index++) {
      final _CourseLessonEntry entry = lessonEntries[index];
      final String lessonId = _stringValue(entry.lesson['id']);
      final CourseLessonProgressModel progress =
          lessonProgressById[lessonId] ??
          CourseLessonProgressModel.empty(lessonId: lessonId);

      if (entry.isAccessible &&
          !progress.isCompleted &&
          (progress.videoWatchPercent > 0 || progress.isTheoryRead)) {
        return index;
      }
    }

    for (int index = 0; index < lessonEntries.length; index++) {
      final _CourseLessonEntry entry = lessonEntries[index];
      final String lessonId = _stringValue(entry.lesson['id']);
      final CourseLessonProgressModel progress =
          lessonProgressById[lessonId] ??
          CourseLessonProgressModel.empty(lessonId: lessonId);

      if (entry.isAccessible && !progress.isCompleted) {
        return index;
      }
    }

    return -1;
  }

  CourseChapterModel _lessonCardFromApi({
    required Map<String, dynamic> lesson,
    required String fallbackCourseId,
    required String chapterTitle,
    required String chapterId,
    required bool courseIsFree,
    required bool isProEnabled,
    required bool isCurrent,
    required CourseLessonProgressModel progress,
  }) {
    final bool lessonIsFree = _boolValue(lesson['isFree'], fallback: true);
    final bool isAccessible = courseIsFree || lessonIsFree || isProEnabled;
    final CourseChapterState state = _learningItemState(
      isAccessible: isAccessible,
      lessonIsFree: lessonIsFree,
      isCurrent: isCurrent,
      progress: progress,
    );

    return CourseChapterModel(
      id: _stringValue(lesson['id']),
      courseId: _fallbackString(lesson['courseId'], fallbackCourseId),
      chapterId: chapterId,
      title: _fallbackString(lesson['title'], 'Untitled Lesson'),
      subtitle: chapterTitle.isEmpty ? 'Course lesson' : chapterTitle,
      statusLabel: _statusLabelForState(state, progress: progress),
      tagLabel: isAccessible ? (lessonIsFree ? 'FREE' : null) : 'PRO',
      progress: progress.progress,
      state: state,
    );
  }

  CourseChapterModel _chapterPlaceholderFromApi({
    required Map<String, dynamic> chapter,
  }) {
    return CourseChapterModel(
      id: _stringValue(chapter['id']),
      courseId: _stringValue(chapter['courseId']),
      chapterId: _stringValue(chapter['id']),
      title: _fallbackString(chapter['title'], 'Untitled Chapter'),
      subtitle: 'No published lesson yet',
      statusLabel: 'NOT AVAILABLE',
      progress: 0,
      state: CourseChapterState.locked,
    );
  }

  CourseFinalExamModel _finalExamFromCourse(
    Map<String, dynamic> course, {
    required Map<String, dynamic>? gateway,
    required int completionPercent,
  }) {
    final bool hasLinkedExam = _stringValue(
      course['finalExamTemplateId'],
    ).isNotEmpty;
    final Map<String, dynamic> exam = gateway == null
        ? <String, dynamic>{}
        : _jsonMapOr(gateway['exam'], <String, dynamic>{});
    final bool hasPublishedExam = _stringValue(exam['id']).isNotEmpty;
    final int unlockPercent = _intValue(exam['unlockCompletionPercent']);
    final String backendProgressValue = gateway == null
        ? ''
        : _stringValue(gateway['courseProgressPercent']);
    final int backendProgressPercent = backendProgressValue.isEmpty
        ? completionPercent
        : _intValue(backendProgressValue);
    final bool thresholdReached =
        hasPublishedExam && backendProgressPercent >= unlockPercent;
    final bool gatewayUnlocked = gateway != null &&
        (_boolValue(gateway['isUnlocked'], fallback: thresholdReached) ||
            thresholdReached);
    final bool canStart =
        hasLinkedExam && hasPublishedExam && gatewayUnlocked;
    final String gatewayMessage = gateway == null
        ? ''
        : _stringValue(gateway['message']);

    String helperLabel;
    if (!hasLinkedExam) {
      helperLabel = 'Final exam not configured';
    } else if (!hasPublishedExam) {
      helperLabel = 'Final exam is not published yet';
    } else if (!gatewayUnlocked) {
      helperLabel = gatewayMessage.isNotEmpty
          ? gatewayMessage
          : 'Reach $unlockPercent% course completion to unlock the final exam';
    } else {
      helperLabel = gatewayMessage.isNotEmpty
          ? gatewayMessage
          : 'Ready to start';
    }

    return CourseFinalExamModel(
      examId: _stringValue(exam['id']),
      title: _fallbackString(exam['title'], 'Final Exam'),
      description: _fallbackString(
        exam['description'],
        'Complete the final exam to earn your course certificate.',
      ),
      actionLabel: canStart ? 'START FINAL EXAM' : 'NOT YET ELIGIBLE',
      helperLabel: helperLabel,
      isConfigured: hasLinkedExam,
      canStart: canStart,
      courseProgressPercent: backendProgressPercent.clamp(0, 100).toInt(),
      unlockCompletionPercent: unlockPercent,
    );
  }

  CourseChapterState _learningItemState({
    required bool isAccessible,
    required bool lessonIsFree,
    required bool isCurrent,
    required CourseLessonProgressModel progress,
  }) {
    if (progress.isCompleted) return CourseChapterState.completed;
    if (!isAccessible) return CourseChapterState.locked;
    if (isCurrent) return CourseChapterState.current;
    return lessonIsFree
        ? CourseChapterState.free
        : CourseChapterState.available;
  }

  String? _statusLabelForState(
    CourseChapterState state, {
    required CourseLessonProgressModel progress,
  }) {
    if (state == CourseChapterState.completed) return 'COMPLETED';
    if (state == CourseChapterState.current) return 'CURRENT STUDY';
    if (progress.videoWatchPercent > 0) {
      return '${progress.videoWatchPercent}% WATCHED';
    }
    return null;
  }

  int _publishedLessonCount(Map<String, dynamic> syllabus) {
    return _jsonList(syllabus['chapters']).fold<int>(
      0,
      (int total, Map<String, dynamic> chapter) =>
          total + _jsonList(chapter['lessons']).length,
    );
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Response is not a valid JSON object',
    );
  }

  List<Map<String, dynamic>> _responseList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    throw DioException(
      requestOptions: RequestOptions(path: '/courses'),
      message: 'Response is not a valid JSON list',
    );
  }

  Map<String, dynamic> _jsonMapOr(
    dynamic value,
    Map<String, dynamic> fallback,
  ) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return fallback;
  }

  List<Map<String, dynamic>> _jsonList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    return <Map<String, dynamic>>[];
  }

  String _fallbackString(dynamic value, String fallback) {
    final String text = _stringValue(value);
    return text.isEmpty ? fallback : text;
  }

  String _stringValue(dynamic value) => value?.toString().trim() ?? '';

  int _intValue(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(_stringValue(value)) ?? 0;
  }

  bool _boolValue(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  static const List<SkillBuilderModel> _defaultSkillBuilders =
      <SkillBuilderModel>[
        SkillBuilderModel(
          id: 'verbs',
          courseId: 'courseId',
          chapterId: 'chapterId',
          title: 'Important Verbs',
          iconName: 'bolt',
          tone: SkillBuilderTone.green,
        ),
        SkillBuilderModel(
          id: 'survival',
          courseId: 'courseId',
          chapterId: 'chapterId',
          title: 'Survival Italian',
          iconName: 'work',
          tone: SkillBuilderTone.yellow,
        ),
        SkillBuilderModel(
          id: 'job',
          courseId: 'courseId',
          chapterId: 'chapterId',
          title: 'Job Sentences',
          iconName: 'workbench',
          tone: SkillBuilderTone.blue,
        ),
        SkillBuilderModel(
          id: 'challenge',
          courseId: 'courseId',
          chapterId: 'chapterId',
          title: 'Daily Challenges',
          iconName: 'target',
          tone: SkillBuilderTone.pink,
        ),
      ];

  static const SpecializedLearningModel _defaultSpecializedLearning =
      SpecializedLearningModel(
        title: 'Final Exam – Esame finale',
        subtitle: 'Complete the course to unlock final exam',
        requirementLabel: '80% Required',
        lockedLabel: 'Locked',
      );
}

class _CourseLessonEntry {
  final Map<String, dynamic> lesson;
  final bool isAccessible;

  const _CourseLessonEntry({
    required this.lesson,
    required this.isAccessible,
  });
}
