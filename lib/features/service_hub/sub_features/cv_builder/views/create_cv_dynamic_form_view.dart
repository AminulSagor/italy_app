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
                            child: _DynamicField(
                              section: section,
                              field: field,
                            ),
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
    final String type = _normalizeFieldType(field.type);
    final TextEditingController? textController =
        controller.isDynamicItemsField(field)
        ? null
        : controller.controllerFor(section, field);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(kRadius20.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
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
                localPreviewPath: controller.photoPreviewPath(section, field),
                isUploading: controller.isPhotoUploading(section, field),
                onUploadTap: () =>
                    controller.pickAndUploadPhoto(section, field),
              ),
            )
          else if (_isTextareaType(type) || _isListType(type))
            _FormattedTextField(
              controller: textController!,
              field: field,
              type: type,
              initialListStyle: controller.selectedListStyle(section, field),
              onListStyleChanged: (String listStyle) =>
                  controller.setListStyle(section, field, listStyle),
            )
          else
            TextField(
              controller: textController,
              keyboardType: _keyboardType(type),
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(_hintText(field, type), false),
              style: TextStyle(
                color: AppColors.homePrimaryText,
                fontSize: AppFont.font12.sp,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
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
      default:
        return TextInputType.text;
    }
  }
}

class _FormattedTextField extends StatefulWidget {
  const _FormattedTextField({
    required this.controller,
    required this.field,
    required this.type,
    required this.initialListStyle,
    required this.onListStyleChanged,
  });

  final TextEditingController controller;
  final CvTemplateFieldModel field;
  final String type;
  final String initialListStyle;
  final ValueChanged<String> onListStyleChanged;

  @override
  State<_FormattedTextField> createState() => _FormattedTextFieldState();
}

class _FormattedTextFieldState extends State<_FormattedTextField> {
  bool _isBold = false;
  bool _isItalic = false;
  bool _isFormattingList = false;
  double _fontSize = 12;
  TextAlign _textAlign = TextAlign.left;
  late String _listStyle;

  bool get _isList => _isListType(widget.type);

