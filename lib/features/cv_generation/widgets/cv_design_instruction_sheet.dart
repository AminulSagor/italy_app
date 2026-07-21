import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../core/themes/app_colors.dart';

class CvDesignInstructionSheet extends StatefulWidget {
  const CvDesignInstructionSheet({
    super.key,
  });

  @override
  State<CvDesignInstructionSheet> createState() =>
      _CvDesignInstructionSheetState();
}

class _CvDesignInstructionSheetState
    extends State<CvDesignInstructionSheet> {
  final TextEditingController _controller =
  TextEditingController();

  String? _errorMessage;

  static const List<String> _examples = <String>[
    'cv_design_example_dark_blue',
    'cv_design_example_minimal',
    'cv_design_example_two_column',
  ];

  void _submit() {
    final String instruction = _controller.text.trim();

    if (instruction.isEmpty) {
      setState(() {
        _errorMessage = 'cv_design_empty_error'.tr;
      });
      return;
    }

    Navigator.of(context).pop(instruction);
  }

  void _applyExample(
      String example,
      ) {
    _controller.text = example;
    _controller.selection = TextSelection.collapsed(
      offset: example.length,
    );

    setState(() {
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardInset =
        MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: keyboardInset,
        ),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  child: Container(
                    width: 42.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9DDD8),
                      borderRadius:
                      BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'cv_design_title'.tr,
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'cv_design_description'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.45,
                    color: AppColors.homeSecondaryText,
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  minLines: 4,
                  maxLines: 7,
                  textCapitalization:
                  TextCapitalization.sentences,
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'cv_design_hint'.tr,
                    errorText: _errorMessage,
                    filled: true,
                    fillColor: AppColors.homeBackground,
                    contentPadding: EdgeInsets.all(15.w),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(16.r),
                      borderSide: const BorderSide(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'cv_design_examples'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 7.w,
                  runSpacing: 7.h,
                  children: _examples.map(
                        (String example) {
                      return ActionChip(
                        label: Text(
                          example.tr,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                          ),
                        ),
                        onPressed: () {
                          _applyExample(example);
                        },
                        backgroundColor:
                        const Color(0xFFEAF7E4),
                        side: BorderSide.none,
                      );
                    },
                  ).toList(),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(
                      Icons.auto_fix_high_rounded,
                    ),
                    label:  Text(
                      'cv_design_generate'.tr,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15.r),
                      ),
                    ),
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