import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/message_report_controller.dart';
import '../models/message_models.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';

class MessageReportSuccessView extends GetView<MessageReportController> {
  const MessageReportSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Obx(() {
          final MessageReportResultModel report =
              controller.reportResult.value ??
              const MessageReportResultModel(
                referenceId: '#SHK-REP-4922',
                statusLabel: 'Under\nReview',
                reviewSteps: <String>[
                  'Our team has been notified',
                  'Manual review is in progress',
                  'You will be notified once a decision is made',
                ],
              );

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 42.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _BackButton(),
                SizedBox(height: 56.h),
                const Center(child: _ReportSuccessHero()),
                SizedBox(height: 70.h),
                Center(
                  child: Text(
                    'Report Received',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font46.sp,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Center(
                  child: Text(
                    'Thank you for keeping our community\nsafe. Our admin team will review your\nreport shortly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFont.font24.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                      color: AppColors.modalTextGrey,
                    ),
                  ),
                ),
                SizedBox(height: 64.h),
                _ReportReferenceCard(report: report),
                SizedBox(height: 50.h),
                _ReviewProcessCard(steps: report.reviewSteps),
                SizedBox(height: 62.h),
                CustomButton.primary(
                  text: 'Back To Messages',
                  onPressed: controller.backToMessages,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back<void>(),
      child: Container(
        width: 64.w,
        height: 64.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.homeNeutralShadow,
              blurRadius: 18.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: AppColors.homePrimaryText,
          size: 34.w,
        ),
      ),
    );
  }
}

class _ReportSuccessHero extends StatelessWidget {
  const _ReportSuccessHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kReportSuccessHeroSize.w,
      height: kReportSuccessHeroSize.w,
      decoration: BoxDecoration(
        color: AppColors.blockSuccessIconBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.reportSuccessOuterGreen,
          width: 12.w,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blockSuccessGlow,
            blurRadius: 74.r,
            spreadRadius: 30.r,
          ),
        ],
      ),
      child: Icon(
        Icons.verified_user_rounded,
        color: AppColors.white,
        size: 100.w,
      ),
    );
  }
}

class _ReportReferenceCard extends StatelessWidget {
  final MessageReportResultModel report;

  const _ReportReferenceCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _ReportReferenceDashedPainter(),
      child: Container(
        width: double.infinity,
        height: kReportReferenceCardHeight.h,
        padding: EdgeInsets.symmetric(horizontal: 42.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(kRadius42.r),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'REFERENCE ID',
                    style: TextStyle(
                      fontSize: AppFont.font16.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      color: AppColors.bodyText,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    report.referenceId.replaceFirst('4922', '\n4922'),
                    style: TextStyle(
                      fontSize: AppFont.font24.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                      color: AppColors.homePrimaryText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 18.h),
              decoration: BoxDecoration(
                color: AppColors.reportStatusBg,
                borderRadius: BorderRadius.circular(kHomePillRadius.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    report.statusLabel,
                    style: TextStyle(
                      fontSize: AppFont.font22.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewProcessCard extends StatelessWidget {
  final List<String> steps;

  const _ReviewProcessCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: kReportReviewCardMinHeight.h),
      padding: EdgeInsets.fromLTRB(42.w, 38.h, 42.w, 36.h),
      decoration: BoxDecoration(
        color: AppColors.reportReviewBg,
        borderRadius: BorderRadius.circular(kSafetySuccessInfoCardRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: AppColors.reportReviewIconBg,
                  borderRadius: BorderRadius.circular(kRadius20.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.profileBlueText.withValues(alpha: 0.14),
                      blurRadius: 18.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: AppColors.profileBlueText,
                  size: 36.w,
                ),
              ),
              SizedBox(width: 24.w),
              Text(
                'Review Process',
                style: TextStyle(
                  fontSize: AppFont.font28.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.reportReviewText,
                ),
              ),
            ],
          ),
          SizedBox(height: 44.h),
          ...steps.map((String step) => _ReviewStep(text: step)),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final String text;

  const _ReviewStep({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 28.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 28.w,
            height: 28.w,
            margin: EdgeInsets.only(top: 4.h),
            decoration: const BoxDecoration(
              color: AppColors.profileBlueText,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.white,
              size: 18.w,
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppFont.font22.sp,
                fontWeight: FontWeight.w500,
                height: 1.38,
                color: AppColors.reportReviewText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportReferenceDashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.reportReferenceBorder
      ..strokeWidth = 2.4.w
      ..style = PaintingStyle.stroke;

    final RRect border = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(kRadius42.r),
    );
    final Path path = Path()..addRRect(border);

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + 10.w;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + 8.w;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
