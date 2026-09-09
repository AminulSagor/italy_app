import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../controllers/cv_library_controller.dart';
import '../models/cv_library_model.dart';
import '../widgets/cv_library_card.dart';
import '../widgets/cv_library_skeleton.dart';

class CvLibraryView extends GetView<CvLibraryController> {
  const CvLibraryView({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const _InlineHeader(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: controller.refreshLibrary,
                child: Obx(() {
                  if (controller.isInitialLoading.value &&
                      controller.items.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 28.h),
                      children: const <Widget>[CvLibrarySkeleton()],
                    );
                  }

                  if (controller.errorMessage.value.isNotEmpty &&
                      controller.items.isEmpty) {
                    return _StateList(
                      icon: Icons.cloud_off_outlined,
                      title: 'cvb_library_load_failed'.tr,
                      message: controller.errorMessage.value,
                      actionLabel: 'cvb_try_again'.tr,
                      onAction: () =>
                          controller.loadLibrary(reset: true, blocking: true),
                    );
                  }

                  if (controller.items.isEmpty) {
                    return _StateList(
                      icon: Icons.folder_open_rounded,
                      title: 'cvb_no_saved_cvs'.tr,
                      message: 'cvb_no_saved_cvs_message'.tr,
                    );
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 28.h),
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'cvb_one_workspace'.tr,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.homeSecondaryText,
                              ),
                            ),
                          ),
                          Text(
                            '${controller.totalItems.value}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.homeSecondaryText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ...controller.items.map(
                        (CvLibraryItemModel item) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: SizedBox(
                            child: CvLibraryCard(
                              key: ValueKey<String>(
                                'library-${item.documentId}',
                              ),
                              item: item,
                              isOpening:
                                  controller.openingDocumentId.value ==
                                  item.documentId,
                              isViewing:
                                  controller.viewingDocumentId.value ==
                                  item.documentId,
                              onEdit: () => controller.edit(item),
                              onView: () => controller.view(item),
                            ),
                          ),
                        ),
                      ),
                      if (controller.canLoadMore)
                        OutlinedButton(
                          onPressed: controller.isLoadingMore.value
                              ? null
                              : () => controller.loadLibrary(reset: false),
                          child: controller.isLoadingMore.value
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryGreen,
                                  ),
                                )
                              : Text('cvb_load_more'.tr),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineHeader extends StatelessWidget {
  const _InlineHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(6.w, 4.h, 16.w, 8.h),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'cvb_back'.tr,
            onPressed: () => Get.back<void>(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'cvb_my_cvs'.tr,
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.homePrimaryText,
                  ),
                ),
                Text(
                  'cvb_library_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: AppColors.homeSecondaryText,
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

class _StateList extends StatelessWidget {
  const _StateList({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 72.h, 24.w, 24.h),
      children: <Widget>[
        Icon(icon, size: 48.w, color: AppColors.homeSecondaryText),
        SizedBox(height: 12.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.homePrimaryText,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5.sp,
            height: 1.4,
            color: AppColors.homeSecondaryText,
          ),
        ),
        if (actionLabel != null && onAction != null) ...<Widget>[
          SizedBox(height: 12.h),
          Center(
            child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ),
        ],
      ],
    );
  }
}
