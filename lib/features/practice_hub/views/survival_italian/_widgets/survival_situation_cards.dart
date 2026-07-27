import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_font.dart';
import '../../../controllers/practice_hub_controller.dart';
import '../../../models/survival_italian_models.dart';

class SurvivalHeroSituationCard extends GetView<PracticeHubController> {
  const SurvivalHeroSituationCard({
    required this.item,
    super.key,
  });

  final SurvivalSituationModel item;

  @override
  Widget build(BuildContext context) {
    final Color background = parseSurvivalCardColor(item.cardColor);
    final Color foreground = survivalCardForeground(background);
    final Color secondaryForeground =
    survivalCardSecondaryForeground(background);
    final IconData icon = survivalIconFor(item.iconKey);

    return _SurvivalCardSurface(
      onTap: () => controller.openSurvivalPdf(item),
      semanticsLabel: _survivalSemanticsLabel(item),
      semanticsHint: item.isCompleted ? 'review'.tr : 'start_here'.tr,
      background: background,
      foreground: foreground,
      borderRadius: BorderRadius.circular(28.r),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          background,
          Color.lerp(background, AppColors.white, 0.14) ?? background,
        ],
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: background.withValues(alpha: 0.18),
          blurRadius: 18.r,
          offset: Offset(0, 8.h),
        ),
      ],
      constraints: BoxConstraints(
        minHeight: 220.h,
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        20.h,
        18.w,
        20.h,
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -10.w,
            bottom: -14.h,
            child: ExcludeSemantics(
              child: Icon(
                icon,
                size: 88.r,
                color: foreground.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _SituationIconTile(
                    icon: icon,
                    foreground: foreground,
                    size: 52.r,
                    iconSize: 27.r,
                    radius: 16.r,
                  ),
                  const Spacer(),
                  if (item.isCompleted)
                    _CompletionBadge(
                      background: background,
                      foreground: foreground,
                      size: 28.r,
                    ),
                ],
              ),
              SizedBox(height: 18.h),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24.sp,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: foreground,
                ),
              ),
              if (_hasText(item.subtitleBn)) ...<Widget>[
                SizedBox(height: 7.h),
                Text(
                  item.subtitleBn!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    color: secondaryForeground,
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              _HeroActionButton(
                label: item.isCompleted ? 'review'.tr : 'start_here'.tr,
                background: foreground,
                foreground: background,
                isCompleted: item.isCompleted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SurvivalSmallSituationCard extends GetView<PracticeHubController> {
  const SurvivalSmallSituationCard({
    required this.item,
    super.key,
  });

  final SurvivalSituationModel item;

  @override
  Widget build(BuildContext context) {
    final Color background = parseSurvivalCardColor(item.cardColor);
    final Color foreground = survivalCardForeground(background);
    final Color secondaryForeground =
    survivalCardSecondaryForeground(background);
    final IconData icon = survivalIconFor(item.iconKey);

    return _SurvivalCardSurface(
      onTap: () => controller.openSurvivalPdf(item),
      semanticsLabel: _survivalSemanticsLabel(item),
      semanticsHint: item.isCompleted ? 'review'.tr : 'start_here'.tr,
      background: background,
      foreground: foreground,
      borderRadius: BorderRadius.circular(24.r),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10.r,
          offset: Offset(0, 4.h),
        ),
      ],
      padding: EdgeInsets.fromLTRB(
        14.w,
        14.h,
        14.w,
        12.h,
      ),
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _SituationIconTile(
                    icon: icon,
                    foreground: foreground,
                    size: 40.r,
                    iconSize: 20.r,
                    radius: 12.r,
                  ),
                  const Spacer(),
                  if (item.isCompleted)
                    _CompletionBadge(
                      background: background,
                      foreground: foreground,
                      size: 22.r,
                    ),
                ],
              ),

              SizedBox(height: 12.h),

              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.font16.sp,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                  color: foreground,
                ),
              ),

              if (_hasText(item.subtitleBn)) ...<Widget>[
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.only(right: 34.w),
                  child: Text(
                    item.subtitleBn!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font12.sp,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                      color: secondaryForeground,
                    ),
                  ),
                ),
              ],
            ],
          ),

          Positioned(
            right: 0,
            bottom: 0,
            child: _TrailingAction(
              foreground: foreground,
              isCompleted: item.isCompleted,
              size: 28.r,
            ),
          ),
        ],
      ),
    );
  }
}

class SurvivalWideSituationCard extends GetView<PracticeHubController> {
  const SurvivalWideSituationCard({
    required this.item,
    super.key,
  });

  final SurvivalSituationModel item;

  @override
  Widget build(BuildContext context) {
    final Color background = parseSurvivalCardColor(item.cardColor);
    final Color foreground = survivalCardForeground(background);
    final Color secondaryForeground =
    survivalCardSecondaryForeground(background);
    final IconData icon = survivalIconFor(item.iconKey);

    return _SurvivalCardSurface(
      onTap: () => controller.openSurvivalPdf(item),
      semanticsLabel: _survivalSemanticsLabel(item),
      semanticsHint: item.isCompleted ? 'review'.tr : 'start_here'.tr,
      background: background,
      foreground: foreground,
      borderRadius: BorderRadius.circular(24.r),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12.r,
          offset: Offset(0, 5.h),
        ),
      ],
      constraints: BoxConstraints(
        minHeight: 104.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 15.h,
      ),
      child: Row(
        children: <Widget>[
          _SituationIconTile(
            icon: icon,
            foreground: foreground,
            size: 48.r,
            iconSize: 24.r,
            radius: 15.r,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.font16.sp,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                    color: foreground,
                  ),
                ),
                if (_hasText(item.subtitleBn)) ...<Widget>[
                  SizedBox(height: 5.h),
                  Text(
                    item.subtitleBn!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.font12.sp,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: secondaryForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w),
          if (item.isCompleted) ...<Widget>[
            _CompletionBadge(
              background: background,
              foreground: foreground,
              size: 23.r,
            ),
            SizedBox(width: 8.w),
          ],
          _TrailingAction(
            foreground: foreground,
            isCompleted: item.isCompleted,
            size: 34.r,
          ),
        ],
      ),
    );
  }
}

