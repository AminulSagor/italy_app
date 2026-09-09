import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../helpers/cv_builder_localization.dart';
import '../models/cv_template_model.dart';
import 'cv_template_thumbnail.dart';
import 'cv_template_zoom_dialog.dart';

class CvTemplateCard extends StatelessWidget {
  const CvTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
  });

  final CvTemplateModel template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Future<void> zoom() =>
        CvTemplateZoomDialog.show(context, template: template);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: zoom,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.w),
              child: AspectRatio(
                // Resume previews are A4. Keeping this ratio preserves the
                // backend image exactly while letting it occupy full width.
                aspectRatio: 210 / 297,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CvTemplateThumbnail(
                      template: template,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    if (template.isNew)
                      Positioned(
                        left: 9.w,
                        top: 9.h,
                        child: _Badge(
                          label: 'cvb_badge_new'.tr,
                          icon: Icons.auto_awesome_rounded,
                          background: Color(0xFFE4F5E8),
                          foreground: Color(0xFF176B38),
                        ),
                      ),
                    if (template.isPremium)
                      Positioned(
                        right: 9.w,
                        top: 9.h,
                        child: _Badge(
                          label: 'cvb_badge_pro'.tr,
                          icon: Icons.workspace_premium_rounded,
                          background: Color(0xFFFFF1CF),
                          foreground: Color(0xFF8B5A00),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 2.h, 10.w, 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          template.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.homePrimaryText,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          template.category.isEmpty
                              ? 'cvb_tap_to_use'.tr
                              : 'cvb_category_tap_to_use'.trParams(
                                  <String, String>{
                                    'category': cvCategoryLabel(
                                      template.category,
                                    ),
                                  },
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.homeSecondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: 'cvb_zoom_preview'.tr,
                    child: IconButton.filledTonal(
                      onPressed: zoom,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFEAF4E5),
                        foregroundColor: AppColors.primaryGreen,
                      ),
                      icon: const Icon(Icons.zoom_in_rounded),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primaryGreen,
                    size: 26.w,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12.w, color: foreground),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w900,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
