import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_constants.dart';
import '../../../core/localization/translation_service.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../../../core/widgets/custom_button.dart';
import 'language_switch_controller.dart';

Future<AppLanguage?> showLanguageDialog({
  required BuildContext context,
  AppLanguage initialLanguage = AppLanguage.english,
}) {
  final controllerTag =
      'language_dialog_${DateTime.now().microsecondsSinceEpoch}';

  Get.put(
    LanguageDialogController(initialLanguage: initialLanguage),
    tag: controllerTag,
  );

  return showDialog<AppLanguage>(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return LanguageDialog(controllerTag: controllerTag);
    },
  ).whenComplete(() {
    if (Get.isRegistered<LanguageDialogController>(tag: controllerTag)) {
      Get.delete<LanguageDialogController>(tag: controllerTag);
    }
  });
}

class LanguageDialog extends StatelessWidget {
  final String controllerTag;

  const LanguageDialog({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LanguageDialogController>(tag: controllerTag);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
      backgroundColor: AppColors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(30.w, 34.h, 30.w, 26.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(kLargeBorderRadius.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: AppFont.font24.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: controller.closeDialog,
                  child: Icon(
                    Icons.close,
                    size: 26.r,
                    color: AppColors.legacyColorFF545454,
                  ),
                ),
              ],
            ),

            SizedBox(height: 26.h),

            Obx(
              () => _LanguageOption(
                flag: '🇮🇹',
                title: 'Italian',
                value: AppLanguage.italian,
                isSelected: controller.isSelected(AppLanguage.italian),
                onTap: () => controller.selectLanguage(AppLanguage.italian),
              ),
            ),

            SizedBox(height: kDefaultGap.h),

            Obx(
              () => _LanguageOption(
                flag: '🇬🇧',
                title: 'English',
                value: AppLanguage.english,
                isSelected: controller.isSelected(AppLanguage.english),
                onTap: () => controller.selectLanguage(AppLanguage.english),
              ),
            ),

            SizedBox(height: kDefaultGap.h),

            Obx(
              () => _LanguageOption(
                flag: '🇧🇩',
                title: 'Bengali',
                value: AppLanguage.bengali,
                isSelected: controller.isSelected(AppLanguage.bengali),
                onTap: () => controller.selectLanguage(AppLanguage.bengali),
              ),
            ),

            SizedBox(height: 46.h),

            CustomButton.primary(
              text: 'CONFIRM',
              onPressed: controller.confirmLanguage,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String title;
  final AppLanguage value;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.title,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96.h,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.messageTileActiveBg
              : AppColors.messageTileInactiveBg,
          borderRadius: BorderRadius.circular(kLargeBorderRadius.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.transparent,
            width: 3.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(flag, style: TextStyle(fontSize: AppFont.font32.sp)),
            ),

            SizedBox(width: 18.w),

            Text(
              title,
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.homePrimaryText,
              ),
            ),

            const Spacer(),

            isSelected
                ? Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 22.r,
                      color: AppColors.white,
                    ),
                  )
                : Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.legacyColorFFA2A2A2,
                        width: 3.w,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