  @override
  void initState() {
    super.initState();
    _listStyle = widget.initialListStyle == 'number' ? 'number' : 'bullet';
    if (_isList && widget.controller.text.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _formatListInput(widget.controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Toolbar(
          isList: _isList,
          isBold: _isBold,
          isItalic: _isItalic,
          fontSize: _fontSize,
          textAlign: _textAlign,
          listStyle: _listStyle,
          onBoldTap: () => setState(() => _isBold = !_isBold),
          onItalicTap: () => setState(() => _isItalic = !_isItalic),
          onFontSizeChanged: (double value) =>
              setState(() => _fontSize = value.clamp(10, 20)),
          onAlignChanged: (TextAlign value) =>
              setState(() => _textAlign = value),
          onListStyleChanged: (String value) {
            setState(
              () => _listStyle = value == 'number' ? 'number' : 'bullet',
            );
            widget.onListStyleChanged(_listStyle);
            _formatListInput(widget.controller.text);
          },
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: widget.controller,
          keyboardType: TextInputType.multiline,
          minLines: _isList ? 5 : 4,
          maxLines: _isList ? 9 : 7,
          textInputAction: TextInputAction.newline,
          textAlign: _isList ? TextAlign.left : _textAlign,
          onChanged: _isList ? _formatListInput : null,
          decoration: _inputDecoration(
            _hintText(widget.field, widget.type),
            true,
          ),
          style: TextStyle(
            color: AppColors.homePrimaryText,
            fontSize: _fontSize.sp,
            fontWeight: _isList
                ? FontWeight.w600
                : _isBold
                ? FontWeight.w800
                : FontWeight.w600,
            fontStyle: _isList
                ? FontStyle.normal
                : _isItalic
                ? FontStyle.italic
                : FontStyle.normal,
            height: 1.35,
          ),
        ),
        if (_isList) ...<Widget>[
          SizedBox(height: 8.h),
          Text(
            _listStyle == 'number'
                ? 'Press Enter to create the next numbered list item.'
                : 'Press Enter to create the next bullet item.',
            style: TextStyle(
              color: AppColors.homeSecondaryText.withOpacity(0.65),
              fontSize: AppFont.font9.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  void _formatListInput(String value) {
    if (_isFormattingList) return;

    final String formattedValue = _formatMarkedListText(value, _listStyle);
    if (formattedValue == value) return;

    _isFormattingList = true;
    widget.controller.value = TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
    _isFormattingList = false;
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.isList,
    required this.isBold,
    required this.isItalic,
    required this.fontSize,
    required this.textAlign,
    required this.listStyle,
    required this.onBoldTap,
    required this.onItalicTap,
    required this.onFontSizeChanged,
    required this.onAlignChanged,
    required this.onListStyleChanged,
  });

  final bool isList;
  final bool isBold;
  final bool isItalic;
  final double fontSize;
  final TextAlign textAlign;
  final String listStyle;
  final VoidCallback onBoldTap;
  final VoidCallback onItalicTap;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<TextAlign> onAlignChanged;
  final ValueChanged<String> onListStyleChanged;

  @override
  Widget build(BuildContext context) {
    if (isList) {
      return Row(
        children: <Widget>[
          Expanded(
            child: _ListStyleButton(
              label: 'Bullet list',
              icon: Icons.format_list_bulleted_rounded,
              isSelected: listStyle == 'bullet',
              onTap: () => onListStyleChanged('bullet'),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _ListStyleButton(
              label: 'Number list',
              icon: Icons.format_list_numbered_rounded,
              isSelected: listStyle == 'number',
              onTap: () => onListStyleChanged('number'),
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: <Widget>[
        _ToolbarButton(
          icon: Icons.format_bold_rounded,
          isSelected: isBold,
          onTap: onBoldTap,
        ),
        _ToolbarButton(
          icon: Icons.format_italic_rounded,
          isSelected: isItalic,
          onTap: onItalicTap,
        ),
        _ToolbarButton(
          icon: Icons.remove_rounded,
          isSelected: false,
          onTap: () => onFontSizeChanged(fontSize - 1),
        ),
        _ToolbarChip(label: fontSize.round().toString()),
        _ToolbarButton(
          icon: Icons.add_rounded,
          isSelected: false,
          onTap: () => onFontSizeChanged(fontSize + 1),
        ),
        _ToolbarButton(
          icon: Icons.format_align_left_rounded,
          isSelected: textAlign == TextAlign.left,
          onTap: () => onAlignChanged(TextAlign.left),
        ),
        _ToolbarButton(
          icon: Icons.format_align_center_rounded,
          isSelected: textAlign == TextAlign.center,
          onTap: () => onAlignChanged(TextAlign.center),
        ),
        _ToolbarButton(
          icon: Icons.format_align_right_rounded,
          isSelected: textAlign == TextAlign.right,
          onTap: () => onAlignChanged(TextAlign.right),
        ),
      ],
    );
  }
}


class _ListStyleButton extends StatelessWidget {
  const _ListStyleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.homePaleGreen : AppColors.homeBackground,
          borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: isSelected ? AppColors.primaryGreen : AppColors.homeSecondaryText,
              size: AppFont.font15.sp,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryGreen : AppColors.homeSecondaryText,
                  fontSize: AppFont.font10.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.homePaleGreen
              : AppColors.homeBackground,
          borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.transparent,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? AppColors.primaryGreen
              : AppColors.homeSecondaryText,
          size: AppFont.font16.sp,
        ),
      ),
    );
  }
}

class _ToolbarChip extends StatelessWidget {
  const _ToolbarChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 32.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.homeBackground,
        borderRadius: BorderRadius.circular(kButtonDefaultRadius.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.homePrimaryText,
          fontSize: AppFont.font11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _formatMarkedListText(String value, String listStyle) {
  if (value.isEmpty) return value;

  final List<String> rawLines = value.replaceAll('\r\n', '\n').split('\n');
  final List<String> formattedLines = <String>[];

  for (int index = 0; index < rawLines.length; index += 1) {
    final String cleanValue = _removeListMarker(rawLines[index]);
    final String marker = listStyle == 'number' ? '${index + 1}. ' : '• ';
    formattedLines.add('$marker$cleanValue');
  }

  return formattedLines.join('\n');
}

String _removeListMarker(String value) {
  return value
      .trimLeft()
      .replaceFirst(RegExp(r'^(?:[•\-*]\s*|\d+[\.)]\s*)'), '')
      .trimRight();
}

class _DynamicItemsField extends GetView<CreateCvDynamicFormController> {
  const _DynamicItemsField({required this.section, required this.field});

  final CvTemplateSectionModel section;
  final CvTemplateFieldModel field;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Map<String, TextEditingController>> items = controller
          .dynamicItemsFor(section, field);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...items.asMap().entries.map((
            MapEntry<int, Map<String, TextEditingController>> entry,
          ) {
            return Container(
              margin: EdgeInsets.only(bottom: 14.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                // color: AppColors.homeBackground,
                borderRadius: BorderRadius.circular(kRadius20.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '${field.label} ${entry.key + 1}',
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
                            entry.key,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.homeSecondaryText,
                            size: AppFont.font17.sp,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  ...field.itemFields.map((
                    CvTemplateDynamicItemFieldModel itemField,
                  ) {
                    final String itemType = _normalizeFieldType(
                      itemField.type,
                    );
                    final bool isLong =
                        _isTextareaType(itemType) || _isListType(itemType);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: TextField(
                        controller: entry.value[itemField.key],
                        minLines: _isListType(itemType) ? 5 : isLong ? 3 : 1,
                        maxLines: _isListType(itemType) ? 9 : isLong ? 5 : 1,
                        keyboardType: isLong
                            ? TextInputType.multiline
                            : TextInputType.text,
                        textInputAction: isLong
                            ? TextInputAction.newline
                            : TextInputAction.next,
                        decoration: _inputDecoration(
                          _stripHtml(itemField.placeholder ?? itemField.label),
                          isLong,
                        ),
                        style: TextStyle(
                          color: AppColors.homePrimaryText,
                          fontSize: AppFont.font12.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
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
    });
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
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Obx(() {
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
      }),
    );
  }
}

InputDecoration _inputDecoration(String hintText, bool isLongInput) {
  return InputDecoration(
    hintText: _stripHtml(hintText),
    hintStyle: TextStyle(
      color: AppColors.homeSecondaryText.withOpacity(0.38),
      fontSize: AppFont.font11.sp,
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: AppColors.homeBackground,
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        isLongInput ? kRadius20.r : kButtonDefaultRadius.r,
      ),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        isLongInput ? kRadius20.r : kButtonDefaultRadius.r,
      ),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        isLongInput ? kRadius20.r : kButtonDefaultRadius.r,
      ),
      borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.w),
    ),
  );
}


String _normalizeFieldType(String value) {
  return value.trim().toLowerCase().replaceAll('-', '_');
}

bool _isTextareaType(String type) {
  final String normalizedType = _normalizeFieldType(type);
  return normalizedType == 'textarea' || normalizedType == 'text_area';
}

bool _isListType(String type) {
  final String normalizedType = _normalizeFieldType(type).replaceAll('_', '');
  return normalizedType == 'list' ||
      normalizedType == 'bulletlist' ||
      normalizedType == 'numberlist' ||
      normalizedType == 'orderedlist' ||
      normalizedType == 'unorderedlist';
}

String _hintText(CvTemplateFieldModel field, String type) {
  if (field.placeholder != null && field.placeholder!.trim().isNotEmpty) {
    return _stripHtml(field.placeholder!);
  }

  if (type == 'photourl' || type == 'imageurl' || type == 'photo_url') return 'Select a photo';
  if (type == 'website' || type == 'url') return 'https://example.com';
  if (_isListType(type)) return 'First item\nSecond item\nThird item';

  return 'Enter ${field.label.toLowerCase()}';
}

String _stripHtml(String value) {
  return value
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .trim();
}
