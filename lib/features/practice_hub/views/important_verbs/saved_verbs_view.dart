import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../controllers/important_verbs_controller.dart';
import '../widgets/verb_serch_field.dart';
import '_widgets/important_verb_library_widgets.dart';

class SavedVerbsView extends GetView<ImportantVerbsController> {
  const SavedVerbsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: SimpleAppbar(
        title: 'Saved Verbs',
        onBackTap: () => Navigator.of(context).pop(),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics.axis == Axis.vertical &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 180.h) {
            controller.loadMoreSavedVerbs();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () => controller.loadSavedVerbs(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(22.w, 27.h, 22.w, 42.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Obx(
                  () => VerbSearchField(
                    textController: controller.savedVerbSearchController,
                    hintText: 'Search saved verbs',
                    query: controller.savedVerbSearchQuery.value,
                    onChanged: controller.onSavedVerbSearchChanged,
                    onClear: controller.clearSavedVerbSearch,
                  ),
                ),
                SizedBox(height: 27.h),
                Obx(
                  () => VerbFilterChips(
                    filters: controller.verbFilters,
                    selectedFilter: controller.selectedSavedVerbFilter.value,
                    onSelected: controller.selectSavedVerbFilter,
                  ),
                ),
                SizedBox(height: 28.h),
                Obx(
                  () => VerbLibraryList(
                    verbs: controller.savedVerbItems,
                    isLoading: controller.isSavedVerbsLoading.value,
                    isLoadingMore:
                        controller.isLoadingMoreSavedVerbs.value,
                    error: controller.savedVerbsError.value,
                    onRetry: controller.loadSavedVerbs,
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
