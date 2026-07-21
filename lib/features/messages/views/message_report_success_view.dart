import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/message_report_controller.dart';
import '../models/message_models.dart';

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
              MessageReportResultModel(
                referenceId: '#SHK-REP-4922',
                statusLabel: 'under_nreview'.tr,
                reviewSteps: <String>[
                  'Our team has been notified',
                  'Manual review is in progress',
                  'You will be notified once a decision is made',
                ],
              );

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const _BackButton(),

                    SizedBox(height: 28.h),

                    const Center(child: _ReportSuccessHero()),

                    SizedBox(height: 24.h),

                    Center(
                      child: Text(
                        'report_received'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Center(
                      child: Text(
                        'report_received_description'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: AppColors.modalTextGrey,
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),

                    _ReportReferenceCard(report: report),

                    SizedBox(height: 18.h),

                    _ReviewProcessCard(steps: report.reviewSteps),

                    SizedBox(height: 28.h),

                    CustomButton.primary(
                      text: 'back_to_messages'.tr,
                      onPressed: controller.backToMessages,
                    ),
                  ],
                ),
              ),
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
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 1.5,
      shadowColor: AppColors.homeNeutralShadow,
      child: InkWell(
        onTap: () => Get.back<void>(),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44.r,
          height: 44.r,
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.homePrimaryText,
            size: 22.r,
          ),
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
      width: 112.r,
      height: 112.r,
      decoration: BoxDecoration(
        color: AppColors.blockSuccessIconBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.reportSuccessOuterGreen,
          width: 6.r,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blockSuccessGlow,
            blurRadius: 30.r,
            spreadRadius: 8.r,
          ),
        ],
      ),
      child: Icon(
        Icons.verified_user_rounded,
        color: AppColors.white,
        size: 54.r,
      ),
    );
  }
}

class _ReportReferenceCard extends StatelessWidget {
  const _ReportReferenceCard({required this.report});

  final MessageReportResultModel report;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _ReportReferenceDashedPainter(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Widget referenceSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'reference_id'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  report.referenceId,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: AppColors.homePrimaryText,
                  ),
                ),
              ],
            );

            final Widget statusBadge = Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.reportStatusBg,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Flexible(
                    child: Text(
                      report.statusLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (constraints.maxWidth < 320) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  referenceSection,
                  SizedBox(height: 14.h),
                  statusBadge,
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(child: referenceSection),
                SizedBox(width: 14.w),
                Flexible(child: statusBadge),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReviewProcessCard extends StatelessWidget {
  const _ReviewProcessCard({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.reportReviewBg,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: AppColors.reportReviewIconBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: AppColors.profileBlueText,
                  size: 23.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'review_process'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.reportReviewText,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          ...steps.map((String step) => _ReviewStep(text: step)),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 22.r,
            height: 22.r,
            margin: EdgeInsets.only(top: 1.h),
            decoration: const BoxDecoration(
              color: AppColors.profileBlueText,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.white,
              size: 14.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                height: 1.45,
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
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final RRect border = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(18.r),
    );

    final Path path = Path()..addRRect(border);

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final double next = distance + 8;

        canvas.drawPath(metric.extractPath(distance, next), paint);

        distance = next + 6;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