class _SurvivalCardSurface extends StatelessWidget {
  const _SurvivalCardSurface({
    required this.onTap,
    required this.semanticsLabel,
    required this.semanticsHint,
    required this.background,
    required this.foreground,
    required this.borderRadius,
    required this.padding,
    required this.child,
    this.gradient,
    this.boxShadow = const <BoxShadow>[],
    this.constraints,
  });

  final VoidCallback onTap;
  final String semanticsLabel;
  final String semanticsHint;
  final Color background;
  final Color foreground;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final Gradient? gradient;
  final List<BoxShadow> boxShadow;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Semantics(
        container: true,
        button: true,
        label: semanticsLabel,
        hint: semanticsHint,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: boxShadow,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(
                color: gradient == null ? background : null,
                gradient: gradient,
                borderRadius: borderRadius,
                border: Border.all(
                  color: foreground.withValues(alpha: 0.07),
                ),
              ),
              child: InkWell(
                onTap: onTap,
                excludeFromSemantics: true,
                borderRadius: borderRadius,
                mouseCursor: SystemMouseCursors.click,
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return foreground.withValues(alpha: 0.12);
                    }

                    if (states.contains(WidgetState.hovered)) {
                      return foreground.withValues(alpha: 0.06);
                    }

                    if (states.contains(WidgetState.focused)) {
                      return foreground.withValues(alpha: 0.08);
                    }

                    return null;
                  },
                ),
                child: ConstrainedBox(
                  constraints: constraints ?? const BoxConstraints(),
                  child: Padding(
                    padding: padding,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SituationIconTile extends StatelessWidget {
  const _SituationIconTile({
    required this.icon,
    required this.foreground,
    required this.size,
    required this.iconSize,
    required this.radius,
  });

  final IconData icon;
  final Color foreground;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: foreground.withValues(alpha: 0.07),
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: foreground,
        ),
      ),
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({
    required this.background,
    required this.foreground,
    required this.size,
  });

  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: foreground,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          size: size * 0.58,
          color: background,
        ),
      ),
    );
  }
}

class _TrailingAction extends StatelessWidget {
  const _TrailingAction({
    required this.foreground,
    required this.isCompleted,
    required this.size,
  });

  final Color foreground;
  final bool isCompleted;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.11),
          shape: BoxShape.circle,
          border: Border.all(
            color: foreground.withValues(alpha: 0.07),
          ),
        ),
        child: Icon(
          isCompleted
              ? Icons.replay_rounded
              : Icons.arrow_forward_rounded,
          size: size * 0.48,
          color: foreground,
        ),
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.isCompleted,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        constraints: BoxConstraints(
          minHeight: 42.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 17.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: foreground,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              isCompleted
                  ? Icons.replay_rounded
                  : Icons.arrow_forward_rounded,
              size: 16.r,
              color: foreground,
            ),
          ],
        ),
      ),
    );
  }
}

bool _hasText(String? value) {
  return value?.trim().isNotEmpty == true;
}

String _survivalSemanticsLabel(SurvivalSituationModel item) {
  if (!_hasText(item.subtitleBn)) {
    return item.title;
  }

  return '${item.title}. ${item.subtitleBn!.trim()}';
}

Color parseSurvivalCardColor(String value) {
  final String normalized = value.replaceAll(
    RegExp('[^0-9a-fA-F]'),
    '',
  );

  final String argb = switch (normalized.length) {
    3 => 'FF${normalized.split('').map((String value) {
      return '$value$value';
    }).join()}',
    6 => 'FF$normalized',
    8 => normalized,
    _ => '',
  };

  final int? parsed = int.tryParse(
    argb,
    radix: 16,
  );

  return parsed == null
      ? const Color(0xFFE8F7EA)
      : Color(parsed);
}

Color survivalCardForeground(Color background) {
  return background.computeLuminance() > 0.42
      ? const Color(0xFF142219)
      : AppColors.white;
}

Color survivalCardSecondaryForeground(Color background) {
  final Color foreground = survivalCardForeground(background);

  return foreground.withValues(
    alpha: background.computeLuminance() > 0.42
        ? 0.72
        : 0.82,
  );
}

IconData survivalIconFor(String iconKey) {
  return switch (iconKey.trim().toLowerCase()) {
    'clock' => Icons.schedule_rounded,
    'bus' => Icons.directions_bus_rounded,
    'grocery' => Icons.local_grocery_store_rounded,
    'pharmacy' => Icons.local_pharmacy_rounded,
    'hospital' => Icons.local_hospital_rounded,
    'police' => Icons.local_police_rounded,
    'home' => Icons.home_rounded,
    'location' => Icons.location_on_rounded,
    _ => Icons.description_rounded,
  };
}