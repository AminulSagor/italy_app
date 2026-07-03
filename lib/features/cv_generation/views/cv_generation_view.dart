import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/simple_appbar.dart';
import '../controllers/cv_generation_controller.dart';

class CvGenerationView
    extends GetView<CvGenerationController> {
  const CvGenerationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: SimpleAppbar(
        title: 'Generated CV',
        onBackTap: Get.back,
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.errorMessage.value.isNotEmpty) {
            return _ErrorState(
              message:
              controller.errorMessage.value,
              onRetry: controller.retry,
            );
          }

          final generation =
              controller.generation.value;

          if (controller.isLoading.value ||
              generation == null ||
              generation.isProcessing) {
            return const _GeneratingState();
          }

          final String imageUrl =
              generation.generatedImageUrl ?? '';

          if (imageUrl.isEmpty) {
            return _ErrorState(
              message:
              'The generated CV image is unavailable.',
              onRetry: controller.retry,
            );
          }

          return _CompletedState(
            imageUrl: imageUrl,
            isRegenerating:
            controller.isRegenerating.value,
            onRegenerate: controller.regenerate,
          );
        }),
      ),
    );
  }
}

class _GeneratingState extends StatelessWidget {
  const _GeneratingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 66.w,
              height: 66.w,
              child: const CircularProgressIndicator(
                strokeWidth: 5,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Creating Your CV',
              style: TextStyle(
                fontSize: 23.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(height: 9.h),
            Text(
              'The CV assistant is arranging your information and generating the final image.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color:
                AppColors.homeSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedState extends StatelessWidget {
  const _CompletedState({
    required this.imageUrl,
    required this.isRegenerating,
    required this.onRegenerate,
  });

  final String imageUrl;
  final bool isRegenerating;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        22.h,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(22.r),
              ),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? progress,
                      ) {
                    if (progress == null) {
                      return child;
                    }

                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                      ) {
                    return const Center(
                      child: Icon(
                        Icons
                            .broken_image_outlined,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 13.h),
          Text(
            'Review the spelling, dates, phone number, email, and all other details before using this CV.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.4,
              color:
              AppColors.homeSecondaryText,
            ),
          ),
          SizedBox(height: 14.h),
          CustomButton.primary(
            text: 'Regenerate CV',
            prefixIcon: Icons.refresh_rounded,
            isLoading: isRegenerating,
            onPressed: onRegenerate,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(26.w),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.error_outline_rounded,
                size: 54.w,
                color: Colors.red,
              ),
              SizedBox(height: 15.h),
              Text(
                'CV Generation Failed',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color:
                  AppColors.homeSecondaryText,
                ),
              ),
              SizedBox(height: 20.h),
              CustomButton.primary(
                text: 'Try Again',
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}