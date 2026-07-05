import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/cv_home_controller.dart';
import '../models/cv_template_model.dart';
import '../widgets/cv_template_card.dart';

class CvHomeView extends GetView<CvHomeController> {
  const CvHomeView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Material(
            color: AppColors.homeBackground,
            child: SafeArea(
              top: false,
              child: RefreshIndicator(
                onRefresh:
                controller.refreshTemplates,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    20.h,
                    16.w,
                    130.h,
                  ),
                  children: <Widget>[
                    Text(
                      'cv_home_create_your_cv'.tr,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight:
                        FontWeight.w900,
                        color:
                        AppColors.primaryGreen,
                      ),
                    ),
                    SizedBox(height: 7.h),
                    Text(
                      'cv_home_description'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.5,
                        color: AppColors
                            .homeSecondaryText,
                      ),
                    ),
                    SizedBox(height: 22.h),

                    Obx(
                          () => _ScratchCard(
                        isLoading: controller
                            .isStartingScratch.value,
                        isDisabled: controller
                            .isStartingAnySession &&
                            !controller
                                .isStartingScratch.value,
                        onTap: controller
                            .startScratchChat,
                      ),
                    ),

                    SizedBox(height: 28.h),

                    Text(
                      'cv_home_choose_template'.tr,
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight:
                        FontWeight.w900,
                        color: AppColors
                            .homePrimaryText,
                      ),
                    ),

                    SizedBox(height: 13.h),

                    Obx(
                          () => TextField(
                        controller: controller
                            .searchController,
                        onChanged: controller
                            .onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'cv_home_search_templates'.tr,
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                          ),
                          suffixIcon: controller
                              .searchQuery
                              .value
                              .isEmpty
                              ? null
                              : IconButton(
                            onPressed:
                            controller
                                .clearSearch,
                            icon: const Icon(
                              Icons
                                  .close_rounded,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              28.r,
                            ),
                            borderSide:
                            BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Obx(
                          () => _buildTemplateArea(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (controller
              .isTemplateOverlayVisible.value)
            const Positioned.fill(
              child:
              _TemplateAnalyzingOverlay(),
            ),
        ],
      ),
    );
  }

  Widget _buildTemplateArea() {
    if (controller.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 50,
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.errorMessage.value.isNotEmpty &&
        controller.templates.isEmpty) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'cv_home_could_not_load_templates'.tr,
        message: controller.errorMessage.value,
        actionLabel: 'cv_home_try_again'.tr,
        onAction: () {
          controller.loadTemplates(
            reset: true,
          );
        },
      );
    }

    if (controller.templates.isEmpty) {
      return _EmptyState(
        icon: Icons.description_outlined,
        title: 'cv_home_no_templates_found'.tr,
        message:
        controller.searchQuery.value.isEmpty
            ? 'cv_home_no_templates_available'.tr
            : 'cv_home_no_search_match'.tr,
        actionLabel:
        controller.searchQuery.value.isEmpty
            ? null
            : 'cv_home_clear_search'.tr,
        onAction:
        controller.searchQuery.value.isEmpty
            ? null
            : controller.clearSearch,
      );
    }

    return Column(
      children: <Widget>[
        GridView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount: controller.templates.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 14.h,
            childAspectRatio: 0.61,
          ),
          itemBuilder: (
              BuildContext context,
              int index,
              ) {
            final CvTemplateModel template =
            controller.templates[index];

            final bool isAnalyzing =
            controller.isTemplateAnalyzing(
              template.id,
            );

            final bool isDisabled =
            controller
                .isTemplateInteractionDisabled(
              template.id,
            );

            final bool hasError =
            controller
                .hasTemplateAnalysisFailed(
              template.id,
            );

            return CvTemplateCard(
              template: template,

              isAnalyzing: isAnalyzing,

              isDisabled: isDisabled,

              hasError: hasError,

              errorMessage: hasError
                  ? controller
                  .analysisErrorMessage.value
                  : null,

              onTap: () {
                controller.startTemplateChat(
                  template,
                );
              },

              onRetry: () {
                controller.retryTemplateAnalysis(
                  template,
                );
              },
            );
          },
        ),

        if (controller.canLoadMore) ...<Widget>[
          SizedBox(height: 22.h),
          CustomButton(
            width: double.infinity,
            text: 'cv_home_load_more'.tr,
            isLoading:
            controller.isLoadingMore.value,
            onPressed: () {
              controller.loadTemplates(
                reset: false,
              );
            },
          ),
        ],
      ],
    );
  }

}

class _TemplateAnalyzingOverlay
    extends StatelessWidget {
  const _TemplateAnalyzingOverlay();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(
        alpha: 0.48,
      ),
      child: AbsorbPointer(
        absorbing: true,
        child: SafeArea(
          child: Center(
            child: Container(
              width: 310.w,
              margin: EdgeInsets.symmetric(
                horizontal: 26.w,
              ),
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(24.r),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 66.w,
                    height: 66.w,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF7E4),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 32.w,
                      height: 32.w,
                      child:
                      const CircularProgressIndicator(
                        strokeWidth: 3.2,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  Text(
                    'cv_home_analyzing_template'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w900,
                      color:
                      AppColors.homePrimaryText,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    'cv_home_analyzing_description'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      height: 1.5,
                      color: AppColors
                          .homeSecondaryText,
                    ),
                  ),

                  SizedBox(height: 17.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 13.w,
                      vertical: 11.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7E4),
                      borderRadius:
                      BorderRadius.circular(13.r),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 18.w,
                          color:
                          AppColors.primaryGreen,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'cv_home_assistant_open_automatically'.tr,
                            style: TextStyle(
                              fontSize: 11.sp,
                              height: 1.4,
                              fontWeight:
                              FontWeight.w700,
                              color: AppColors
                                  .primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 13.h),

                  Text(
                    'cv_home_stay_on_page'.tr,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors
                          .homeSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScratchCard extends StatelessWidget {
  const _ScratchCard({
    required this.isLoading,
    required this.isDisabled,
    required this.onTap,
  });

  final bool isLoading;

  final bool isDisabled;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool cannotTap =
        isLoading || isDisabled;

    return Opacity(
      opacity: isDisabled ? 0.55 : 1,
      child: Material(
        color: AppColors.primaryGreen,
        borderRadius:
        BorderRadius.circular(24.r),
        child: InkWell(
          onTap: cannotTap ? null : onTap,
          borderRadius:
          BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: <Widget>[
                Container(
                  width: 54.w,
                  height: 54.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                    Colors.white.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      18.r,
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Icon(
                    Icons
                        .auto_awesome_rounded,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'cv_home_build_from_scratch'.tr,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight:
                          FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'cv_home_build_from_scratch_description'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.4,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;

  final String title;

  final String message;

  final String? actionLabel;

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(24.r),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            size: 48.w,
            color: AppColors.primaryGreen,
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.4,
              color:
              AppColors.homeSecondaryText,
            ),
          ),
          if (actionLabel != null &&
              onAction != null) ...<Widget>[
            SizedBox(height: 18.h),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}