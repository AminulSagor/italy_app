import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../controllers/practice_hub_controller.dart';
import '../../models/practice_hub_models.dart';
import 'practice_hub_skill_builder_grid.dart';

class PracticeHubWebinarCard extends GetView<PracticeHubController> {
  const PracticeHubWebinarCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final PracticeHubWebinarModel? webinar = controller.featuredWebinar.value;

      if (controller.isPracticeHubOverviewLoading.value && webinar == null) {
        return Container(
          height: 240.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: const CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        );
      }

      if (webinar == null) {
        return PracticeHubSectionMessage(
          message: controller.practiceHubOverviewError.value.isEmpty
              ? 'No upcoming webinar is available.'
              : controller.practiceHubOverviewError.value,
          onRetry: () => controller.loadPracticeHubOverview(showError: true),
        );
      }

      final String detail = _webinarDetail(webinar);
      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1.w),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18.r,
              offset: Offset(0, 9.h),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            _WebinarStatusPill(isLive: webinar.isLive),
            SizedBox(height: 15.h),
            Text(
              webinar.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                height: 1.15,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.45,
                color: const Color(0xFF2F3337),
              ),
            ),
            if (detail.isNotEmpty) ...<Widget>[
              SizedBox(height: 10.h),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.font15.sp,
                  height: 1.42,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6A6F73),
                ),
              ),
            ],
            SizedBox(height: 19.h),
            CustomButton(
              onPressed: controller.onViewAllSessionsTap,
              text: 'View All Sessions  →',
              height: 43,
              width: double.infinity,
              btnColor: AppColors.primaryGreen,
              borderColor: AppColors.primaryGreen,
              textColor: AppColors.white,
              fontSize: AppFont.font16,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 15.h),
            CustomButton(
              onPressed: controller.onNotifyMeTap,
              text: 'Notify Me',
              prefixIcon: Icons.notifications_none_rounded,
              height: 45,
              width: double.infinity,
              btnColor: AppColors.white,
              borderColor: const Color(0xFFDCDDDE),
              textColor: const Color(0xFF707477),
              fontSize: AppFont.font16,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      );
    });
  }

  String _webinarDetail(PracticeHubWebinarModel webinar) {
    final List<String> parts = <String>[];
    if (webinar.hostTeacherName.trim().isNotEmpty) {
      parts.add('Hosted by ${webinar.hostTeacherName.trim()}');
    }
    final DateTime? date = webinar.dateTime;
    if (date != null) {
      final String day = date.day.toString().padLeft(2, '0');
      final String month = date.month.toString().padLeft(2, '0');
      final String hour = (date.hour % 12 == 0 ? 12 : date.hour % 12)
          .toString();
      final String minute = date.minute.toString().padLeft(2, '0');
      final String period = date.hour >= 12 ? 'PM' : 'AM';
      parts.add('$day/$month/${date.year} · $hour:$minute $period');
    }
    return parts.join('\n');
  }
}

class _WebinarStatusPill extends StatelessWidget {
  const _WebinarStatusPill({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 31.h,
      padding: EdgeInsets.symmetric(horizontal: 13.w),
      decoration: BoxDecoration(
        color: isLive ? const Color(0xFFDDF8C9) : const Color(0xFFE7EEF7),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(
              color: isLive
                  ? AppColors.primaryGreen
                  : const Color(0xFF416C9D),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            isLive ? 'LIVE NOW' : 'UPCOMING',
            style: TextStyle(
              fontSize: AppFont.font15.sp,
              height: 1,
              fontWeight: FontWeight.w600,
              color: isLive
                  ? AppColors.primaryGreen
                  : const Color(0xFF416C9D),
            ),
          ),
        ],
      ),
    );
  }
}
