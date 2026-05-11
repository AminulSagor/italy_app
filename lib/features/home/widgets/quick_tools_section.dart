import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/home_models.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/themes/app_constants.dart';

class QuickToolsSection extends StatelessWidget {
  final List<HomeToolModel> tools;

  const QuickToolsSection({super.key, required this.tools});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Quick Tools', style: TextStyle(fontSize: AppFont.font20.sp, fontWeight: FontWeight.w800, height: 1.1, color: AppColors.homePrimaryText)),
        SizedBox(height: 16.h),
        Row(
          children: List<Widget>.generate(tools.length, (int index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == tools.length - 1 ? 0 : 16.w,
                ),
                child: _QuickToolCard(tool: tools[index]),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _QuickToolCard extends StatelessWidget {
  final HomeToolModel tool;

  const _QuickToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: kHomeToolCardHeight.h),
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: _cardColor(tool.tone),
        borderRadius: BorderRadius.circular(kHomeSmallCardRadius.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: kHomeIconCircleSize.w,
            height: kHomeIconCircleSize.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconFor(tool.iconKey),
              color: _iconColor(tool.tone),
              size: kHomeTopIconSize.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(tool.title, style: TextStyle(fontSize: AppFont.font17.sp, fontWeight: FontWeight.w900, height: 1.05, color: AppColors.homePrimaryText)),
          SizedBox(height: 3.h),
          Text(tool.subtitle, style: TextStyle(fontSize: AppFont.font12.sp, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.homeSecondaryText)),
        ],
      ),
    );
  }

  Color _cardColor(HomeToolTone tone) {
    switch (tone) {
      case HomeToolTone.orange:
        return AppColors.homeOrange;
      case HomeToolTone.blue:
        return AppColors.homeBlueCard;
    }
  }

  Color _iconColor(HomeToolTone tone) {
    switch (tone) {
      case HomeToolTone.orange:
        return AppColors.homeBrownIcon;
      case HomeToolTone.blue:
        return AppColors.homeBlueIcon;
    }
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'gavel':
        return Icons.gavel_rounded;
      case 'document':
      default:
        return Icons.description_rounded;
    }
  }
}
