import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../../../core/themes/app_font.dart';
import '../models/home_models.dart';

class QuickToolsSection extends StatelessWidget {
  const QuickToolsSection({super.key, required this.tools, this.onToolTap});

  final List<HomeToolModel> tools;
  final ValueChanged<HomeToolModel>? onToolTap;

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) {
      return const SizedBox.shrink();
    }

    final int columnCount = tools.length == 1 ? 1 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'quick_tools'.tr,
          style: TextStyle(
            fontSize: AppFont.font20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.homePrimaryText,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tools.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 14.w,
            mainAxisSpacing: 14.h,
            mainAxisExtent: 130.h,
          ),
          itemBuilder: (BuildContext context, int index) {
            final HomeToolModel tool = tools[index];

            return _QuickToolCard(
              tool: tool,
              onTap: () => onToolTap?.call(tool),
            );
          },
        ),
      ],
    );
  }
}

class _QuickToolCard extends StatelessWidget {
  const _QuickToolCard({required this.tool, this.onTap});

  final HomeToolModel tool;
  final VoidCallback? onTap;

  bool get _isGuideVideo => tool.type == HomeToolType.guideVideo;

  Color get _backgroundColor {
    if (_isGuideVideo) {
      return const Color(0xFFFF9800);
    }

    return AppColors.homeBlueCard;
  }

  Color get _iconColor {
    if (_isGuideVideo) {
      return const Color(0xFF8A4A00);
    }

    return AppColors.homeBlueIcon;
  }

  Color get _subtitleColor {
    if (_isGuideVideo) {
      return const Color(0xFF5F3200);
    }

    return AppColors.homeSecondaryText;
  }

  IconData get _icon {
    if (_isGuideVideo) {
      return Icons.play_arrow_rounded;
    }

    return Icons.description_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(
      kHomeSmallCardRadius.r,
    );

    return Semantics(
      button: true,
      label: tool.title,
      child: Material(
        color: _backgroundColor,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.r,
              vertical: 10.r,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, size: 22.r, color: _iconColor),
                ),
                SizedBox(height: 14.h),
                Text(
                  tool.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  tool.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: _subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
