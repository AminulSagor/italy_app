import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/practice_hub_controller.dart';
import '../../models/practice_hub_models.dart';

class PracticeHubSkillBuilderGrid extends GetView<PracticeHubController> {
  const PracticeHubSkillBuilderGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isPracticeHubOverviewLoading.value &&
          controller.skillBuilders.isEmpty) {
        return SizedBox(
          height: 220.h,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
        );
      }

      if (controller.skillBuilders.isEmpty) {
        return PracticeHubSectionMessage(
          message: controller.practiceHubOverviewError.value.isEmpty
              ? 'no_skill_builders_are_available'.tr
              : controller.practiceHubOverviewError.value,
          onRetry: () => controller.loadPracticeHubOverview(showError: true),
        );
      }

      return GridView.builder(
        itemCount: controller.skillBuilders.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 18.h,
          childAspectRatio: 1.35,
        ),
        itemBuilder: (BuildContext context, int index) {
          final PracticeHubSkillBuilderModel item =
              controller.skillBuilders[index];
          final _SkillBuilderVisual visual =
              _SkillBuilderVisual.fromType(item.type);

          return _SkillBuilderCard(
            title: item.title,
            subtitle: item.subtitle,
            icon: visual.icon,
            background: visual.background,
            accent: visual.accent,
            iconColor: visual.iconColor,
            textColor: visual.textColor,
            onTap: () => controller.onSkillBuilderTap(item.type),
          );
        },
      );
    });
  }
}

class _SkillBuilderVisual {
  const _SkillBuilderVisual({
    required this.icon,
    required this.background,
    required this.accent,
    required this.iconColor,
    required this.textColor,
  });

  final IconData icon;
  final Color background;
  final Color accent;
  final Color iconColor;
  final Color textColor;

  factory _SkillBuilderVisual.fromType(PracticeHubSkillBuilderType type) {
    return switch (type) {
      PracticeHubSkillBuilderType.importantVerbs =>
        const _SkillBuilderVisual(
          icon: Icons.translate_rounded,
          background: Color(0xFFE4F7D9),
          accent: Color(0xFFBDECA5),
          iconColor: Color(0xFF257400),
          textColor: Color(0xFF205C07),
        ),
      PracticeHubSkillBuilderType.survivalItalian =>
        const _SkillBuilderVisual(
          icon: Icons.flight_takeoff_rounded,
          background: Color(0xFFFFE8C4),
          accent: Color(0xFFFFCE80),
          iconColor: Color(0xFFB86600),
          textColor: Color(0xFF7B4808),
        ),
      PracticeHubSkillBuilderType.jobSentences =>
        const _SkillBuilderVisual(
          icon: Icons.work_outline_rounded,
          background: Color(0xFFDDEDFE),
          accent: Color(0xFFAECFF5),
          iconColor: Color(0xFF1768A5),
          textColor: Color(0xFF24577E),
        ),
      PracticeHubSkillBuilderType.dailyChallenges =>
        const _SkillBuilderVisual(
          icon: Icons.local_fire_department_rounded,
          background: Color(0xFFFFDEDA),
          accent: Color(0xFFFFB7AC),
          iconColor: Color(0xFFCC432E),
          textColor: Color(0xFF843428),
        ),
    };
  }
}

class _SkillBuilderCard extends StatelessWidget {
  const _SkillBuilderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.accent,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color accent;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            top: 7.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(42.r),
              ),
            ),
          ),
          Positioned.fill(
            bottom: 7.h,
            child: Container(
              padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 16.h),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(42.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 31.r, color: iconColor),
                  SizedBox(height: 13.h),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font14.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 8.h)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PracticeHubSectionMessage extends StatelessWidget {
  const PracticeHubSectionMessage({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: const Color(0xFFE2E4E5)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF676C70),
            ),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onRetry,
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }
}

