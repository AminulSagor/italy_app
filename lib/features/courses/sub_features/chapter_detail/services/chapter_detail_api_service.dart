import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../../../core/services/api_client.dart';
import '../models/chapter_detail_models.dart';

class ChapterDetailApiService {
  ChapterDetailApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;
  final Dio _fileClient = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: const <String, String>{'Accept': 'application/pdf'},
    ),
  );

  Future<ChapterDetailModel> fetchChapterDetail({
    required String lessonId,
    required String fallbackCourseId,
    required String fallbackTitle,
    required double initialVideoProgress,
  }) async {
    late Map<String, dynamic> lesson;
    late LessonProgressModel progress;
    Map<String, dynamic>? quiz;

    await Future.wait<void>(<Future<void>>[
      () async {
        final Response<dynamic> response = await _apiClient.dio.get(
          '/lessons/$lessonId',
        );
        lesson = _responseMap(response);
      }(),
      () async {
        progress = await _safeFetchLessonProgress(
          lessonId: lessonId,
          fallbackProgress: initialVideoProgress,
        );
      }(),
      () async {
        quiz = await _safeFetchQuizAvailability(lessonId: lessonId);
      }(),
    ]);

    final String courseId = _fallbackString(
      lesson['courseId'],
      fallbackCourseId,
    );
    final String videoFileId = _stringValue(lesson['videoFileId']);
    final String audioFileId = _stringValue(lesson['theoryAudioFileId']);
    final String pdfFileId = _stringValue(
      lesson['supplementaryMaterialFileId'],
    );

    final ChapterMediaModel? video = _mediaReference(
      fileId: videoFileId,
      type: ChapterMediaType.video,
    );
    final ChapterMediaModel? audio = _mediaReference(
      fileId: audioFileId,
      type: ChapterMediaType.audio,
    );
    final int vocabularyCount = _jsonList(lesson['vocabularyItems']).length;
    final bool hasVideo = videoFileId.isNotEmpty;
    final bool canStartQuiz = !hasVideo || progress.videoWatchPercent >= 80;

    return ChapterDetailModel(
      id: _stringValue(lesson['id']),
      courseId: courseId,
      title: _fallbackString(lesson['title'], fallbackTitle),
      videoProgressLabel: hasVideo
          ? _videoProgressLabel(progress.videoWatchPercent)
          : 'video_not_given'.tr,
      watchedTimeLabel: _durationLabelFromPercent(
        percent: progress.videoWatchPercent,
        durationSeconds: video?.durationSeconds ?? 0,
      ),
      totalTimeLabel: _durationLabel(video?.durationSeconds ?? 0),
      videoProgress: (progress.videoWatchPercent / 100)
          .clamp(0.0, 1.0)
          .toDouble(),
      lessonContent: _lessonContentFromLesson(
        lesson,
        hasAudio: audioFileId.isNotEmpty,
      ),
      video: video,
      audio: audio,
      theoryBook: pdfFileId.isEmpty
          ? ChapterResourceModel.notGiven(
              title: 'gen_theory_book'.tr,
              iconName: 'book',
            )
          : ChapterResourceModel(
              title: 'gen_theory_book'.tr,
              subtitle: 'gen_not_given'.tr,
              iconName: 'book',
              fileId: pdfFileId,
              isAvailable: true,
              count: 0,
            ),
      vocabulary: ChapterResourceModel(
        title: 'gen_vocabulary'.tr,
        subtitle: vocabularyCount > 0
            ? '$vocabularyCount ${'flashcards'.tr}'
            : 'gen_not_given'.tr,
        iconName: 'cards',
        isAvailable: vocabularyCount > 0,
        count: vocabularyCount,
      ),
      isQuizAvailabilityKnown: quiz != null,
      quiz: quiz == null || !_boolValue(quiz!['hasQuiz'], fallback: false)
          ? null
          : ChapterQuizModel(
              title: _fallbackString(quiz!['title'], 'chapter_quiz'.tr),
              subtitle: _fallbackString(
                quiz!['description'],
                'chapter_quiz_description'.tr,
              ),
              status: progress.isCompleted
                  ? ChapterQuizStatus.completed
                  : canStartQuiz
                  ? ChapterQuizStatus.enabled
                  : ChapterQuizStatus.disabled,
              actionLabel: canStartQuiz
                  ? 'start_quiz'.tr
                  : 'requires_80_video'.tr,
              scoreLabel: '',
              xpLabel: '',
              timeLabel: '',
              quizId: _stringValue(quiz!['quizId']),
              totalQuestions: _intValue(quiz!['totalQuestions']),
            ),
      progress: progress,
    );
  }

  Future<ChapterVideoAccessModel> fetchVideoAccess({
    required String lessonId,
  }) async {
    final Response<dynamic> response = await _apiClient.dio.get(
      '/lessons/$lessonId/video-access',
    );

    return ChapterVideoAccessModel.fromJson(
      _responseMap(response),
    );
  }



  Future<void> recordVideoProgress({
    required String courseId,
    required String lessonId,
    required int watchedPercent,
    required int timeSpentSeconds,
  }) async {
    await _apiClient.dio.post(
      '/learning-progress/lessons/video-progress',
      data: <String, dynamic>{
        'courseId': courseId,
        'lessonId': lessonId,
        'watchedPercent': watchedPercent.clamp(0, 100).toInt(),
        'timeSpentSeconds': timeSpentSeconds,
        'clientActivityDate': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> markTheoryRead({
    required String courseId,
    required String lessonId,
  }) async {
    await _apiClient.dio.post(
      '/learning-progress/lessons/theory-read',
      data: <String, dynamic>{
        'courseId': courseId,
        'lessonId': lessonId,
        'clientActivityDate': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> recordAudioListened({
    required String courseId,
    required String lessonId,
    required String audioFileId,
  }) async {
    await _apiClient.dio.post(
      '/learning-progress/lessons/audio-listened',
      data: <String, dynamic>{
        'courseId': courseId,
        'lessonId': lessonId,
        if (audioFileId.isNotEmpty) 'audioFileId': audioFileId,
        'clientActivityDate': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> markLessonCompleted({
    required String courseId,
    required String lessonId,
  }) async {
    await _apiClient.dio.post(
      '/learning-progress/lessons/complete',
      data: <String, dynamic>{
        'courseId': courseId,
        'lessonId': lessonId,
        'clientActivityDate': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<LessonProgressModel> _safeFetchLessonProgress({
    required String lessonId,
    required double fallbackProgress,
  }) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/learning-progress/lessons/$lessonId',
      );
      return LessonProgressModel.fromJson(_responseMap(response));
    } on DioException {
      return LessonProgressModel(
        videoWatchPercent: (fallbackProgress * 100)
            .round()
            .clamp(0, 100)
            .toInt(),
        isTheoryRead: false,
        isCompleted: false,
      );
    }
  }

  Future<Map<String, dynamic>?> _safeFetchQuizAvailability({
    required String lessonId,
  }) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/quiz-sessions/lessons/$lessonId/availability',
      );
      return _responseMap(response);
    } on DioException {
      return null;
    }
  }

  ChapterMediaModel? _mediaReference({
    required String fileId,
    required ChapterMediaType type,
  }) {
    if (fileId.isEmpty) {
      return null;
    }

    return ChapterMediaModel(
      fileId: fileId,
      url: '',
      title: '',
      mimeType: '',
      durationSeconds: 0,
      type: type,
    );
  }

  Future<ChapterMediaModel?> fetchMedia({
    required String fileId,
    required ChapterMediaType type,
  }) async {
    if (fileId.isEmpty) return null;

    try {
      final Response<dynamic> response = await _apiClient.dio.get(
        '/files/$fileId/signed-read-url',
      );
      final Map<String, dynamic> data = _responseMap(response);
      final Map<String, dynamic> file = _jsonMap(data['file']);
      final String url = _fallbackString(
        data['signedReadUrl'],
        data['publicUrl'],
      );

      if (url.isEmpty) return null;

      return ChapterMediaModel(
        fileId: fileId,
        url: url,
        title: _stringValue(file['originalName']),
        mimeType: _stringValue(file['mimeType']),
        durationSeconds: _intValue(data['durationSeconds']),
        type: type,
      );
    } on DioException {
      return null;
    }
  }

  Future<int> fetchPdfPageCount({required String pdfUrl}) async {
    if (pdfUrl.isEmpty) {
      return 0;
    }

    try {
      final Response<List<int>> response = await _fileClient.get<List<int>>(
        pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final List<int> bytes = response.data ?? <int>[];
      if (bytes.isEmpty) {
        return 0;
      }

      final PdfDocument document = PdfDocument(
        inputBytes: Uint8List.fromList(bytes),
      );
      try {
        return document.pages.count;
      } finally {
        document.dispose();
      }
    } on DioException {
      return 0;
    } catch (_) {
      return 0;
    }
  }

  LessonContentModel? _lessonContentFromLesson(
    Map<String, dynamic> lesson, {
    required bool hasAudio,
  }) {
    final String theory = _stringValue(lesson['theoryText']);
    final String translation = _stringValue(lesson['bengaliTranslation']);

    if (theory.isEmpty && translation.isEmpty && !hasAudio) {
      return null;
    }

    return LessonContentModel(
      title: _fallbackString(lesson['title'], 'lesson_theory'.tr),
      italianText: theory,
      italianHighlightText: '',
      italianMissingText: '',
      translationLabel: 'translation_label'.tr,
      banglaText: translation,
      banglaHighlightText: '',
    );
  }

  String _videoProgressLabel(int percent) {
    if (percent >= 80) {
      return '$percent% ${'watched'.tr} – ${'quiz_unlocked'.tr}';
    }
    return '$percent% ${'watched'.tr} – ${'keep_going_1'.tr}';
  }

  String _durationLabelFromPercent({
    required int percent,
    required int durationSeconds,
  }) {
    if (durationSeconds <= 0) return '0:00';
    final int seconds =
        (durationSeconds * (percent.clamp(0, 100).toInt() / 100)).round();
    return _durationLabel(seconds);
  }

  String _durationLabel(int seconds) {
    if (seconds <= 0) return '0:00';
    final Duration duration = Duration(seconds: seconds);
    final int minutes = duration.inMinutes.remainder(60);
    final int remainingSeconds = duration.inSeconds.remainder(60);
    final int hours = duration.inHours;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw DioException(
      requestOptions: response.requestOptions,
      message: 'response_is_not_a_valid_json_object'.tr,
    );
  }

  Map<String, dynamic> _jsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
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

  String _fallbackString(dynamic value, dynamic fallback) {
    final String text = _stringValue(value);
    if (text.isNotEmpty) return text;
    return _stringValue(fallback);
  }

  String _stringValue(dynamic value) => value?.toString().trim() ?? '';

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _boolValue(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }
}
