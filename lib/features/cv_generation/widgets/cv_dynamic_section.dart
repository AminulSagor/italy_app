import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../controllers/cv_builder_controller.dart';
import '../helpers/cv_builder_localization.dart';
import '../models/cv_template_model.dart';
import 'cv_dynamic_field.dart';

class CvDynamicSection extends StatelessWidget {
  const CvDynamicSection({
    super.key,
    required this.controller,
    required this.section,
  });

  final CvBuilderController controller;
  final CvSectionDefinition section;

  @override
  Widget build(BuildContext context) {
    if (section.isCollectionSection) {
      return _CollectionSection(controller: controller, section: section);
    }

    return _SectionCard(
      title: cvSectionLabel(section),
      requiredSection: section.required,
      child: Column(
        children: section.visibleFields
            .map(
              (CvFieldDefinition field) => CvDynamicField(
                key: ValueKey<String>('${section.key}-${field.key}'),
                controller: controller,
                section: section,
                field: field,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CollectionSection extends StatelessWidget {
  const _CollectionSection({required this.controller, required this.section});

  final CvBuilderController controller;
  final CvSectionDefinition section;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = controller.collectionItems(
      section.key,
    );
    final int maxItems = section.maxItems ?? 50;

    return _SectionCard(
      title: cvSectionLabel(section),
      requiredSection: section.required,
      trailing: TextButton.icon(
        onPressed: items.length >= maxItems
            ? null
            : () => controller.addCollectionItem(section),
        icon: const Icon(Icons.add_rounded),
        label: Text('cvb_add'.tr),
      ),
      child: items.isEmpty
          ? _EmptyCollection(
              label: cvSectionLabel(section),
              onAdd: () => controller.addCollectionItem(section),
            )
          : Column(
              children: List<Widget>.generate(
                items.length,
                (int index) => _CollectionEntry(
                  key: ValueKey<String>(
                    '${section.key}-${items[index]['id'] ?? index}',
                  ),
                  controller: controller,
                  section: section,
                  itemIndex: index,
                  itemNumber: index + 1,
                ),
              ),
            ),
    );
  }
}

class _CollectionEntry extends StatelessWidget {
  const _CollectionEntry({
    super.key,
    required this.controller,
    required this.section,
    required this.itemIndex,
    required this.itemNumber,
  });

  final CvBuilderController controller;
  final CvSectionDefinition section;
  final int itemIndex;
  final int itemNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE0E6E2)),
      ),
      child: ExpansionTile(
        initiallyExpanded: itemNumber == 1,
        tilePadding: EdgeInsets.only(left: 13.w, right: 5.w),
        childrenPadding: EdgeInsets.fromLTRB(13.w, 0, 13.w, 13.h),
        title: Text(
          'cvb_collection_item'.trParams(<String, String>{
            'label': cvSectionLabel(section),
            'number': '$itemNumber',
          }),
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.homePrimaryText,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              tooltip: 'cvb_remove'.tr,
              onPressed: () =>
                  controller.removeCollectionItem(section.key, itemIndex),
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.redAccent,
              visualDensity: VisualDensity.compact,
            ),
            const Icon(Icons.expand_more_rounded),
          ],
        ),
        children: controller
            .visibleCollectionFields(section, itemIndex: itemIndex)
            .map(
              (CvFieldDefinition field) => CvDynamicField(
                key: ValueKey<String>('${section.key}-$itemIndex-${field.key}'),
                controller: controller,
                section: section,
                field: field,
                itemIndex: itemIndex,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection({required this.label, required this.onAdd});

  final String label;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.note_add_rounded,
            color: AppColors.homeSecondaryText,
            size: 28.w,
          ),
          SizedBox(height: 7.h),
          Text(
            'cvb_collection_empty'.trParams(<String, String>{'label': label}),
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.homeSecondaryText,
            ),
          ),
          SizedBox(height: 8.h),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'cvb_collection_add'.trParams(<String, String>{'label': label}),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.requiredSection,
    required this.child,
    this.trailing,
  });

  final String title;
  final bool requiredSection;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E7E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: title,
                    children: <InlineSpan>[
                      if (requiredSection)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimaryText,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}
