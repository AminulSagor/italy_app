import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../_widgets/cv_no_template_fields_card.dart';
import '../_widgets/cv_photo_url_upload_field.dart';
import '../controllers/create_cv_dynamic_form_controller.dart';
import '../models/cv_builder_models.dart';

class CreateCvDynamicFormView extends GetView<CreateCvDynamicFormController> {
  const CreateCvDynamicFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 28.h),
                child: Obx(() {
                  final CvTemplateSectionModel? section =
                      controller.currentSectionOrNull;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _Header(),
                      SizedBox(height: 22.h),
                      Text(
                        controller.template.title,
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: AppFont.font11.sp,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      if (section == null)
                        const CvNoTemplateFieldsCard()
                      else ...<Widget>[
                        Text(
                          section.title,
                          style: TextStyle(
                            color: AppColors.homePrimaryText,
                            fontSize: AppFont.font23.sp,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            letterSpacing: -0.7,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Step ${controller.currentStepIndex.value + 1} of ${controller.sections.length}',
                          style: TextStyle(
                            color: AppColors.homeSecondaryText,
                            fontSize: AppFont.font11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: LinearProgressIndicator(
                            minHeight: 7.h,
                            value: controller.progress,
                            backgroundColor: AppColors.white,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        SizedBox(height: 22.h),
                        ...section.fields.map(
                          (CvTemplateFieldModel field) => Padding(
                            padding: EdgeInsets.only(bottom: 14.h),
                            child: _DynamicField(section: section, field: field),
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ),
            ),
            _BottomActions(controller: controller),
          ],
        ),
      ),
    );
  }
}


class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: Get.back,
          child: Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: AppFont.font13.sp,
              color: AppColors.homeDarkGreen,
            ),
          ),
        ),
      ),
    );
  }
}

class _DynamicField extends GetView<CreateCvDynamicFormController> {
  const _DynamicField({required this.section, required this.field});

  final CvTemplateSectionModel section;
  final CvTemplateFieldModel field;

  @override
  Widget build(BuildContext context) {
    final String type = field.type.toLowerCase();
    final TextEditingController? textController = controller.isDynamicItemsField(field)
        ? null
        : controller.controllerFor(
            section,
            field,
          );
    final bool isLongInput = type == 'textarea' || type == 'list';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius20.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  field.label,
                  style: TextStyle(
                    color: AppColors.homePrimaryText,
                    fontSize: AppFont.font12.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (field.required)
                Text(
                  'Required',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: AppFont.font9.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          if (controller.isDynamicItemsField(field))
            _DynamicItemsField(section: section, field: field)
          else if (controller.isPhotoField(field))
            Obx(
              () => CvPhotoUrlUploadField(
                textController: textController!,
                isUploading: controller.isPhotoUploading(section, field),
                onUploadTap: () => controller.pickAndUploadPhoto(section, field),
              ),
            )
          else
            TextField(
              controller: textController,
              keyboardType: _keyboardType(type),
              minLines: isLongInput ? 4 : 1,
              maxLines: isLongInput ? 7 : 1,
              textInputAction: isLongInput
                  ? TextInputAction.newline
                  : TextInputAction.next,
              decoration: InputDecoration(
                hintText: _hintText(field, type),
                filled: true,
                fillColor: AppColors.homeBackground,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 13.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: AppColors.homePrimaryText,
                fontSize: AppFont.font12.sp,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          if (type == 'list') ...<Widget>[
            SizedBox(height: 8.h),
            Text(
              'Write each item on a new line.',
              style: TextStyle(
                color: AppColors.homeSecondaryText,
                fontSize: AppFont.font9.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  TextInputType _keyboardType(String type) {
    switch (type) {
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'website':
      case 'url':
        return TextInputType.url;
      case 'number':
        return TextInputType.number;
      case 'textarea':
      case 'list':
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  String _hintText(CvTemplateFieldModel field, String type) {
    if (field.placeholder != null && field.placeholder!.trim().isNotEmpty) {
      return field.placeholder!;
    }

    if (type == 'photourl' || type == 'imageurl') return 'Select a photo';
    if (type == 'website' || type == 'url') return 'https://example.com';
    if (type == 'list') return 'First item\nSecond item\nThird item';

    return 'Enter ${field.label.toLowerCase()}';
  }
}


class _DynamicItemsField extends GetView<CreateCvDynamicFormController> {
  const _DynamicItemsField({required this.section, required this.field});

  final CvTemplateSectionModel section;
  final CvTemplateFieldModel field;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final List<Map<String, TextEditingController>> items =
            controller.dynamicItemsFor(section, field);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ...items.asMap().entries.map(
              (MapEntry<int, Map<String, TextEditingController>> entry) {
                final int index = entry.key;
                final Map<String, TextEditingController> itemControllers =
                    entry.value;

                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.homeBackground,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.black.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '${field.label} ${index + 1}',
                              style: TextStyle(
                                color: AppColors.homePrimaryText,
                                fontSize: AppFont.font11.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (items.length > 1)
                            GestureDetector(
                              onTap: () => controller.removeDynamicItem(
                                section,
                                field,
                                index,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: AppFont.font17.sp,
                                color: AppColors.homeSecondaryText,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ...field.itemFields.map(
                        (CvTemplateDynamicItemFieldModel itemField) {
                          final bool isLongInput =
                              itemField.type.toLowerCase() == 'textarea';
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: TextField(
                              controller: itemControllers[itemField.key],
                              minLines: isLongInput ? 3 : 1,
                              maxLines: isLongInput ? 6 : 1,
                              textInputAction: isLongInput
                                  ? TextInputAction.newline
                                  : TextInputAction.next,
                              keyboardType: isLongInput
                                  ? TextInputType.multiline
                                  : TextInputType.text,
                              decoration: InputDecoration(
                                labelText: itemField.label,
                                hintText: itemField.placeholder ??
                                    'Enter ${itemField.label.toLowerCase()}',
                                filled: true,
                                fillColor: AppColors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 13.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    kButtonDefaultRadius.r,
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(
                                color: AppColors.homePrimaryText,
                                fontSize: AppFont.font12.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            OutlinedButton.icon(
              onPressed: () => controller.addDynamicItem(section, field),
              icon: Icon(Icons.add_rounded, size: AppFont.font17.sp),
              label: Text('Add ${field.label}'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: BorderSide(color: AppColors.primaryGreen, width: 1.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.controller});

  final CreateCvDynamicFormController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.homeBackground,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Obx(
        () {
          if (!controller.hasFormFields) {
            return OutlinedButton(
              onPressed: controller.goBackStep,
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(48.h),
                side: BorderSide(color: AppColors.primaryGreen, width: 1.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                ),
              ),
              child: Text(
                'Back',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: AppFont.font12.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          }

          return Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.goBackStep,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(48.h),
                    side: BorderSide(color: AppColors.primaryGreen, width: 1.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                    ),
                  ),
                  child: Text(
                    controller.isFirstStep ? 'Back' : 'Previous',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : () => controller.goNextStep(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(48.h),
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor: AppColors.homeSecondaryText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    controller.isSaving.value
                        ? 'Saving...'
                        : controller.isLastStep
                            ? 'Choose Theme'
                            : 'Continue',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: AppFont.font12.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
