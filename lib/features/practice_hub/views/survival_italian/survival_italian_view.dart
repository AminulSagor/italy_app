import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/practice_hub_controller.dart';
import '../../models/survival_italian_models.dart';
import '_widgets/survival_situation_cards.dart';

class SurvivalItalianView extends GetView<PracticeHubController> {
  const SurvivalItalianView({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottomSafeArea =
        MediaQuery.paddingOf(context).bottom;

    return LearningActivityPageScope(
      activityKind: LearningActivityKind.survivalItalian,
      sourceId: 'survival_italian_view',
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: Stack(
          children: <Widget>[
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: () {
                  return controller.loadSurvivalItalian(
                    showError: true,
                  );
                },
                child: Obx(() {
                  if (controller.isSurvivalLoading.value &&
                      controller.survivalItalianItems.isEmpty) {
                    return const _SurvivalLoadingView();
                  }

                  if (controller.survivalItalianItems.isEmpty) {
                    return _SurvivalEmptyView(
                      message:
                      controller.survivalError.value.isEmpty
                          ? 'no_survival_italian_situations_are_available'
                          .tr
                          : controller.survivalError.value,
                      onRetry: () {
                        controller.loadSurvivalItalian(
                          showError: true,
                        );
                      },
                    );
                  }

                  final SurvivalSituationModel? hero =
                      controller.survivalHeroItem;

                  final List<SurvivalSituationModel>
                  normalItems =
                      controller.survivalNormalItems;

                  final List<SurvivalSituationModel> wideItems =
                      controller.survivalWideItems;

                  return SingleChildScrollView(
                    physics:
                    const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),

                    // Keeps the final content above the floating card.
                    padding: EdgeInsets.fromLTRB(
                      24.w,
                      0.h,
                      24.w,
                      bottomSafeArea + 104.h,
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: <Widget>[
                        const _SurvivalHeader(),

                        SizedBox(height: 26.h),

                        if (hero != null) ...<Widget>[
                          SurvivalHeroSituationCard(
                            item: hero,
                          ),

                          SizedBox(height: 32.h),
                        ],

                        if (normalItems.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: normalItems.length,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 24.w,
                              mainAxisSpacing: 24.h,
                              childAspectRatio: 0.94,
                            ),
                            itemBuilder: (
                                BuildContext context,
                                int index,
                                ) {
                              return SurvivalSmallSituationCard(
                                item: normalItems[index],
                              );
                            },
                          ),

                        if (normalItems.isNotEmpty &&
                            wideItems.isNotEmpty)
                          SizedBox(height: 25.h),

                        ...wideItems.map(
                              (SurvivalSituationModel item) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: 20.h,
                              ),
                              child:
                              SurvivalWideSituationCard(
                                item: item,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            Obx(() {
              if (controller
                  .survivalItalianItems
                  .isEmpty) {
                return const SizedBox.shrink();
              }

              return const _SurvivalProgressBar();
            }),

            Obx(() {
              if (!controller.isOpeningSurvivalPdf.value) {
                return const SizedBox.shrink();
              }

              return const _PdfOpeningOverlay();
            }),
          ],
        ),
      ),
    );
  }
}

class _SurvivalLoadingView extends StatelessWidget {
  const _SurvivalLoadingView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  24.w,
                  20.h,
                  24.w,
                  0,
                ),
                child: const _SurvivalHeader(),
              ),

              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SurvivalEmptyView extends StatelessWidget {
  const _SurvivalEmptyView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24.w,
              20.h,
              24.w,
              120.h,
            ),
            child: Column(
              children: <Widget>[
                const _SurvivalHeader(),

                const Spacer(),

                Container(
                  width: 70.r,
                  height: 70.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(
                      alpha: 0.08,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_outlined,
                    size: 34.r,
                    color: AppColors.primaryGreen.withValues(
                      alpha: 0.70,
                    ),
                  ),
                ),

                SizedBox(height: 18.h),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font15.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6A6F73),
                  ),
                ),

                SizedBox(height: 14.h),

                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: Text('retry'.tr),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SurvivalHeader
    extends GetView<PracticeHubController> {
  const _SurvivalHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64.h,
      child: Row(
        children: <Widget>[
          Material(
            color: AppColors.white,
            shape: const CircleBorder(),
            elevation: 1,
            shadowColor:
            Colors.black.withValues(alpha: 0.10),
            child: InkWell(
              onTap: controller.onSurvivalBackTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 46.r,
                height: 46.r,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 23.r,
                  color: const Color(0xFF2C3034),
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              'gen_survival_italian'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font20.sp,
                height: 1.1,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: const Color(0xFF376812),
              ),
            ),
          ),

          // Balances the back button so the title stays centered.
          SizedBox(width: 58.w),
        ],
      ),
    );
  }
}

class _SurvivalProgressBar
    extends GetView<PracticeHubController> {
  const _SurvivalProgressBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16.w,
      right: 16.w,

      // Places the floating card close to the bottom.
      bottom: 8.h,

      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(
          bottom: 4.h,
        ),
        child: Obx(() {
          final int learned =
              controller.survivalSituationsLearned;

          final int total =
              controller.survivalTotalSituations;

          final double progress =
          controller.survivalLearningProgress
              .clamp(0.0, 1.0)
              .toDouble();

          return Semantics(
            container: true,
            label:
            '${'total_situations_learned'.tr}: '
                '$learned / $total',
            child: Container(
              height: 66.h,
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                BorderRadius.circular(22.r),
                border: Border.all(
                  color: const Color(0xFFD6E8CF),
                  width: 1.w,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.12,
                    ),
                    blurRadius: 22.r,
                    offset: Offset(0, 7.h),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 38.r,
                    height: 38.r,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF4E6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      progress >= 1
                          ? Icons.check_circle_rounded
                          : Icons.school_outlined,
                      size: 22.r,
                      color: AppColors.primaryGreen,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'total_situations_learned'.tr,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:
                            AppFont.font14.sp,
                            height: 1,
                            fontWeight:
                            FontWeight.w700,
                            color: const Color(
                              0xFF626A66,
                            ),
                          ),
                        ),

                        SizedBox(height: 8.h),

                        ClipRRect(
                          borderRadius:
                          BorderRadius.circular(
                            99.r,
                          ),
                          child:
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 5.h,
                            backgroundColor:
                            const Color(
                              0xFFE4EBE1,
                            ),
                            color:
                            AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 14.w),

                  AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 180,
                    ),
                    transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                        ) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      '$learned/$total',
                      key: ValueKey<String>(
                        '$learned-$total',
                      ),
                      style: TextStyle(
                        fontSize: AppFont.font16.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color:
                        AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PdfOpeningOverlay extends StatelessWidget {
  const _PdfOpeningOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(
          alpha: 0.24,
        ),
        child: Center(
          child: Container(
            width: 58.r,
            height: 58.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
              BorderRadius.circular(18.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.12,
                  ),
                  blurRadius: 20.r,
                ),
              ],
            ),
            child: SizedBox(
              width: 27.r,
              height: 27.r,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}