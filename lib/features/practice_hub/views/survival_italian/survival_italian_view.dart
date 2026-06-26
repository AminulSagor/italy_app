import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/practice_hub_controller.dart';
import '../../models/survival_italian_models.dart';
import '_widgets/survival_situation_cards.dart';

class SurvivalItalianView extends GetView<PracticeHubController> {
  const SurvivalItalianView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: Stack(
        children: <Widget>[
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: () => controller.loadSurvivalItalian(showError: true),
              child: Obx(() {
                if (controller.isSurvivalLoading.value &&
                    controller.survivalItalianItems.isEmpty) {
                  return const _SurvivalLoadingView();
                }

                if (controller.survivalItalianItems.isEmpty) {
                  return _SurvivalEmptyView(
                    message: controller.survivalError.value.isEmpty
                        ? 'No Survival Italian situations are available.'
                        : controller.survivalError.value,
                    onRetry: () =>
                        controller.loadSurvivalItalian(showError: true),
                  );
                }

                final SurvivalSituationModel? hero =
                    controller.survivalHeroItem;
                final List<SurvivalSituationModel> normalItems =
                    controller.survivalNormalItems;
                final List<SurvivalSituationModel> wideItems =
                    controller.survivalWideItems;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 150.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _SurvivalHeader(),
                      SizedBox(height: 26.h),
                      if (hero != null) ...<Widget>[
                        SurvivalHeroSituationCard(item: hero),
                        SizedBox(height: 32.h),
                      ],
                      if (normalItems.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: normalItems.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 24.w,
                                mainAxisSpacing: 24.h,
                                childAspectRatio: 0.94,
                              ),
                          itemBuilder: (BuildContext context, int index) {
                            return SurvivalSmallSituationCard(
                              item: normalItems[index],
                            );
                          },
                        ),
                      if (normalItems.isNotEmpty && wideItems.isNotEmpty)
                        SizedBox(height: 25.h),
                      ...wideItems.map(
                        (SurvivalSituationModel item) => Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: SurvivalWideSituationCard(item: item),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          Obx(
            () => controller.survivalItalianItems.isEmpty
                ? const SizedBox.shrink()
                : const _SurvivalProgressBar(),
          ),
          Obx(() {
            if (!controller.isOpeningSurvivalPdf.value) {
              return const SizedBox.shrink();
            }
            return ColoredBox(
              color: Colors.black.withValues(alpha: 0.22),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              ),
            );
          }),
        ],
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
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
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
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 120.h),
            child: Column(
              children: <Widget>[
                const _SurvivalHeader(),
                const Spacer(),
                Icon(
                  Icons.menu_book_outlined,
                  size: 58.r,
                  color: AppColors.primaryGreen.withValues(alpha: 0.5),
                ),
                SizedBox(height: 18.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6A6F73),
                  ),
                ),
                SizedBox(height: 14.h),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SurvivalHeader extends GetView<PracticeHubController> {
  const _SurvivalHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: controller.onSurvivalBackTap,
            child: Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 24.r,
                color: const Color(0xFF2C3034),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Survival Italian',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font20.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: const Color(0xFF376812),
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  'ইতালিতে আসার পর পর যা শিখতে হবে',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.font11.sp,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF72777B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 62.w),
        ],
      ),
    );
  }
}

class _SurvivalProgressBar extends GetView<PracticeHubController> {
  const _SurvivalProgressBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24.w,
      right: 24.w,
      bottom: 30.h,
      child: SafeArea(
        top: false,
        child: Obx(() {
          final int learned = controller.survivalSituationsLearned;
          final int total = controller.survivalTotalSituations;
          final double progress = controller.survivalLearningProgress;

          return Container(
            height: 81.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: const Color(0xFFCDE7C2), width: 1.2.w),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0, 1).toDouble(),
                      child: Container(
                        height: 5.h,
                        color: const Color(0xFF70FF36),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 41.r,
                          height: 41.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAF4E6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 27.r,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        RichText(
                          text: TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: 'Total Situations Learned: ',
                                style: TextStyle(
                                  fontSize: AppFont.font15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF676B6F),
                                ),
                              ),
                              TextSpan(
                                text: '$learned/$total',
                                style: TextStyle(
                                  fontSize: AppFont.font16.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
