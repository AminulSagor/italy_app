import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../controllers/important_verbs_controller.dart';
import '../../../models/important_verb_models.dart';
import 'important_verb_loading_widgets.dart';

class SearchSuggestionOverlay extends GetView<ImportantVerbsController> {
  const SearchSuggestionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<ImportantVerbSummaryModel> results =
          controller.searchSuggestions;
      final bool isLoading = controller.isSearchLoading.value;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(26.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 22.r,
              offset: Offset(0, 11.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26.r),
          child: isLoading && results.isEmpty
              ? const SearchSuggestionSkeleton()
              : results.isEmpty
              ? SizedBox(
                  height: 88.h,
                  child: Center(
                    child: Text(
                      'no_verbs_found'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6F7478),
                      ),
                    ),
                  ),
                )
              : Column(
                  children: <Widget>[
                    ...results.map(
                      (ImportantVerbSummaryModel verb) => _SearchSuggestionTile(
                        verb: verb,
                        onTap: () => controller.onVerbSuggestionTap(verb),
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.onViewAllSearchResultsTap,
                      child: Container(
                        height: 40.h,
                        alignment: Alignment.center,
                        child: Text(
                          'view_all_results'.tr,
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}

class _SearchSuggestionTile extends StatelessWidget {
  const _SearchSuggestionTile({required this.verb, required this.onTap});

  final ImportantVerbSummaryModel verb;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 66.h,
        padding: EdgeInsets.symmetric(horizontal: 17.w),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFECEDED), width: 1),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 35.r,
              height: 35.r,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF9E9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 20.r,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    verb.infinitive,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 19.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF303437),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${verb.englishMeaning} • ${verb.banglaMeaning}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF60656A),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 9.w),
            _CompactVerbBadge(verb: verb),
          ],
        ),
      ),
    );
  }
}

class _CompactVerbBadge extends StatelessWidget {
  const _CompactVerbBadge({required this.verb});

  final ImportantVerbSummaryModel verb;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7ED),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Center(
        child: Text(
          '${verb.endingLabel} / ${verb.isIrregular ? 'irreg'.tr : 'reg'.tr}',
          style: TextStyle(
            fontSize: 9.5.sp,
            height: 1,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF69716B),
          ),
        ),
      ),
    );
  }
}

class VerbFilterChips extends StatelessWidget {
  const VerbFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
    this.isLoading = false,
  });

  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (
            BuildContext context,
            int index,
            ) {
          final String filter = filters[index];
          final bool isSelected =
              filter == selectedFilter;

          final bool showSpinner =
              isLoading && isSelected;

          return GestureDetector(
            onTap: isLoading
                ? null
                : () => onSelected(filter),
            child: AnimatedOpacity(
              duration: const Duration(
                milliseconds: 180,
              ),
              opacity: isLoading && !isSelected
                  ? 0.55
                  : 1,
              child: Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.white,
                  borderRadius:
                  BorderRadius.circular(999.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : const Color(0xFFE0E3E5),
                    width: 1.5.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (showSpinner) ...<Widget>[
                      SizedBox(
                        width: 14.r,
                        height: 14.r,
                        child:
                        const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 7.w),
                    ],
                    Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class VerbLibraryList extends StatelessWidget {
  const VerbLibraryList({
    super.key,
    required this.verbs,
    required this.isLoading,
    required this.isLoadingMore,
    required this.error,
    required this.onRetry,
  });

  final List<ImportantVerbSummaryModel> verbs;
  final bool isLoading;
  final bool isLoadingMore;
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // First load, filter with no existing data, or empty search.
    if (isLoading && verbs.isEmpty) {
      return const VerbLibrarySkeleton();
    }

    if (error.isNotEmpty && verbs.isEmpty) {
      return _VerbListMessage(
        message: error,
        actionLabel: 'retry'.tr,
        onAction: onRetry,
      );
    }

    if (verbs.isEmpty) {
      return _VerbListMessage(
        message: 'no_verbs_found'.tr,
      );
    }

    return Column(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(
            milliseconds: 180,
          ),
          child: isLoading
              ? Padding(
            key: const ValueKey<String>(
              'verb-list-refreshing',
            ),
            padding: EdgeInsets.only(
              bottom: 14.h,
            ),
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(999.r),
              child:
              const LinearProgressIndicator(
                minHeight: 3,
                color: AppColors.primaryGreen,
                backgroundColor:
                Color(0xFFDDE8D8),
              ),
            ),
          )
              : const SizedBox.shrink(
            key: ValueKey<String>(
              'verb-list-ready',
            ),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(
            milliseconds: 180,
          ),
          opacity: isLoading ? 0.65 : 1,
          child: IgnorePointer(
            ignoring: isLoading,
            child: ListView.separated(
              itemCount: verbs.length,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              separatorBuilder: (_, _) =>
                  SizedBox(height: 14.h),
              itemBuilder: (
                  BuildContext context,
                  int index,
                  ) {
                return VerbLibraryCard(
                  verb: verbs[index],
                );
              },
            ),
          ),
        ),
        if (isLoadingMore) ...<Widget>[
          SizedBox(height: 14.h),
          const VerbLoadMoreSkeleton(),
        ],
      ],
    );
  }
}

class _VerbListMessage extends StatelessWidget {
  const _VerbListMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30.h),
      child: Column(
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6F7478),
            ),
          ),
          if (onAction != null) ...<Widget>[
            SizedBox(height: 12.h),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel ?? 'retry'.tr),
            ),
          ],
        ],
      ),
    );
  }
}

class VerbLibraryCard extends GetView<ImportantVerbsController> {
  const VerbLibraryCard({super.key, required this.verb});

  final ImportantVerbSummaryModel verb;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.openVerbDetails(verb),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 134.h),
        padding: EdgeInsets.fromLTRB(19.w, 17.h, 17.w, 17.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(36.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 17.r,
              offset: Offset(0, 9.h),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      VerbBadge(
                        label: verb.isIrregular ? 'irregular'.tr : 'regular'.tr,
                        dark: verb.isIrregular,
                      ),
                      SizedBox(width: 7.w),
                      VerbBadge(label: verb.endingLabel),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    verb.infinitive,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24.sp,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: const Color(0xFF303437),
                    ),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    verb.englishMeaning,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5D6266),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    verb.banglaMeaning,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5D6266),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 11.w),
            Obx(() {
              final bool isSaving =
              controller.isVerbSavePending(verb.id);

              return CircleVerbActionButton(
                icon: controller.isVerbSaved(verb.id)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                isLoading: isSaving,
                onTap: () => controller.toggleVerbSaved(verb),
              );
            }),
            SizedBox(width: 9.w),
            CircleVerbActionButton(
              icon: Icons.arrow_forward_rounded,
              onTap: () => controller.openVerbDetails(verb),
            ),
          ],
        ),
      ),
    );
  }
}

class VerbBadge extends StatelessWidget {
  const VerbBadge({super.key, required this.label, this.dark = false});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 19.h,
      padding: EdgeInsets.symmetric(horizontal: 9.w),
      decoration: BoxDecoration(
        color: dark ? AppColors.primaryGreen : const Color(0xFFF0F8EC),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: dark ? AppColors.white : const Color(0xFF7C8580),
          ),
        ),
      ),
    );
  }
}

class CircleVerbActionButton extends StatelessWidget {
  const CircleVerbActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        width: 40.r,
        height: 40.r,
        decoration: const BoxDecoration(
          color: Color(0xFFEFF9E9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
            width: 18.r,
            height: 18.r,
            child:
            const CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.primaryGreen,
            ),
          )
              : Icon(
            icon,
            size: 21.r,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }
}
