import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../controllers/important_verbs_controller.dart';
import '../../../models/important_verb_models.dart';

class SavedVerbPreviewSection extends GetView<ImportantVerbsController> {
  const SavedVerbPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool expanded = controller.showSavedVerbPreview.value;
      final List<ImportantVerbSummaryModel> items =
          controller.savedVerbPreviewItems;

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
                      'gen_saved_verbs'.tr,
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
                      'gen_view_all'.tr,
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
            if (controller.isSavedVerbsLoading.value && items.isEmpty)
              SizedBox(
                height: 100.h,
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              SizedBox(
                height: 72.h,
                child: Center(
                  child: Text(
                    'no_saved_verbs_yet'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6F7478),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 164.h,
                child: ListView.separated(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => SizedBox(width: 16.w),
                  itemBuilder: (BuildContext context, int index) {
                    final ImportantVerbSummaryModel verb = items[index];
                    return SavedVerbMiniCard(
                      verb: verb,
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
  const SavedVerbMiniCard({
    super.key,
    required this.verb,
    required this.onTap,
  });

  final ImportantVerbSummaryModel verb;
  final VoidCallback onTap;

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
              verb.infinitive,
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
              verb.englishMeaning.toUpperCase(),
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

