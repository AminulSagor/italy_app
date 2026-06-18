import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../../../core/services/api_client.dart';
import '../models/chapter_detail_models.dart';

class ChapterDetailApiService {
  ChapterDetailApiService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ChapterDetailModel> fetchChapterDetail({
    required String lessonId,
    required String fallbackCourseId,
    required String fallbackTitle,
    required double initialVideoProgress,
  }) async {
    final Response<dynamic> lessonResponse = await _apiClient.dio.get(
      '/lessons/$lessonId',
    );
    final Map<String, dynamic> lesson = _responseMap(lessonResponse);
    final String courseId = _fallbackString(
      lesson['courseId'],
      fallbackCourseId,
    );

    final LessonProgressModel progress = await _safeFetchLessonProgress(
      lessonId: lessonId,
      fallbackProgress: initialVideoProgress,
    );
    final ChapterMediaModel? video = await _mediaFromFileId(
      fileId: _stringValue(lesson['videoFileId']),
      type: ChapterMediaType.video,
    );
    final ChapterMediaModel? audio = await _mediaFromFileId(
      fileId: _stringValue(lesson['theoryAudioFileId']),
      type: ChapterMediaType.audio,
    );
    final ChapterMediaModel? pdf = await _mediaFromFileId(
      fileId: _stringValue(lesson['supplementaryMaterialFileId']),
      type: ChapterMediaType.pdf,
    );
    final int pdfPages = pdf == null ? 0 : await _safeFetchPdfPageCount(pdf.url);
    final int vocabularyCount = _jsonList(lesson['vocabularyItems']).length;
    final Map<String, dynamic>? quiz = await _safeFetchQuizAvailability(
      lessonId: lessonId,
    );
    final bool hasVideo = video?.url.isNotEmpty == true;
    final bool canStartQuiz = !hasVideo || progress.videoWatchPercent >= 80;

    return ChapterDetailModel(
      id: _stringValue(lesson['id']),
      courseId: courseId,
      title: _fallbackString(lesson['title'], fallbackTitle),
      videoProgressLabel: hasVideo
          ? _videoProgressLabel(progress.videoWatchPercent)
          : 'Video not given',
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
        hasAudio: audio?.url.isNotEmpty == true,
      ),
      video: video,
      audio: audio,
      theoryBook: pdf == null
          ? ChapterResourceModel.notGiven(
              title: 'Theory Book',
              iconName: 'book',
            )
          : ChapterResourceModel(
              title: 'Theory Book',
              subtitle: pdfPages > 0 ? '$pdfPages Pages' : 'PDF ready',
              iconName: 'book',
              fileUrl: pdf.url,
              isAvailable: true,
              count: pdfPages,
            ),
      vocabulary: ChapterResourceModel(
        title: 'Vocabulary',
        subtitle: vocabularyCount > 0 ? '$vocabularyCount Flashcards' : 'Not given',
        iconName: 'cards',
        isAvailable: vocabularyCount > 0,
        count: vocabularyCount,
      ),
      quiz: quiz == null || !_boolValue(quiz['hasQuiz'], fallback: false)
          ? null
          : ChapterQuizModel(
              title: _fallbackString(quiz['title'], 'Chapter Quiz'),
              subtitle: _fallbackString(
                quiz['description'],
                'Test your knowledge of this chapter',
              ),
              status: progress.isCompleted
                  ? ChapterQuizStatus.completed
                  : canStartQuiz
                      ? ChapterQuizStatus.enabled
                      : ChapterQuizStatus.disabled,
              actionLabel: canStartQuiz ? 'Start Quiz →' : 'REQUIRES 80% VIDEO',
              scoreLabel: '',
              xpLabel: '',
              timeLabel: '',
              quizId: _stringValue(quiz['quizId']),
              totalQuestions: _intValue(quiz['totalQuestions']),
            ),
      progress: progress,
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

  Future<ChapterMediaModel?> _mediaFromFileId({
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
      final String url = _fallbackString(data['signedReadUrl'], data['publicUrl']);

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

  Future<int> _safeFetchPdfPageCount(String url) async {
    try {
      final Response<List<int>> response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final List<int>? bytes = response.data;
      if (bytes == null || bytes.isEmpty) return 0;

      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final int pageCount = document.pages.count;
      document.dispose();
      return pageCount;
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
      title: _fallbackString(lesson['title'], 'Lesson Theory'),
      italianText: theory,
      italianHighlightText: '',
      italianMissingText: '',
      translationLabel: 'বাংলা অনুবাদ',
      banglaText: translation,
      banglaHighlightText: '',
    );
  }

  String _videoProgressLabel(int percent) {
    if (percent >= 80) return '$percent% Watched – Quiz Unlocked!';
    return '$percent% Watched – Keep Going!';
  }

  String _durationLabelFromPercent({
    required int percent,
    required int durationSeconds,
  }) {
    if (durationSeconds <= 0) return '0:00';
    final int seconds = (durationSeconds * (percent.clamp(0, 100).toInt() / 100))
        .round();
    return _durationLabel(seconds);
  }

  String _durationLabel(int seconds) {
    if (seconds <= 0) return '0:00';
    final Duration duration = Duration(seconds: seconds);
    final int minutes = duration.inMinutes.remainder(60);
    final int remainingSeconds = duration.inSeconds.remainder(60);
    final int hours = duration.inHours;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
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
