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
    required bool isProEnabled,
  }) async {
    final List<Response<dynamic>> responses =
        await Future.wait(<Future<Response<dynamic>>>[
          _apiClient.dio.get('/courses/$courseId'),
          _apiClient.dio.get('/courses/$courseId/syllabus'),
        ]);

    final CourseProgressModel? progress = await _safeFetchCourseProgress(
      courseId: courseId,
    );

    return _courseDetailFromApi(
      course: _responseMap(responses.first),
      syllabus: _responseMap(responses.last),
      progress: progress,
      isProEnabled: isProEnabled,
    );
  }

  Future<void> enableProAccess() async {
    // Mobile purchase API is not available in the supplied backend module yet.
    // Keep the existing local unlock flow so the current UI can refresh.
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

  CourseCardModel _courseCardFromApi(
    Map<String, dynamic> json, {
    CourseProgressModel? progress,
  }) {
    final int percent = (progress?.completionPercent ?? 0).round();
    final String subtitle = _stringValue(json['subtitle']).isNotEmpty
        ? _stringValue(json['subtitle'])
        : _stringValue(json['description']);

    return CourseCardModel(
      id: _stringValue(json['id']),
      courseId: _stringValue(json['courseId']),
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
    CourseProgressModel? progress,
  }) {
    final Map<String, dynamic> sourceCourse = _jsonMapOr(
      syllabus['course'],
      course,
    );
    final bool courseIsFree = _boolValue(
      sourceCourse['isFree'],
      fallback: true,
    );
    final int percent = (progress?.completionPercent ?? 0).round();

    return CourseDetailModel(
      id: _stringValue(sourceCourse['id']),
      courseId: _stringValue(sourceCourse['courseId']),
      chapterId: _stringValue(sourceCourse['chapterId']),
      title: _fallbackString(sourceCourse['title'], 'Course Details'),
      progressLabel: '$percent%',
      isProEnabled: isProEnabled || courseIsFree,
      isExamFinished: false,
      chapters: _learningItemsFromSyllabus(
        syllabus: syllabus,
        courseIsFree: courseIsFree,
        isProEnabled: isProEnabled,
        completedLessons: progress?.completedLessons ?? 0,
      ),
      finalExam: _finalExamFromCourse(sourceCourse, completionPercent: percent),
    );
  }

  List<CourseChapterModel> _learningItemsFromSyllabus({
    required Map<String, dynamic> syllabus,
    required bool courseIsFree,
    required bool isProEnabled,
    required int completedLessons,
  }) {
    final List<CourseChapterModel> items = <CourseChapterModel>[];
    final List<Map<String, dynamic>> chapters = _jsonList(syllabus['chapters']);

    for (final Map<String, dynamic> chapter in chapters) {
      final String chapterTitle = _stringValue(chapter['title']);
      final List<Map<String, dynamic>> lessons = _jsonList(chapter['lessons']);

      if (lessons.isEmpty) {
        items.add(
          _chapterPlaceholderFromApi(
            chapter: chapter,
            index: items.length,
            completedLessons: completedLessons,
          ),
        );
        continue;
      }

      for (final Map<String, dynamic> lesson in lessons) {
        items.add(
          _lessonCardFromApi(
            lesson: lesson,
            chapterTitle: chapterTitle,
            chapterId: _stringValue(chapter['id']),
            courseIsFree: courseIsFree,
            isProEnabled: isProEnabled,
            index: items.length,
            completedLessons: completedLessons,
          ),
        );
      }
    }

    return items;
  }

  CourseChapterModel _lessonCardFromApi({
    required Map<String, dynamic> lesson,
    required String chapterTitle,
    required String chapterId,
    required bool courseIsFree,
    required bool isProEnabled,
    required int index,
    required int completedLessons,
  }) {
    final bool lessonIsFree = _boolValue(lesson['isFree'], fallback: true);
    final bool isAccessible = courseIsFree || lessonIsFree || isProEnabled;
    final CourseChapterState state = _learningItemState(
      index: index,
      completedLessons: completedLessons,
      isAccessible: isAccessible,
      lessonIsFree: lessonIsFree,
    );

    return CourseChapterModel(
      id: _stringValue(lesson['id']),
      courseId: _stringValue(lesson['courseId']),
      chapterId: chapterId,
      title: _fallbackString(lesson['title'], 'Untitled Lesson'),
      subtitle: chapterTitle.isEmpty ? 'Course lesson' : chapterTitle,
      statusLabel: _statusLabelForState(state),
      tagLabel: isAccessible ? (lessonIsFree ? 'FREE' : null) : 'PRO',
      progress: _progressForState(state),
      state: state,
    );
  }

  CourseChapterModel _chapterPlaceholderFromApi({
    required Map<String, dynamic> chapter,
    required int index,
    required int completedLessons,
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
    required int completionPercent,
  }) {
    final bool hasTemplate = _stringValue(
      course['finalExamTemplateId'],
    ).isNotEmpty;
    final bool canStart = hasTemplate && completionPercent >= 80;
    final int remainingPercent = (80 - completionPercent).clamp(0, 80).toInt();

    return CourseFinalExamModel(
      title: 'Final Exam',
      description:
          'Unlock after completing the course to prove your Italian mastery & earn certificate.',
      actionLabel: canStart ? 'START FINAL EXAM' : 'NOT YET ELIGIBLE',
      helperLabel: hasTemplate
          ? canStart
                ? 'Ready to start'
                : 'Requires $remainingPercent% more progress'
          : 'Final exam not configured',
      canStart: canStart,
    );
  }

  CourseChapterState _learningItemState({
    required int index,
    required int completedLessons,
    required bool isAccessible,
    required bool lessonIsFree,
  }) {
    if (index < completedLessons) return CourseChapterState.completed;
    if (!isAccessible) return CourseChapterState.locked;
    if (index == completedLessons) return CourseChapterState.current;
    return lessonIsFree
        ? CourseChapterState.free
        : CourseChapterState.available;
  }

  String? _statusLabelForState(CourseChapterState state) {
    if (state == CourseChapterState.completed) return 'COMPLETED';
    if (state == CourseChapterState.current) return 'CURRENT STUDY';
    return null;
  }

  double _progressForState(CourseChapterState state) {
    if (state == CourseChapterState.completed) return 1;
    if (state == CourseChapterState.current) return 0.6;
    return 0;
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
