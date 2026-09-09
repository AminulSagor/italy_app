import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../controllers/cv_home_controller.dart';
import '../helpers/cv_builder_localization.dart';
import '../models/cv_template_model.dart';
import '../widgets/cv_template_card.dart';
import '../widgets/cv_template_list_skeleton.dart';

class CvHomeView extends GetView<CvHomeController> {
  const CvHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.homeBackground,
      child: SafeArea(
        top: false,
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: controller.refreshTemplates,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 130.h),
            children: <Widget>[
              const _Header(),
              SizedBox(height: 8.h),
              const _QuickActionsRow(),
              SizedBox(height: 8.h),
              _SearchField(controller: controller),
              SizedBox(height: 6.h),
              _CategoryChips(controller: controller),
              Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: controller.isFiltering.value
                      ? Padding(
                          key: const ValueKey<String>('filter-loading'),
                          padding: EdgeInsets.only(top: 12.h),
                          child: const LinearProgressIndicator(
                            minHeight: 2,
                            color: AppColors.primaryGreen,
                          ),
                        )
                      : const SizedBox(
                          key: ValueKey<String>('filter-idle'),
                          height: 8,
                        ),
                ),
              ),
              _TemplateArea(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'cvb_home_title'.tr,
          style: TextStyle(
            fontSize: 27.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }
}

class _QuickActionsRow extends GetView<CvHomeController> {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Obx(() {
                final CvAccessModel? access = controller.cvAccess.value;
                if (access == null) return const _CompactCardSkeleton();
                return _CreditsCard(access: access);
              }),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Obx(
                () => _MyCvsCard(
                  loading: controller.isOpeningLibrary.value,
                  onTap: controller.openMyCvs,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditsCard extends StatelessWidget {
  const _CreditsCard({required this.access});

  final CvAccessModel access;

  @override
  Widget build(BuildContext context) {
    final bool freeNext = access.nextIsFree;
    final bool paidNext = access.nextUsesPaidCredit;
    final Color background = freeNext
        ? const Color(0xFFEAF6EC)
        : paidNext
        ? const Color(0xFFFFF3DE)
        : const Color(0xFFF0F2F1);
    final Color accent = freeNext
        ? const Color(0xFF176B38)
        : paidNext
        ? const Color(0xFF8A5A00)
        : const Color(0xFF606965);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              freeNext ? Icons.card_giftcard_rounded : Icons.toll_rounded,
              size: 19.r,
              color: accent,
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'cvb_credits'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'cvb_credit_summary'.trParams(<String, String>{
                    'free': '${access.freeCreationsRemaining}',
                    'paid': '${access.paidCredits}',
                  }),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyCvsCard extends StatelessWidget {
  const _MyCvsCard({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFD8E7DF)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: loading
                    ? Padding(
                        padding: EdgeInsets.all(9.r),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryGreen,
                        ),
                      )
                    : const Icon(
                        Icons.folder_open_rounded,
                        color: AppColors.primaryGreen,
                      ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'cvb_my_cvs'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.homePrimaryText,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'cvb_drafts_pdfs'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactCardSkeleton extends StatelessWidget {
  const _CompactCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E9E7),
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final CvHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'cvb_search_designs'.tr,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.searchQuery.value.isEmpty
              ? null
              : IconButton(
                  onPressed: controller.clearSearch,
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 13.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.controller});

  final CvHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Read it HERE so Obx reacts when selection changes.
      final String selectedCategory = controller.selectedCategory.value
          .trim()
          .toLowerCase();

      if (controller.categories.isEmpty) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 38.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length + 1,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (BuildContext context, int index) {
            final String rawCategory = index == 0
                ? ''
                : controller.categories[index - 1].category;

            final String category = rawCategory.trim().toLowerCase();

            final String label = category.isEmpty
                ? 'cvb_all'.tr
                : cvCategoryLabel(rawCategory);

            final bool selected = selectedCategory == category;

            return ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => controller.selectCategory(category),

              // Clear selected state.
              selectedColor: AppColors.primaryGreen,
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,

              labelStyle: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? Colors.white : AppColors.homeSecondaryText,
              ),

              side: BorderSide(
                color: selected
                    ? AppColors.primaryGreen
                    : const Color(0xFFE1E7E3),
              ),
            );
          },
        ),
      );
    });
  }
}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: Row(
        children: <Widget>[
          for (final double width in <double>[54, 94, 78, 88]) ...<Widget>[
            Container(
              width: width.w,
              height: 34.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E8E6),
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }
}

class _TemplateArea extends StatelessWidget {
  const _TemplateArea({required this.controller});

  final CvHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isInitialLoading.value && controller.templates.isEmpty) {
        return const CvTemplateListSkeleton();
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.templates.isEmpty) {
        return _StateCard(
          icon: Icons.cloud_off_outlined,
          title: 'cvb_load_templates_failed'.tr,
          message: controller.errorMessage.value,
          actionLabel: 'cvb_try_again'.tr,
          onAction: () =>
              controller.loadHomeBootstrap(showBlockingLoading: true),
        );
      }

      if (controller.templates.isEmpty) {
        return _StateCard(
          icon: Icons.search_off_rounded,
          title: 'cvb_no_templates'.tr,
          message:
              controller.searchQuery.value.isNotEmpty ||
                  controller.selectedCategory.value.isNotEmpty
              ? 'cvb_try_search_category'.tr
              : 'cvb_no_published_templates'.tr,
          actionLabel: controller.searchQuery.value.isNotEmpty
              ? 'cvb_clear_search'.tr
              : null,
          onAction: controller.searchQuery.value.isNotEmpty
              ? controller.clearSearch
              : null,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'cvb_designs'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimaryText,
                  ),
                ),
              ),
              Text(
                '${controller.totalItems.value}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.homeSecondaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            'cvb_inspect_design'.tr,
            style: TextStyle(
              fontSize: 10.5.sp,
              color: AppColors.homeSecondaryText,
            ),
          ),
          SizedBox(height: 11.h),
          ...controller.templates.map(
            (CvTemplateModel template) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: CvTemplateCard(
                key: ValueKey<String>('template-${template.id}'),
                template: template,
                onTap: () => controller.openTemplate(template),
              ),
            ),
          ),
          if (controller.canLoadMore) ...<Widget>[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.isLoadingMore.value
                    ? null
                    : () => controller.loadTemplates(reset: false),
                child: controller.isLoadingMore.value
                    ? SizedBox(
                        width: 19.w,
                        height: 19.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryGreen,
                        ),
                      )
                    : Text('cvb_load_more_designs'.tr),
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
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
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 42.w, color: AppColors.homeSecondaryText),
          SizedBox(height: 10.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.4,
              color: AppColors.homeSecondaryText,
            ),
          ),
          if (actionLabel != null && onAction != null) ...<Widget>[
            SizedBox(height: 12.h),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
