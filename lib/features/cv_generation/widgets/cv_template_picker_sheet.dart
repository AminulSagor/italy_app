import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_template_model.dart';
import 'cv_template_thumbnail.dart';

class CvTemplatePickerSheet extends StatelessWidget {
  const CvTemplatePickerSheet({
    super.key,
    required this.templates,
    required this.selectedTemplateId,
    required this.onSelected,
  });

  final List<CvTemplateModel> templates;
  final String? selectedTemplateId;
  final ValueChanged<CvTemplateModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (BuildContext context, ScrollController scrollController) {
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            child: Column(
              children: <Widget>[
                SizedBox(height: 9.h),
                Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9DEDB),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 10.h),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'cvb_choose_template'.tr,
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.homePrimaryText,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: templates.isEmpty
                      ? Center(child: Text('cvb_no_templates_available'.tr))
                      : GridView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 24.h),
                          itemCount: templates.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10.w,
                                mainAxisSpacing: 10.h,
                                childAspectRatio: 0.78,
                              ),
                          itemBuilder: (BuildContext context, int index) {
                            final CvTemplateModel template = templates[index];
                            final bool selected =
                                template.id == selectedTemplateId;

                            return Material(
                              color: selected
                                  ? const Color(0xFFEAF6F1)
                                  : const Color(0xFFF7F9F8),
                              borderRadius: BorderRadius.circular(15.r),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15.r),
                                onTap: () => onSelected(template),
                                child: Padding(
                                  padding: EdgeInsets.all(8.w),
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: CvTemplateThumbnail(
                                          template: template,
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              template.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12.5.sp,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          if (selected)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.primaryGreen,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
