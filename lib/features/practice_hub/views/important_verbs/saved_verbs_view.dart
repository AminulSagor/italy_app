import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../controllers/practice_hub_controller.dart';
import '../widgets/verb_serch_field.dart';
import 'important_verbs_view.dart';

class SavedVerbsView extends GetView<PracticeHubController> {
  const SavedVerbsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: SimpleAppbar(
        title: 'Saved Verbs',
        onBackTap: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(22.w, 27.h, 22.w, 42.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Obx(
              () => VerbSearchField(
                textController: controller.savedVerbSearchController,
                hintText: 'Search for a saved Verbs',
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
              () => VerbLibraryList(verbs: controller.filteredSavedVerbItems),
            ),
          ],
        ),
      ),
    );
  }
}
