import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../controllers/cv_builder_controller.dart';
import '../models/cv_template_model.dart';
import '../widgets/cv_builder_loading_skeleton.dart';
import '../widgets/cv_dynamic_section.dart';
import '../widgets/cv_keyboard_aware_field.dart';

class CvBuilderView extends GetView<CvBuilderController> {
  const CvBuilderView({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Obx(() {
            if (controller.isPreparing.value) {
              return Column(
                children: <Widget>[
                  _InlineToolbar(controller: controller),
                  const Expanded(child: CvBuilderLoadingSkeleton()),
                ],
              );
            }

            return Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _InlineToolbar(controller: controller),
                    Expanded(
                      child: GetBuilder<CvBuilderController>(
                        tag: controllerTag,
                        id: 'form',
                        builder: (CvBuilderController builder) {
                          final bool keyboardOpen =
                              MediaQuery.viewInsetsOf(context).bottom > 0;

                          return ListView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.fromLTRB(
                              16.w,
                              8.h,
                              16.w,
                              126.h + (keyboardOpen ? 24.h : 0),
                            ),
                            children: <Widget>[
                              _CreationAccessBanner(controller: builder),
                              SizedBox(height: 12.h),
                              _DocumentTitleCard(controller: builder),
                              SizedBox(height: 12.h),
                              Obx(() {
                                if (builder.saveError.value.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: EdgeInsets.only(top: 12.h),
                                  child: _SaveErrorBanner(
                                    message: builder.saveError.value,
                                    onRetry: builder.saveNow,
                                  ),
                                );
                              }),
                              SizedBox(height: 14.h),
                              ...builder.schema.visibleSections.map(
                                (
                                  CvSectionDefinition section,
                                ) => CvDynamicSection(
                                  key: ValueKey<String>(
                                    '${builder.selectedTemplate.value?.id ?? 'scratch'}-${section.key}',
                                  ),
                                  controller: builder,
                                  section: section,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _BottomActionBar(controller: controller),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _InlineToolbar extends StatelessWidget {
  const _InlineToolbar({required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.homeBackground,
      padding: EdgeInsets.fromLTRB(6.w, 4.h, 12.w, 5.h),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'cvb_back'.tr,
            onPressed: () => Get.back<void>(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              controller.isEditingExistingDocument
                  ? 'cvb_edit_cv'.tr
                  : 'cvb_build_cv'.tr,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.homePrimaryText,
              ),
            ),
          ),
          Obx(
            () => _SaveStatus(
              isPreparing: controller.isPreparing.value,
              isSaving: controller.isSaving.value,
              hasUnsavedChanges: controller.hasUnsavedChanges.value,
              hasError: controller.saveError.value.isNotEmpty,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreationAccessBanner extends StatelessWidget {
  const _CreationAccessBanner({required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool alreadyCreated = controller.creationAccessConsumed.value;
      final CvAccessModel? access = controller.accessAtOpen;

      if (alreadyCreated) {
        return _InfoBanner(
          background: const Color(0xFFE5F5E8),
          foreground: const Color(0xFF176B38),
          icon: Icons.verified_rounded,
          title: 'cvb_editing_free_title'.tr,
          message: 'cvb_editing_free_message'.tr,
        );
      }

      if (access?.nextIsFree == true) {
        return _InfoBanner(
          background: const Color(0xFFEAF5E5),
          foreground: const Color(0xFF276B1C),
          icon: Icons.card_giftcard_rounded,
          title: 'cvb_free_creation_title'.tr,
          message: 'cvb_free_creation_message'.tr,
        );
      }

      if (access?.nextUsesPaidCredit == true) {
        return _InfoBanner(
          background: const Color(0xFFFFF2D8),
          foreground: const Color(0xFF895900),
          icon: Icons.toll_rounded,
          title: 'cvb_paid_creation_title'.tr,
          message: 'cvb_paid_creation_message'.tr,
        );
      }

      return _InfoBanner(
        background: const Color(0xFFFFEEE9),
        foreground: const Color(0xFF9B3D27),
        icon: Icons.info_outline_rounded,
        title: 'cvb_access_required_title'.tr,
        message: 'cvb_access_required_message'.tr,
      );
    });
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.title,
    required this.message,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: foreground, size: 22.w),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: foreground,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    height: 1.35,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTitleCard extends StatefulWidget {
  const _DocumentTitleCard({required this.controller});

  final CvBuilderController controller;

  @override
  State<_DocumentTitleCard> createState() => _DocumentTitleCardState();
}

class _DocumentTitleCardState extends State<_DocumentTitleCard> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.title);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: CvKeyboardAwareField(
        builder: (BuildContext context, FocusNode focusNode) => TextField(
          focusNode: focusNode,
          controller: _textController,
          onChanged: widget.controller.setTitle,
          maxLength: 160,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'cvb_name'.tr,
            hintText: 'cvb_name_hint'.tr,
            counterText: '',
            prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13.r),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 11.h, 14.w, 11.h),
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: controller.isRendering.value
                    ? null
                    : controller.renderCv,
                icon: controller.isRendering.value
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                  controller.isRendering.value
                      ? 'cvb_creating_pdf'.tr
                      : 'cvb_preview_pdf'.tr,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveStatus extends StatelessWidget {
  const _SaveStatus({
    required this.isPreparing,
    required this.isSaving,
    required this.hasUnsavedChanges,
    required this.hasError,
  });

  final bool isPreparing;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    if (isPreparing || isSaving) {
      return SizedBox(
        width: 20.w,
        height: 20.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryGreen,
        ),
      );
    }
    if (hasError) {
      return const Icon(Icons.cloud_off_outlined, color: Colors.redAccent);
    }
    if (hasUnsavedChanges) {
      return const Icon(Icons.cloud_upload_outlined, color: Color(0xFFB66A00));
    }
    return const Icon(Icons.cloud_done_outlined, color: AppColors.primaryGreen);
  }
}

class _SaveErrorBanner extends StatelessWidget {
  const _SaveErrorBanner({required this.message, required this.onRetry});

  final String message;
  final Future<bool> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EE),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.cloud_off_outlined, color: Colors.redAccent),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 11.5.sp, color: Colors.red.shade800),
            ),
          ),
          TextButton(onPressed: () => onRetry(), child: Text('cvb_retry'.tr)),
        ],
      ),
    );
  }
}
