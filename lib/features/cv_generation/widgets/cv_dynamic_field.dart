import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/services/api_error_handler.dart';
import '../../../core/themes/app_colors.dart';
import '../controllers/cv_builder_controller.dart';
import '../helpers/cv_builder_localization.dart';
import '../models/cv_template_model.dart';
import 'cv_keyboard_aware_field.dart';

class CvDynamicField extends StatelessWidget {
  const CvDynamicField({
    super.key,
    required this.controller,
    required this.section,
    required this.field,
    this.itemIndex,
  });

  final CvBuilderController controller;
  final CvSectionDefinition section;
  final CvFieldDefinition field;
  final int? itemIndex;

  @override
  Widget build(BuildContext context) {
    final dynamic value = controller.fieldValue(
      section,
      field,
      itemIndex: itemIndex,
    );

    final Widget input = _buildInput(value);
    if (!field.supportsAi) return input;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        input,
        _AiSuggestionPanel(
          suggestions: controller.aiSuggestionsFor(
            section,
            field,
            itemIndex: itemIndex,
          ),
          loading: controller.isAiSuggestionLoading(
            section,
            field,
            itemIndex: itemIndex,
          ),
          addMode:
              field.type == CvFieldType.tags ||
              field.type == CvFieldType.repeatable,
          onRefresh: () => _refreshAiSuggestions(),
          onInclude: (String suggestion) => controller.includeAiSuggestion(
            section,
            field,
            suggestion,
            itemIndex: itemIndex,
          ),
          onIncludeEdited: (String source, String edited) =>
              controller.includeAiSuggestion(
                section,
                field,
                edited,
                itemIndex: itemIndex,
                sourceSuggestion: source,
              ),
        ),
      ],
    );
  }

  Widget _buildInput(dynamic value) {
    final String label = cvFieldLabel(field);
    switch (field.type) {
      case CvFieldType.boolean:
        return _BooleanField(
          label: label,
          value: value == true,
          onChanged: (bool next) => controller.setFieldValue(
            section,
            field,
            next,
            itemIndex: itemIndex,
          ),
        );

      case CvFieldType.select:
        return _SelectField(
          label: label,
          requiredField: field.required,
          value: value?.toString(),
          options: field.options,
          onChanged: (String? next) => controller.setFieldValue(
            section,
            field,
            next,
            itemIndex: itemIndex,
          ),
        );

      case CvFieldType.date:
        return _DateField(
          label: label,
          requiredField: field.required,
          value: value?.toString(),
          onChanged: (String next) => controller.setFieldValue(
            section,
            field,
            next,
            itemIndex: itemIndex,
          ),
        );

      case CvFieldType.tags:
      case CvFieldType.repeatable:
        return _StringListField(
          label: label,
          showLabel: !_hasRedundantSectionLabel,
          requiredField: field.required,
          values: value is List
              ? value.map((dynamic item) => item.toString()).toList()
              : const <String>[],
          maxItems: field.maxItems,
          maxLength: field.maxLength,
          compactChips: field.type == CvFieldType.tags,
          onChanged: (List<String> next) => controller.setStringListField(
            section,
            field,
            next,
            itemIndex: itemIndex,
          ),
        );

      case CvFieldType.image:
        return _PhotoField(
          controller: controller,
          section: section,
          field: field,
          hasPhoto: value?.toString().trim().isNotEmpty == true,
        );

      case CvFieldType.textarea:
        return _TextField(
          label: label,
          requiredField: field.required,
          value: value?.toString() ?? '',
          maxLength: field.maxLength,
          maxLines: 5,
          minLines: 3,
          onChanged: (String next) => controller.setFieldValue(
            section,
            field,
            next,
            itemIndex: itemIndex,
          ),
        );

      case CvFieldType.email:
        return _TextField(
          label: label,
          requiredField: field.required,
          value: value?.toString() ?? '',
          maxLength: field.maxLength,
          keyboardType: TextInputType.emailAddress,
          onChanged: (String next) => controller.setFieldValue(
            section,
            field,
            next,
            itemIndex: itemIndex,
          ),
        );

      case CvFieldType.phone:
        return _TextField(
          label: label,
          requiredField: field.required,
          value: value?.toString() ?? '',
          maxLength: field.maxLength,
          keyboardType: TextInputType.phone,
          onChanged: (String next) => controller.setFieldValue(
            section,
            field,
            next,
            itemIndex: itemIndex,
          ),
        );

      case CvFieldType.url:
        return _TextField(
          label: label,
          requiredField: field.required,
          value: value?.toString() ?? '',
          maxLength: field.maxLength,
          keyboardType: TextInputType.url,
          onChanged: (String next) => controller.setFieldValue(
            section,
            field,
            next,
            itemIndex: itemIndex,
          ),
        );

      case CvFieldType.text:
        return _TextField(
          label: label,
          requiredField: field.required,
          value: value?.toString() ?? '',
          maxLength: field.maxLength,
          onChanged: (String next) => controller.setFieldValue(
            section,
            field,
            next,
            itemIndex: itemIndex,
          ),
        );
    }
  }

  bool get _hasRedundantSectionLabel {
    if (itemIndex != null || section.visibleFields.length != 1) return false;

    String normalize(String value) =>
        value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    final String sectionLabel = normalize(cvSectionLabel(section));
    return sectionLabel.isNotEmpty &&
        sectionLabel == normalize(cvFieldLabel(field));
  }

  Future<void> _refreshAiSuggestions() async {
    try {
      await controller.requestAiSuggestions(
        section,
        field,
        itemIndex: itemIndex,
        force: true,
      );
    } catch (error) {
      Get.snackbar(
        'cvb_ai_unavailable'.tr,
        ApiErrorHandler.getErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _AiSuggestionPanel extends StatelessWidget {
  const _AiSuggestionPanel({
    required this.suggestions,
    required this.loading,
    required this.addMode,
    required this.onRefresh,
    required this.onInclude,
    required this.onIncludeEdited,
  });

  final List<String> suggestions;
  final bool loading;
  final bool addMode;
  final VoidCallback onRefresh;
  final ValueChanged<String> onInclude;
  final void Function(String source, String edited) onIncludeEdited;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8F4),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD8E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F2E6),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 16.w,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'cvb_ai_suggestions'.tr,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.homePrimaryText,
                      ),
                    ),
                    Text(
                      'cvb_ai_control_message'.tr,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: AppColors.homeSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: loading ? null : onRefresh,
                icon: loading
                    ? SizedBox(
                        width: 13.w,
                        height: 13.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.refresh_rounded, size: 15.w),
                label: Text('cvb_ai_refresh'.tr),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          if (suggestions.isNotEmpty) ...<Widget>[
            SizedBox(height: 8.h),
            ...suggestions.map(
              (String suggestion) => _EditableAiSuggestionCard(
                key: ValueKey<String>(suggestion),
                suggestion: suggestion,
                addMode: addMode,
                onInclude: (String edited) {
                  if (edited == suggestion) {
                    onInclude(suggestion);
                    return;
                  }
                  onIncludeEdited(suggestion, edited);
                },
              ),
            ),
          ] else if (!loading) ...<Widget>[
            SizedBox(height: 6.h),
            Text(
              'cvb_ai_empty'.tr,
              style: TextStyle(
                fontSize: 10.5.sp,
                height: 1.35,
                color: AppColors.homeSecondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EditableAiSuggestionCard extends StatefulWidget {
  const _EditableAiSuggestionCard({
    super.key,
    required this.suggestion,
    required this.addMode,
    required this.onInclude,
  });

  final String suggestion;
  final bool addMode;
  final ValueChanged<String> onInclude;

  @override
  State<_EditableAiSuggestionCard> createState() =>
      _EditableAiSuggestionCardState();
}

class _EditableAiSuggestionCardState extends State<_EditableAiSuggestionCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.suggestion);
  }

  @override
  void didUpdateWidget(covariant _EditableAiSuggestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.suggestion != oldWidget.suggestion &&
        _controller.text == oldWidget.suggestion) {
      _controller.text = widget.suggestion;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 7.h),
      padding: EdgeInsets.fromLTRB(11.w, 8.h, 5.w, 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFDDE6E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CvKeyboardAwareField(
            builder: (BuildContext context, FocusNode focusNode) => TextField(
              focusNode: focusNode,
              controller: _controller,
              minLines: 1,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.35,
                color: AppColors.homePrimaryText,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                final String edited = _controller.text.trim();
                if (edited.isNotEmpty) widget.onInclude(edited);
              },
              icon: Icon(
                widget.addMode ? Icons.add_rounded : Icons.check_rounded,
                size: 15.w,
              ),
              label: Text(widget.addMode ? 'cvb_add'.tr : 'cvb_use'.tr),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _TextField extends StatefulWidget {
  const _TextField({
    required this.label,
    required this.requiredField,
    required this.value,
    required this.onChanged,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
  });

  final String label;
  final bool requiredField;
  final String value;
  final ValueChanged<String> onChanged;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _TextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FieldLabel(widget.label, widget.requiredField),
          SizedBox(height: 7.h),
          CvKeyboardAwareField(
            builder: (BuildContext context, FocusNode focusNode) => TextField(
              focusNode: focusNode,
              controller: _controller,
              onChanged: widget.onChanged,
              keyboardType: widget.keyboardType,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              textInputAction: widget.maxLines > 1
                  ? TextInputAction.newline
                  : TextInputAction.next,
              inputFormatters: widget.maxLength == null
                  ? null
                  : <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(widget.maxLength),
                    ],
              decoration: _inputDecoration(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SelectField extends StatefulWidget {
  const _SelectField({
    required this.label,
    required this.requiredField,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final bool requiredField;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  State<_SelectField> createState() => _SelectFieldState();
}

class _SelectFieldState extends State<_SelectField> {
  String? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.options.contains(widget.value) ? widget.value : null;
  }

  @override
  void didUpdateWidget(covariant _SelectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _value = widget.options.contains(widget.value) ? widget.value : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FieldLabel(widget.label, widget.requiredField),
          SizedBox(height: 7.h),
          DropdownButtonFormField<String>(
            value: _value,
            isExpanded: true,
            items: widget.options
                .map(
                  (String option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(cvOptionLabel(option)),
                  ),
                )
                .toList(),
            onChanged: (String? next) {
              setState(() => _value = next);
              widget.onChanged(next);
            },
            decoration: _inputDecoration(),
          ),
        ],
      ),
    );
  }
}

class _BooleanField extends StatefulWidget {
  const _BooleanField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_BooleanField> createState() => _BooleanFieldState();
}

class _BooleanFieldState extends State<_BooleanField> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant _BooleanField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: SwitchListTile.adaptive(
        value: _value,
        title: Text(widget.label),
        activeColor: AppColors.primaryGreen,
        onChanged: (bool next) {
          setState(() => _value = next);
          widget.onChanged(next);
        },
      ),
    );
  }
}

class _DateField extends StatefulWidget {
  const _DateField({
    required this.label,
    required this.requiredField,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool requiredField;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FieldLabel(widget.label, widget.requiredField),
          SizedBox(height: 7.h),
          TextField(
            controller: _controller,
            readOnly: true,
            onTap: () async {
              final DateTime now = DateTime.now();
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _parseDate(_controller.text) ?? now,
                firstDate: DateTime(1950),
                lastDate: DateTime(now.year + 20),
              );
              if (picked == null) return;
              final String value =
                  '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}';
              _controller.text = value;
              widget.onChanged(value);
            },
            decoration: _inputDecoration().copyWith(
              suffixIcon: const Icon(Icons.calendar_month_outlined),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseDate(String value) {
    final RegExpMatch? match = RegExp(
      r'^(\d{4})-(\d{2})$',
    ).firstMatch(value.trim());
    if (match == null) return null;

    final int? year = int.tryParse(match.group(1) ?? '');
    final int? month = int.tryParse(match.group(2) ?? '');
    if (year == null || month == null || month < 1 || month > 12) return null;
    return DateTime(year, month);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _StringListField extends StatefulWidget {
  const _StringListField({
    required this.label,
    required this.showLabel,
    required this.requiredField,
    required this.values,
    required this.maxItems,
    required this.maxLength,
    required this.compactChips,
    required this.onChanged,
  });

  final String label;
  final bool showLabel;
  final bool requiredField;
  final List<String> values;
  final int? maxItems;
  final int? maxLength;
  final bool compactChips;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_StringListField> createState() => _StringListFieldState();
}

class _StringListFieldState extends State<_StringListField> {
  late List<String> _items;
  final TextEditingController _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List<String>.from(widget.values);
  }

  @override
  void didUpdateWidget(covariant _StringListField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameStrings(widget.values, _items)) {
      _items = List<String>.from(widget.values);
    }
  }

  void _add() {
    final String value = _input.text.trim();
    if (value.isEmpty) return;
    if (_items.length >= (widget.maxItems ?? 50)) return;
    if (_items.contains(value)) {
      _input.clear();
      return;
    }

    setState(() {
      _items.add(value);
      _input.clear();
    });
    widget.onChanged(List<String>.from(_items));
  }

  void _remove(int index) {
    setState(() => _items.removeAt(index));
    widget.onChanged(List<String>.from(_items));
  }

  Future<void> _edit(BuildContext context, int index) async {
    if (index < 0 || index >= _items.length) return;
    final String? edited = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => _EditStringItemDialog(
        initialValue: _items[index],
        maxLength: widget.maxLength,
        singleLine: widget.compactChips,
      ),
    );

    if (!mounted || edited == null || edited == _items[index]) return;
    final bool duplicate = _items.asMap().entries.any(
      (MapEntry<int, String> item) =>
          item.key != index && item.value.toLowerCase() == edited.toLowerCase(),
    );
    if (duplicate) return;

    setState(() => _items[index] = edited);
    widget.onChanged(List<String>.from(_items));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.showLabel) _FieldLabel(widget.label, widget.requiredField),
          if (_items.isNotEmpty) ...<Widget>[
            if (widget.showLabel) SizedBox(height: 8.h),
            if (widget.compactChips)
              Wrap(
                spacing: 7.w,
                runSpacing: 7.h,
                children: List<Widget>.generate(
                  _items.length,
                  (int index) => InputChip(
                    label: Text(_items[index]),
                    avatar: const Icon(Icons.edit_outlined, size: 16),
                    onPressed: () => _edit(context, index),
                    onDeleted: () => _remove(index),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              )
            else
              Column(
                children: List<Widget>.generate(
                  _items.length,
                  (int index) => Container(
                    margin: EdgeInsets.only(bottom: 6.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F6),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text(_items[index])),
                        IconButton(
                          onPressed: () => _edit(context, index),
                          icon: const Icon(Icons.edit_outlined),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'cvb_edit'.tr,
                        ),
                        IconButton(
                          onPressed: () => _remove(index),
                          icon: const Icon(Icons.close_rounded),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          if (widget.showLabel || _items.isNotEmpty) SizedBox(height: 8.h),
          Row(
            children: <Widget>[
              Expanded(
                child: CvKeyboardAwareField(
                  builder: (BuildContext context, FocusNode focusNode) =>
                      TextField(
                        focusNode: focusNode,
                        controller: _input,
                        maxLength: widget.maxLength,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _add(),
                        decoration: _inputDecoration().copyWith(
                          hintText: widget.compactChips
                              ? 'cvb_type_and_add'.tr
                              : 'cvb_add_item'.tr,
                        ),
                      ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton.filled(
                onPressed: _items.length >= (widget.maxItems ?? 50)
                    ? null
                    : _add,
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }
}

bool _sameStrings(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (int index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

class _EditStringItemDialog extends StatefulWidget {
  const _EditStringItemDialog({
    required this.initialValue,
    required this.maxLength,
    required this.singleLine,
  });

  final String initialValue;
  final int? maxLength;
  final bool singleLine;

  @override
  State<_EditStringItemDialog> createState() => _EditStringItemDialogState();
}

class _EditStringItemDialogState extends State<_EditStringItemDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('cvb_edit_item'.tr),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        minLines: widget.singleLine ? 1 : 2,
        maxLines: widget.singleLine ? 1 : 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: _inputDecoration(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cvb_cancel'.tr),
        ),
        FilledButton(
          onPressed: () {
            final String value = _controller.text.trim();
            if (value.isNotEmpty) Navigator.of(context).pop(value);
          },
          child: Text('cvb_save'.tr),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _PhotoField extends StatelessWidget {
  const _PhotoField({
    required this.controller,
    required this.section,
    required this.field,
    required this.hasPhoto,
  });

  final CvBuilderController controller;
  final CvSectionDefinition section;
  final CvFieldDefinition field;
  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9F8),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE1E7E3)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 44.r,
              height: 44.r,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF6F1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasPhoto ? Icons.check_rounded : Icons.person_outline_rounded,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _FieldLabel(cvFieldLabel(field), field.required),
                  SizedBox(height: 3.h),
                  Text(
                    controller.localPhotoName.value.isNotEmpty
                        ? controller.localPhotoName.value
                        : hasPhoto
                        ? 'cvb_photo_uploaded'.tr
                        : 'cvb_photo_formats'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: AppColors.homeSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: controller.isUploadingPhoto.value
                  ? null
                  : () => controller.pickAndUploadPhoto(section, field),
              child: controller.isUploadingPhoto.value
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(hasPhoto ? 'cvb_replace'.tr : 'cvb_choose'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label, this.requiredField);

  final String label;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        children: <InlineSpan>[
          if (requiredField)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.redAccent),
            ),
        ],
      ),
      style: TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.homePrimaryText,
      ),
    );
  }
}

InputDecoration _inputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    counterText: '',
    contentPadding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 12.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: const BorderSide(color: Color(0xFFDCE3DF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: const BorderSide(color: Color(0xFFDCE3DF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.4),
    ),
  );
}
