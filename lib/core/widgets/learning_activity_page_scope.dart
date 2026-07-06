import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/learning_activity_models.dart';
import '../services/learning_activity_tracker_service.dart';

class LearningActivityPageScope extends StatefulWidget {
  const LearningActivityPageScope({
    super.key,
    required this.activityKind,
    required this.sourceId,
    required this.child,
    this.enabled = true,
  });

  final LearningActivityKind activityKind;
  final String sourceId;
  final Widget child;
  final bool enabled;

  @override
  State<LearningActivityPageScope> createState() =>
      _LearningActivityPageScopeState();
}

class _LearningActivityPageScopeState
    extends State<LearningActivityPageScope> {
  late final String _scopeToken;
  bool? _wasVisible;

  LearningActivityTrackerService? get _tracker {
    if (!Get.isRegistered<LearningActivityTrackerService>()) {
      return null;
    }
    return Get.find<LearningActivityTrackerService>();
  }

  @override
  void initState() {
    super.initState();
    _scopeToken = '${widget.sourceId}-${identityHashCode(this)}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateVisibility();
  }

  @override
  void didUpdateWidget(covariant LearningActivityPageScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.activityKind != widget.activityKind ||
        oldWidget.sourceId != widget.sourceId) {
      _wasVisible = null;
      _updateVisibility();
    }
  }

  void _updateVisibility() {
    final bool isVisible = widget.enabled && TickerMode.of(context);
    if (_wasVisible == isVisible) return;
    _wasVisible = isVisible;
    _tracker?.setPageScope(
      token: _scopeToken,
      activityKind: widget.activityKind,
      sourceId: widget.sourceId,
      isVisible: isVisible,
    );
  }

  @override
  void dispose() {
    _tracker?.removePageScope(_scopeToken);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
