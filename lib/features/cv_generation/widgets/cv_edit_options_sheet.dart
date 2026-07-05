import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../core/themes/app_colors.dart';

enum CvEditOption {
  factsOnly,
  designAndFacts,
  designOnly,
}

class CvEditOptionsSheet extends StatefulWidget {
  const CvEditOptionsSheet({
    super.key,
  });

  @override
  State<CvEditOptionsSheet> createState() =>
      _CvEditOptionsSheetState();
}

class _CvEditOptionsSheetState
    extends State<CvEditOptionsSheet> {
  CvEditOption? _selectedOption;
  bool _isProcessing = false;

  Future<void> _selectOption(
      CvEditOption option,
      ) async {
    if (_isProcessing) {
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      _selectedOption = option;
      _isProcessing = true;
    });

    // Give the user enough time to see the selected state.
    await Future<void>.delayed(
      const Duration(milliseconds: 400),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(option);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          18.w,
          12.h,
          18.w,
          24.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 42.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD9DDD8),
                borderRadius:
                BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'cv_edit_options_title'.tr,
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.homePrimaryText,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'cv_edit_options_subtitle'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color:
                AppColors.homeSecondaryText,
              ),
            ),
            SizedBox(height: 20.h),

            _EditOptionTile(
              icon: Icons.edit_note_rounded,
              title:
              'cv_edit_options_information_title'.tr,
              description:
              'cv_edit_options_information_description'.tr,
              isSelected:
              _selectedOption ==
                  CvEditOption.factsOnly,
              isDisabled: _isProcessing,
              onTap: () {
                _selectOption(
                  CvEditOption.factsOnly,
                );
              },
            ),

            SizedBox(height: 10.h),

            _EditOptionTile(
              icon:
              Icons.auto_fix_high_rounded,
              title:
              'cv_edit_options_information_design_title'.tr,
              description:
              'cv_edit_options_information_design_description'.tr,
              isSelected:
              _selectedOption ==
                  CvEditOption
                      .designAndFacts,
              isDisabled: _isProcessing,
              onTap: () {
                _selectOption(
                  CvEditOption
                      .designAndFacts,
                );
              },
            ),

            SizedBox(height: 10.h),

            _EditOptionTile(
              icon: Icons.palette_outlined,
              title:
              'cv_edit_options_design_only_title'.tr,
              description:
              'cv_edit_options_design_only_description'.tr,
              isSelected:
              _selectedOption ==
                  CvEditOption.designOnly,
              isDisabled: _isProcessing,
              onTap: () {
                _selectOption(
                  CvEditOption.designOnly,
                );
              },
            ),

            SizedBox(height: 14.h),

            Text(
              'cv_edit_options_version_notice'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.4,
                color:
                AppColors.homeSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditOptionTile
    extends StatelessWidget {
  const _EditOptionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration:
      const Duration(milliseconds: 180),
      opacity:
      isDisabled && !isSelected
          ? 0.55
          : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius:
        BorderRadius.circular(18.r),
        child: InkWell(
          onTap:
          isDisabled ? null : onTap,
          borderRadius:
          BorderRadius.circular(18.r),
          child: AnimatedContainer(
            duration:
            const Duration(
              milliseconds: 220,
            ),
            curve: Curves.easeOut,
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFEAF7E4)
                  : AppColors.homeBackground,
              borderRadius:
              BorderRadius.circular(18.r),
              border: Border.all(
                width:
                isSelected ? 1.5 : 1,
                color: isSelected
                    ? AppColors.primaryGreen
                    : Colors.transparent,
              ),
              boxShadow: isSelected
                  ? <BoxShadow>[
                BoxShadow(
                  color: AppColors
                      .primaryGreen
                      .withValues(
                    alpha: 0.12,
                  ),
                  blurRadius: 12,
                  offset:
                  const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 220,
                  ),
                  width: 44.w,
                  height: 44.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : const Color(
                      0xFFEAF7E4,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      14.r,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 23.w,
                    color: isSelected
                        ? Colors.white
                        : AppColors.primaryGreen,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight:
                          FontWeight.w900,
                          color: AppColors
                              .homePrimaryText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          height: 1.4,
                          color: AppColors
                              .homeSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: isSelected
                      ? const CircularProgressIndicator(
                    strokeWidth: 2.2,
                  )
                      : Icon(
                    Icons
                        .arrow_forward_ios_rounded,
                    size: 16.w,
                    color: AppColors
                        .primaryGreen,
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