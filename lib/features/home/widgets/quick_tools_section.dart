import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_theme.dart';
import '../models/home_models.dart';

class QuickToolsSection extends StatelessWidget {
  final List<HomeToolModel> tools;

  const QuickToolsSection({super.key, required this.tools});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Quick Tools', style: AppTheme.homeSectionTitleStyle),
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
      constraints: BoxConstraints(minHeight: AppTheme.homeToolCardHeight.h),
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: _cardColor(tool.tone),
        borderRadius: BorderRadius.circular(AppTheme.homeSmallCardRadius.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: AppTheme.homeIconCircleSize.w,
            height: AppTheme.homeIconCircleSize.w,
            decoration: const BoxDecoration(
              color: AppTheme.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconFor(tool.iconKey),
              color: _iconColor(tool.tone),
              size: AppTheme.homeTopIconSize.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(tool.title, style: AppTheme.homeToolTitleStyle),
          SizedBox(height: 3.h),
          Text(tool.subtitle, style: AppTheme.homeToolSubtitleStyle),
        ],
      ),
    );
  }

  Color _cardColor(HomeToolTone tone) {
    switch (tone) {
      case HomeToolTone.orange:
        return AppTheme.homeOrange;
      case HomeToolTone.blue:
        return AppTheme.homeBlueCard;
    }
  }

  Color _iconColor(HomeToolTone tone) {
    switch (tone) {
      case HomeToolTone.orange:
        return AppTheme.homeBrownIcon;
      case HomeToolTone.blue:
        return AppTheme.homeBlueIcon;
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
