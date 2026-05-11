import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_theme.dart';
import '../models/home_models.dart';

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
              child: Text('Learn For Work', style: AppTheme.homeSectionTitleStyle),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(AppTheme.homePillRadius.r),
              onTap: onViewAllTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppTheme.homeGreenChip,
                  borderRadius: BorderRadius.circular(AppTheme.homePillRadius.r),
                ),
                child: Text('View All', style: AppTheme.homeActionChipStyle),
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
      height: AppTheme.homeWorkChipHeight.h,
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.homePillRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.homeNeutralShadow,
            blurRadius: 14.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(item.emoji, style: AppTheme.homeWorkChipStyle),
          SizedBox(width: 6.w),
          Text(item.title, style: AppTheme.homeWorkChipStyle),
        ],
      ),
    );
  }
}
