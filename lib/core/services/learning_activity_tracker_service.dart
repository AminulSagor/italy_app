import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../routes/app_routes.dart';
import '../models/learning_activity_models.dart';
import 'api_error_handler.dart';
import 'learning_activity_api_service.dart';
import 'learning_activity_route_resolver.dart';
import 'storage_service.dart';

class LearningActivityTrackerService extends GetxService
    with WidgetsBindingObserver {
  LearningActivityTrackerService({
    required LearningActivityApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  static const String _pendingStorageKey = 'pendingLearningActivityTime';
  static const Duration _heartbeatDuration = Duration(seconds: 10);
  static const int _minimumRecordSeconds = 1;

  final LearningActivityApiService _apiService;
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();
  final LearningActivityRouteResolver _routeResolver =
      const LearningActivityRouteResolver();

  Timer? _heartbeat;
  Future<void> _operationQueue = Future<void>.value();
  LearningActivityKind? _currentKind;
  String? _currentSourceId;
  DateTime? _startedAt;
  int _shellTabIndex = 0;
  bool _isForeground = true;
  bool _isClosed = false;

  Future<LearningActivityTrackerService> init() async {
    WidgetsBinding.instance.addObserver(this);
    _heartbeat = Timer.periodic(
      _heartbeatDuration,
      (_) => unawaited(flushAndSync()),
    );
    return this;
  }

  Future<void> startSession() {
    return _enqueue(() async {
      await _syncPendingInternal();
      _restoreCurrentActivity();
    });
  }

  Future<void> endSession() {
    return _enqueue(() async {
      await _flushCurrentInternal(clearActivity: true);
      await _syncPendingInternal();
      _currentKind = null;
      _currentSourceId = null;
      _startedAt = null;
      await _writePending(<LearningActivityTimeEntryModel>[]);
    });
  }

  Future<void> discardSession() {
    return _enqueue(() async {
      _currentKind = null;
      _currentSourceId = null;
      _startedAt = null;
      await _writePending(<LearningActivityTimeEntryModel>[]);
    });
  }

  Future<void> flushAndSync() {
    return _enqueue(() async {
      await _flushCurrentInternal(clearActivity: false);
      await _syncPendingInternal();
    });
  }

  Future<void> syncPending() {
    return _enqueue(_syncPendingInternal);
  }

  void setShellTab(int index) {
    _shellTabIndex = index;

    // The shell uses nested Navigators, so Get.currentRoute can remain on a
    // previous root route while the selected tab has already changed. Tab
    // selection itself is the authoritative learning context here.
    _queueActivity(
      _routeResolver.forShellTab(index),
      sourceId: 'shell-tab-$index',
    );
  }

  void handleRoute(String? routeName) {
    final String route = _routeResolver.normalize(routeName);
    if (route.isEmpty) return;

    if (route == AppRoutes.wrapper) {
      _queueActivity(
        _routeResolver.forShellTab(_shellTabIndex),
        sourceId: 'shell-tab-$_shellTabIndex',
      );
      return;
    }

    final LearningActivityKind? activity = _routeResolver.forRoute(route);
    if (activity != null) {
      _queueActivity(activity, sourceId: route);
      return;
    }

    if (_routeResolver.isKnownNonLearningRoute(route)) {
      _queueActivity(null);
    }
    // Unnamed Get.to() child routes are intentionally ignored. They are
    // commonly fullscreen lesson media, survival Italian details, saved verb
    // pages, or AI tutor flows and should inherit the active learning session.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _isForeground = false;
      unawaited(
        _enqueue(() async {
          await _flushCurrentInternal(clearActivity: false);
          await _syncPendingInternal();
        }),
      );
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _isForeground = true;
      unawaited(
        _enqueue(() async {
          if (_currentKind != null) {
            _startedAt = DateTime.now();
          }
          await _syncPendingInternal();
        }),
      );
    }
  }

  void _queueActivity(
    LearningActivityKind? kind, {
    String? sourceId,
  }) {
    unawaited(
      _enqueue(() => _transitionTo(kind, sourceId: sourceId)),
    );
  }

  Future<void> _transitionTo(
    LearningActivityKind? kind, {
    String? sourceId,
  }) async {
    if (kind == _currentKind && sourceId == _currentSourceId) {
      if (kind != null && _isForeground && _startedAt == null) {
        _startedAt = DateTime.now();
      }
      return;
    }

    await _flushCurrentInternal(clearActivity: true);
    await _syncPendingInternal();
    _currentKind = kind;
    _currentSourceId = sourceId;
    _startedAt = kind != null && _isForeground ? DateTime.now() : null;
  }

  Future<void> _flushCurrentInternal({required bool clearActivity}) async {
    final LearningActivityKind? kind = _currentKind;
    final DateTime? startedAt = _startedAt;
    final String? sourceId = _currentSourceId;
    final DateTime endedAt = DateTime.now();

    if (clearActivity) {
      _currentKind = null;
      _currentSourceId = null;
      _startedAt = null;
    } else {
      _startedAt = kind != null && _isForeground ? endedAt : null;
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
  }

  Future<void> _syncPendingInternal() async {
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
        dev.log(
          'Unable to upload learning activity: ${result.error}',
          name: 'LearningActivityTracker',
        );
      }
    }

    await _writePending(remaining);
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final Completer<void> completer = Completer<void>();
    _operationQueue = _operationQueue.then((_) async {
      if (_isClosed) {
        completer.complete();
        return;
      }
      try {
        await operation();
      } catch (error, stackTrace) {
        dev.log(
          'Learning activity operation failed',
          error: error,
          stackTrace: stackTrace,
          name: 'LearningActivityTracker',
        );
      } finally {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    return completer.future;
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
          .toList(growable: true);
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

  void _restoreCurrentActivity() {
    final String route = _routeResolver.normalize(Get.currentRoute);
    if (route == AppRoutes.wrapper || route.isEmpty) {
      final LearningActivityKind? kind = _routeResolver.forShellTab(_shellTabIndex);
      _currentKind = kind;
      _currentSourceId = 'shell-tab-$_shellTabIndex';
      _startedAt = kind != null && _isForeground ? DateTime.now() : null;
      return;
    }

    final LearningActivityKind? kind = _routeResolver.forRoute(route);
    if (kind != null) {
      _currentKind = kind;
      _currentSourceId = route;
      _startedAt = _isForeground ? DateTime.now() : null;
    }
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
    unawaited(
      flushAndSync().whenComplete(() {
        _isClosed = true;
      }),
    );
    super.onClose();
  }
}
