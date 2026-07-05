import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../../core/themes/app_colors.dart';
import '../../controllers/important_verbs_controller.dart';
import '../../models/important_verb_detail_models.dart';
import '../../models/important_verb_models.dart';
import '_widgets/important_verb_detail_widgets.dart';

class VerbDetailsView extends GetView<ImportantVerbsController> {
  const VerbDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.importantVerbs,
      sourceId: 'verb_details_view',
      child: Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final ImportantVerbSummaryModel? summary =
              controller.currentVerbSummary;
          final ImportantVerbDetailModel? details =
              controller.selectedVerbDetails.value;

          if (summary == null) {
            return _VerbDetailsMessage(
              message: 'verb_information_is_unavailable'.tr,
              onBack: controller.onVerbDetailBackTap,
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadVerbDetails(summary.id),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(24.w, 15.h, 24.w, 42.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const VerbDetailsTopBar(),
                  SizedBox(height: 13.h),
                  VerbHeroCard(verb: summary),
                  SizedBox(height: 20.h),
                  if (controller.isVerbDetailsLoading.value && details == null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 42.h),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (controller.verbDetailsError.value.isNotEmpty &&
                      details == null)
                    _VerbDetailsRetry(
                      message: controller.verbDetailsError.value,
                      onRetry: () => controller.loadVerbDetails(summary.id),
                    )
                  else if (details != null) ...<Widget>[
                    VerbInformationCard(information: details.information),
                    SizedBox(height: 32.h),
                    Text(
                      'verb_forms_tenses'.tr,
                      style: TextStyle(
                        fontSize: 20.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.45,
                        color: const Color(0xFF33383C),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    if (details.forms.isEmpty)
                      Text(
                        'no_verb_forms_are_available'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF747A80),
                        ),
                      )
                    else
                      ...details.forms.asMap().entries.map(
                        (MapEntry<int, ImportantVerbFormModel> entry) =>
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: entry.key == details.forms.length - 1
                                    ? 0
                                    : 14.h,
                              ),
                              child: VerbFormSection(form: entry.value),
                            ),
                      ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    ),
    );
  }
}

class _VerbDetailsRetry extends StatelessWidget {
  const _VerbDetailsRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF747A80),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(onPressed: onRetry, child: Text('retry'.tr)),
          ],
        ),
      ),
    );
  }
}

class _VerbDetailsMessage extends StatelessWidget {
  const _VerbDetailsMessage({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp, color: const Color(0xFF747A80)),
            ),
            SizedBox(height: 12.h),
            TextButton(onPressed: onBack, child: Text('go_back'.tr)),
          ],
        ),
      ),
    );
  }
}
