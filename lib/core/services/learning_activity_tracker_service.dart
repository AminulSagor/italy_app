import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../routes/app_routes.dart';
import '../models/learning_activity_models.dart';
import 'api_error_handler.dart';
import 'learning_activity_api_service.dart';
import 'storage_service.dart';

class LearningActivityTrackerService extends GetxService
    with WidgetsBindingObserver {
  LearningActivityTrackerService({
    required LearningActivityApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  static const String _pendingStorageKey = 'pendingLearningActivityTime';
  static const Duration _heartbeatDuration = Duration(seconds: 60);
  static const int _minimumRecordSeconds = 5;

  final LearningActivityApiService _apiService;
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  Timer? _heartbeat;
  LearningActivityKind? _currentKind;
  String? _currentSourceId;
  DateTime? _startedAt;
  int _shellTabIndex = 0;
  bool _isSyncing = false;

  Future<LearningActivityTrackerService> init() async {
    WidgetsBinding.instance.addObserver(this);
    _heartbeat = Timer.periodic(_heartbeatDuration, (_) => _flushCurrent());
    return this;
  }


  Future<void> startSession() => syncPending();

  Future<void> endSession() async {
    await _flushCurrent(clearActivity: true);
    await syncPending();
    await discardSession();
  }

  Future<void> discardSession() async {
    _currentKind = null;
    _currentSourceId = null;
    _startedAt = null;
    await _writePending(<LearningActivityTimeEntryModel>[]);
  }

  void setShellTab(int index) {
    _shellTabIndex = index;
    if (Get.currentRoute == AppRoutes.wrapper || Get.currentRoute.isEmpty) {
      _setActivity(_shellActivity(index));
    }
  }

  void handleRoute(String? routeName) {
    if (routeName == null || routeName.isEmpty) return;
    if (routeName == AppRoutes.wrapper) {
      _setActivity(_shellActivity(_shellTabIndex));
      return;
    }
    _setActivity(_routeActivity(routeName), sourceId: routeName);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _flushCurrent(clearActivity: false);
      return;
    }

    if (state == AppLifecycleState.resumed && _currentKind != null) {
      _startedAt = DateTime.now();
      syncPending();
    }
  }

  void _setActivity(LearningActivityKind? kind, {String? sourceId}) {
    if (kind == _currentKind && sourceId == _currentSourceId) return;
    _flushCurrent(clearActivity: true);
    _currentKind = kind;
    _currentSourceId = sourceId;
    _startedAt = kind == null ? null : DateTime.now();
  }

  Future<void> _flushCurrent({bool clearActivity = false}) async {
    final LearningActivityKind? kind = _currentKind;
    final DateTime? startedAt = _startedAt;
    final String? sourceId = _currentSourceId;
    final DateTime endedAt = DateTime.now();

    if (clearActivity) {
      _currentKind = null;
      _currentSourceId = null;
      _startedAt = null;
    } else if (kind != null) {
      _startedAt = endedAt;
    }

    if (kind == null || startedAt == null) return;

    final int durationSeconds = endedAt.difference(startedAt).inSeconds;
    if (durationSeconds < _minimumRecordSeconds) return;

    final LearningActivityTimeEntryModel entry =
        LearningActivityTimeEntryModel(
          eventId: _uuid.v4(),
          activityKind: kind,
          sourceId: sourceId,
          durationSeconds: durationSeconds.clamp(1, 3600).toInt(),
          startedAt: startedAt,
          endedAt: endedAt,
          clientActivityDate: _dateOnly(startedAt.toLocal()),
        );

    await _appendPending(entry);
    await syncPending();
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final List<LearningActivityTimeEntryModel> pending = _readPending();
      if (pending.isEmpty) return;

      final List<LearningActivityTimeEntryModel> remaining =
          <LearningActivityTimeEntryModel>[];
      for (final LearningActivityTimeEntryModel entry in pending) {
        final ApiResult<bool> result = await ApiErrorHandler.call<bool>(
          () => _apiService.recordTime(entry),
          showError: false,
        );
        if (!result.isSuccess) {
          remaining.add(entry);
        }
      }
      await _writePending(remaining);
    } finally {
      _isSyncing = false;
    }
  }

  List<LearningActivityTimeEntryModel> _readPending() {
    final String? raw = _storageService.readString(_pendingStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return <LearningActivityTimeEntryModel>[];
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) return <LearningActivityTimeEntryModel>[];
      return decoded
          .whereType<Map>()
          .map(
            (Map item) => LearningActivityTimeEntryModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return <LearningActivityTimeEntryModel>[];
    }
  }

  Future<void> _appendPending(
    LearningActivityTimeEntryModel entry,
  ) async {
    final List<LearningActivityTimeEntryModel> pending = _readPending();
    pending.add(entry);
    await _writePending(pending);
  }

  Future<void> _writePending(
    List<LearningActivityTimeEntryModel> entries,
  ) async {
    await _storageService.writeString(
      _pendingStorageKey,
      jsonEncode(
        entries
            .map((LearningActivityTimeEntryModel item) => item.toJson())
            .toList(growable: false),
      ),
    );
  }

  LearningActivityKind? _shellActivity(int index) {
    switch (index) {
      case 1:
        return LearningActivityKind.practiceHub;
      case 2:
        return LearningActivityKind.aiTutor;
      default:
        return null;
    }
  }

  LearningActivityKind? _routeActivity(String route) {
    if (route.startsWith(AppRoutes.chapterDetail)) {
      if (route.contains('/quiz')) return LearningActivityKind.quiz;
      if (route.contains('/vocabulary')) {
        return LearningActivityKind.vocabulary;
      }
      return LearningActivityKind.lesson;
    }
    if (route.startsWith('/courses/final-exam')) {
      return LearningActivityKind.exam;
    }
    if (route == AppRoutes.courseDetail) return LearningActivityKind.course;
    if (route == AppRoutes.practiceHubPdfViewer) {
      return LearningActivityKind.pdf;
    }
    if (route.startsWith('/practice-hub/job')) {
      return LearningActivityKind.jobSentences;
    }
    if (route == AppRoutes.survivalItalian) {
      return LearningActivityKind.survivalItalian;
    }
    if (route == AppRoutes.verbDetails) {
      return LearningActivityKind.importantVerbs;
    }
    if (route == AppRoutes.dailyChallenges) {
      return LearningActivityKind.practiceHub;
    }
    if (route.startsWith(AppRoutes.webinar)) {
      return LearningActivityKind.webinar;
    }
    return null;
  }

  String _dateOnly(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  void onClose() {
    _heartbeat?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _flushCurrent(clearActivity: true);
    super.onClose();
  }
}
