import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../controllers/practice_hub_controller.dart';
import '../widgets/verb_serch_field.dart';

class ImportantVerbsView extends GetView<PracticeHubController> {
  const ImportantVerbsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: SimpleAppbar(
        title: 'Important Verbs',
        onBackTap: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 42.h),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  'assets/heroes/important_verbs_hero.png',
                  width: double.infinity,
                  height: 144.h,
                  fit: BoxFit.cover,
                ),

                SizedBox(height: 27.h),

                Obx(
                  () => VerbSearchField(
                    textController: controller.importantVerbSearchController,
                    hintText: 'Search for a verb (e.g., Avere)...',
                    query: controller.importantVerbSearchQuery.value,
                    onChanged: controller.onImportantVerbSearchChanged,
                    onClear: controller.clearImportantVerbSearch,
                  ),
                ),

                SizedBox(height: 29.h),

                const SavedVerbPreviewSection(),

                SizedBox(height: 21.h),

                Obx(
                  () => VerbFilterChips(
                    filters: controller.verbFilters,
                    selectedFilter:
                        controller.selectedImportantVerbFilter.value,
                    onSelected: controller.selectImportantVerbFilter,
                  ),
                ),

                SizedBox(height: 27.h),

                Obx(
                  () => VerbLibraryList(
                    verbs: controller.filteredImportantVerbItems,
                  ),
                ),
              ],
            ),

            Obx(() {
              if (controller.importantVerbSearchQuery.value.trim().isEmpty) {
                return const SizedBox.shrink();
              }

              return Positioned(
                top: 224.h,
                left: 0,
                right: 0,
                child: SearchSuggestionOverlay(
                  results: controller.importantVerbSearchResults,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class SearchSuggestionOverlay extends GetView<PracticeHubController> {
  final List<Map<String, dynamic>> results;

  const SearchSuggestionOverlay({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Container(
        height: 88.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(26.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.09),
              blurRadius: 20.r,
              offset: Offset(0, 9.h),
            ),
          ],
        ),
        child: Text(
          'No verbs found',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6F7478),
          ),
        ),
      );
    }

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
        child: Column(
          children: <Widget>[
            ...results.map(
              (Map<String, dynamic> verb) => _SearchSuggestionTile(
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
                  'VIEW ALL RESULTS',
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSuggestionTile extends StatelessWidget {
  final Map<String, dynamic> verb;
  final VoidCallback onTap;

  const _SearchSuggestionTile({required this.verb, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String type = verb['type'] as String? ?? 'regular';
    final String ending = verb['ending'] as String? ?? '-ARE';

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
                    verb['title'] as String,
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
                    '${verb['english']} • ${verb['bangla']}',
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
            Container(
              height: 18.h,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F7ED),
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Center(
                child: Text(
                  '$ending / ${type == 'irregular' ? 'IRREG' : 'REG'}',
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF69716B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedVerbPreviewSection extends GetView<PracticeHubController> {
  const SavedVerbPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool expanded = controller.showSavedVerbPreview.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: controller.toggleSavedVerbPreview,
                child: Row(
                  children: <Widget>[
                    Text(
                      'Saved Verbs',
                      style: TextStyle(
                        fontSize: 20.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: const Color(0xFF2E3337),
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Container(
                      width: 5.r,
                      height: 5.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF98FF70),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20.r,
                      color: const Color(0xFF394044),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: controller.onViewAllSavedVerbsTap,
                child: Row(
                  children: <Widget>[
                    Text(
                      'VIEW ALL',
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 17.r,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (expanded) ...<Widget>[
            SizedBox(height: 19.h),
            SizedBox(
              height: 164.h,
              child: ListView.separated(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: controller.savedVerbPreviewItems.length,
                separatorBuilder: (_, __) => SizedBox(width: 16.w),
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> verb =
                      controller.savedVerbPreviewItems[index];

                  return SavedVerbMiniCard(
                    title: verb['title'] as String,
                    english: verb['english'] as String,
                    onTap: () => controller.openVerbDetails(verb),
                  );
                },
              ),
            ),
          ],
        ],
      );
    });
  }
}

class SavedVerbMiniCard extends StatelessWidget {
  final String title;
  final String english;
  final VoidCallback onTap;

  const SavedVerbMiniCard({
    super.key,
    required this.title,
    required this.english,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 125.w,
        height: 164.h,
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 14.w, 23.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: const Color(0xFFE5E7E8), width: 1.w),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 17.r,
              offset: Offset(0, 9.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 30.r,
              height: 30.r,
              decoration: const BoxDecoration(
                color: Color(0xFFD8FFC8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: 17.r,
                color: AppColors.primaryGreen,
              ),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 19.sp,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: const Color(0xFF303437),
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              english.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5.sp,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: const Color(0xFF8C9297),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerbFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const VerbFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (BuildContext context, int index) {
          final String filter = filters[index];
          final bool isSelected = filter == selectedFilter;

          return GestureDetector(
            onTap: () => onSelected(filter),
            child: Container(
              width: 100.w,
              height: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.white,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : const Color(0xFFE0E3E5),
                  width: 1.5.w,
                ),
                boxShadow: isSelected
                    ? <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12.r,
                          offset: Offset(0, 7.h),
                        ),
                      ]
                    : const <BoxShadow>[],
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? AppColors.white : AppColors.primaryGreen,
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
  final List<Map<String, dynamic>> verbs;

  const VerbLibraryList({super.key, required this.verbs});

  @override
  Widget build(BuildContext context) {
    if (verbs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 26.h),
        child: Center(
          child: Text(
            'No verbs found',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6F7478),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: verbs.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      separatorBuilder: (_, __) => SizedBox(height: 14.h),
      itemBuilder: (BuildContext context, int index) {
        return VerbLibraryCard(verb: verbs[index]);
      },
    );
  }
}

class VerbLibraryCard extends GetView<PracticeHubController> {
  final Map<String, dynamic> verb;

  const VerbLibraryCard({super.key, required this.verb});

  @override
  Widget build(BuildContext context) {
    final String id = verb['id'] as String;
    final String type = verb['type'] as String;
    final String ending = verb['ending'] as String;

    return GestureDetector(
      onTap: () => controller.openVerbDetails(verb),
      child: Container(
        width: double.infinity,
        height: 134.h,
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
              child: Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        VerbBadge(
                          label: type == 'irregular' ? 'IRREGULAR' : 'REGULAR',
                          dark: type == 'irregular',
                        ),
                        SizedBox(width: 7.w),
                        VerbBadge(label: ending),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      verb['title'] as String,
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
                      '${verb['english']} /',
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
                      verb['bangla'] as String,
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
            ),
            SizedBox(width: 11.w),
            Obx(
              () => CircleVerbActionButton(
                icon: controller.isVerbSaved(id)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                onTap: () => controller.toggleVerbSaved(id),
              ),
            ),
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
  final String label;
  final bool dark;

  const VerbBadge({super.key, required this.label, this.dark = false});

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
  final IconData icon;
  final VoidCallback onTap;

  const CircleVerbActionButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: const BoxDecoration(
          color: Color(0xFFEFF9E9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 21.r, color: AppColors.primaryGreen),
      ),
    );
  }
}
