import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_template_model.dart';

class CvTemplateCard extends StatelessWidget {
  const CvTemplateCard({
    required this.template,
    required this.onTap,
    required this.isLoading,
    super.key,
  });

  final CvTemplateModel template;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(9.w),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(14.r),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF0F1F1),
                    child: Image.network(
                      template.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? progress,
                          ) {
                        if (progress == null) {
                          return child;
                        }

                        return const Center(
                          child:
                          CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                          ) {
                        return const Center(
                          child: Icon(
                            Icons
                                .broken_image_outlined,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                template.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color:
                  AppColors.homePrimaryText,
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: <Widget>[
                  if (isLoading)
                    SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child:
                      const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(
                      Icons
                          .auto_awesome_outlined,
                      size: 14.w,
                      color:
                      AppColors.primaryGreen,
                    ),
                  SizedBox(width: 5.w),
                  Text(
                    isLoading
                        ? 'Opening...'
                        : 'Use this template',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color:
                      AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}