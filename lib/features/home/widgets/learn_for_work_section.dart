import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/home_models.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/themes/app_constants.dart';

class LearnForWorkSection extends StatelessWidget {
  final List<HomeWorkItemModel> items;
  final VoidCallback? onViewAllTap;

  const LearnForWorkSection({
    super.key,
    required this.items,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Learn For Work',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: AppFont.font20.sp, fontWeight: FontWeight.w800, height: 1.1, color: AppColors.homePrimaryText),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(kHomePillRadius.r),
              onTap: onViewAllTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.homeGreenChip,
                  borderRadius: BorderRadius.circular(
                    kHomePillRadius.r,
                  ),
                ),
                child: Text(
                  'View All',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: AppFont.font12.sp, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: items
                .map(
                  (HomeWorkItemModel item) => Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: _WorkChip(item: item),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _WorkChip extends StatelessWidget {
  final HomeWorkItemModel item;

  const _WorkChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kHomeWorkChipHeight.h,
      padding: EdgeInsets.symmetric(horizontal: 22.w),
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
          Text(item.emoji, style: TextStyle(fontSize: AppFont.font14.sp, fontWeight: FontWeight.w800, color: AppColors.homePrimaryText)),
          SizedBox(width: 6.w),
          Text(item.title, style: TextStyle(fontSize: AppFont.font14.sp, fontWeight: FontWeight.w800, color: AppColors.homePrimaryText)),
        ],
      ),
    );
  }
}
