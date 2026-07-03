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
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.homeBackground,
      child: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: controller.refreshTemplates,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16.w,
              20.h,
              16.w,
              130.h,
            ),
            children: <Widget>[
              Text(
                'Create Your CV',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                'Choose a CV template or let the CV assistant create a design from scratch.',
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.5,
                  color:
                  AppColors.homeSecondaryText,
                ),
              ),
              SizedBox(height: 22.h),
              Obx(
                    () => _ScratchCard(
                  isLoading:
                  controller.isStartingScratch.value,
                  onTap:
                  controller.startScratchChat,
                ),
              ),
              SizedBox(height: 28.h),
              Text(
                'Choose a Template',
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w900,
                  color:
                  AppColors.homePrimaryText,
                ),
              ),
              SizedBox(height: 13.h),
              Obx(
                    () => TextField(
                  controller:
                  controller.searchController,
                  onChanged:
                  controller.onSearchChanged,
                  decoration: InputDecoration(
                    hintText:
                    'Search CV templates...',
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
                      controller.clearSearch,
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(28.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Obx(() => _buildTemplateArea()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateArea() {
    if (controller.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.errorMessage.value.isNotEmpty &&
        controller.templates.isEmpty) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Could not load templates',
        message: controller.errorMessage.value,
        actionLabel: 'Try Again',
        onAction: () =>
            controller.loadTemplates(reset: true),
      );
    }

    if (controller.templates.isEmpty) {
      return _EmptyState(
        icon: Icons.description_outlined,
        title: 'No templates found',
        message: controller.searchQuery.value.isEmpty
            ? 'No CV templates are currently available.'
            : 'No template matches your search.',
        actionLabel:
        controller.searchQuery.value.isEmpty
            ? null
            : 'Clear Search',
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

            return CvTemplateCard(
              template: template,
              isLoading: controller
                  .startingTemplateId.value ==
                  template.id,
              onTap: () =>
                  controller.startTemplateChat(
                    template,
                  ),
            );
          },
        ),
        if (controller.canLoadMore) ...<Widget>[
          SizedBox(height: 22.h),
          CustomButton(
            width: double.infinity,
            text: 'Load More',
            isLoading:
            controller.isLoadingMore.value,
            onPressed: () =>
                controller.loadTemplates(
                  reset: false,
                ),
          ),
        ],
      ],
    );
  }
}

class _ScratchCard extends StatelessWidget {
  const _ScratchCard({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryGreen,
      borderRadius: BorderRadius.circular(24.r),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: <Widget>[
              Container(
                width: 54.w,
                height: 54.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius:
                  BorderRadius.circular(18.r),
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
                      'Build From Scratch',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Chat with the CV assistant, share your preferences, and generate a professional CV.',
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
        borderRadius: BorderRadius.circular(24.r),
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