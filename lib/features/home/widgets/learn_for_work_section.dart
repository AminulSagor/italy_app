import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/home_models.dart';
import 'package:get/get.dart';

class LearnForWorkSection extends StatelessWidget {
  const LearnForWorkSection({
    super.key,
    required this.items,
    this.onViewAllTap,
    this.onItemTap,
  });

  final List<HomeWorkItemModel> items;
  final VoidCallback? onViewAllTap;
  final void Function(HomeWorkItemModel item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'learn_for_work'.tr,
                style: TextStyle(
                  fontSize: AppFont.font20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.homePrimaryText,
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
              onTap: onViewAllTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.homeGreenChip,
                  borderRadius: BorderRadius.circular(kHomePillRadius.r),
                ),
                child: Text(
                  'gen_view_all'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        if (items.isEmpty)
          Text(
            'no_career_tracks_are_available_yet'.tr,
            style: TextStyle(
              fontSize: AppFont.font13.sp,
              color: AppColors.homeSecondaryText,
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: items
                  .map(
                    (HomeWorkItemModel item) => Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: _WorkChip(
                        item: item,
                        onTap: () => onItemTap?.call(item),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
      ],
    );
  }
}

class _WorkChip extends StatelessWidget {
  const _WorkChip({required this.item, this.onTap});

  final HomeWorkItemModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kHomePillRadius.r),
      child: Container(
        height: kHomeWorkChipHeight.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(kHomePillRadius.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.homeNeutralShadow,
              blurRadius: 14.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.work_outline_rounded,
              color: AppColors.primaryGreen,
              size: 20,
            ),
            SizedBox(width: 8.w),
            Text(
              item.title,
              style: TextStyle(
                fontSize: AppFont.font14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.homePrimaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
