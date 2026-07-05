import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../controllers/important_verbs_controller.dart';
import '../widgets/verb_serch_field.dart';
import '_widgets/important_verb_library_widgets.dart';
import '_widgets/saved_verb_preview_widgets.dart';

class ImportantVerbsView extends GetView<ImportantVerbsController> {
  const ImportantVerbsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: SimpleAppbar(
        title: 'gen_important_verbs'.tr,
        onBackTap: () => Navigator.of(context).pop(),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics.axis == Axis.vertical &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 180.h) {
            controller.loadMoreVerbs();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: controller.refreshImportantVerbs,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 42.h),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Image.asset(
                      'assets/heroes/important_verbs_hero.png',
                      width: double.infinity,
                      height: 144.h,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 27.h),
                    Obx(
                      () => VerbSearchField(
                        textController:
                            controller.importantVerbSearchController,
                        hintText: 'gen_search_for_a_verb_e_g_avere'.tr,
                        query: controller.importantVerbSearchQuery.value,
                        onChanged: controller.onImportantVerbSearchChanged,
                        onClear: controller.clearImportantVerbSearch,
                      ),
                    ),
                    SizedBox(height: 29.h),
                    const SavedVerbPreviewSection(),
                    SizedBox(height: 21.h),
                    Obx(
                      () => VerbFilterChips(
                        filters: controller.verbFilters,
                        selectedFilter:
                            controller.selectedImportantVerbFilter.value,
                        onSelected: controller.selectImportantVerbFilter,
                      ),
                    ),
                    SizedBox(height: 27.h),
                    Obx(
                      () => VerbLibraryList(
                        verbs: controller.verbItems,
                        isLoading: controller.isVerbsLoading.value,
                        isLoadingMore: controller.isLoadingMoreVerbs.value,
                        error: controller.verbsError.value,
                        onRetry: controller.loadVerbs,
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  if (controller.importantVerbSearchQuery.value
                      .trim()
                      .isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    top: 224.h,
                    left: 0,
                    right: 0,
                    child: const SearchSuggestionOverlay(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
