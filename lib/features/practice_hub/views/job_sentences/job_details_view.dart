import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_font.dart';
import '../../controllers/practice_hub_controller.dart';

class JobDetailsView extends GetView<PracticeHubController> {
  const JobDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 48.h),
          child: Obx(() {
            final Map<String, dynamic> job = controller.currentJobTrack;
            final List<Map<String, dynamic>> categories =
                controller.currentJobCategories;

            return Column(
              children: <Widget>[
                _JobDetailsHeader(title: job['title'] as String),
                SizedBox(height: 21.h),
                Transform.scale(
                  scale: 1.11,
                  child: Image.asset(
                    'assets/heroes/job_details_video.png',
                    width: double.infinity,
                  ),
                ),

                //_JobIntroVideoCard(job: job),
                //SizedBox(height: 32.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 17.h,
                    crossAxisSpacing: 17.w,
                    childAspectRatio: 1.08,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return _JobCategoryCard(item: categories[index]);
                  },
                ),

                SizedBox(height: 34.h),

                _TheoryBookCard(job: job),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _JobDetailsHeader extends GetView<PracticeHubController> {
  final String title;

  const _JobDetailsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 61.h,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: controller.onJobDetailsBackTap,
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
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                height: 1,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          SizedBox(width: 48.r),
        ],
      ),
    );
  }
}

class _JobCategoryCard extends GetView<PracticeHubController> {
  final Map<String, dynamic> item;

  const _JobCategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool showIcon = item['showIcon'] as bool? ?? true;

    return GestureDetector(
      onTap: () => controller.openJobPhraseCategory(item),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(42.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 18.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (showIcon) ...<Widget>[
              Container(
                width: 56.r,
                height: 56.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEFE3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 28.r,
                  color: const Color(0xFF9B5C00),
                ),
              ),
              SizedBox(height: 22.h),
            ],
            Text(
              item['title'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font15.sp,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2D3236),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              item['bangla'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFont.font12.sp,
                height: 1,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8A8E92),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TheoryBookCard extends GetView<PracticeHubController> {
  final Map<String, dynamic> job;

  const _TheoryBookCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final Color color = job['color'] as Color? ?? AppColors.primaryGreen;
    final Color background =
        job['theoryBackground'] as Color? ?? const Color(0xFFEAF8EA);

    return GestureDetector(
      onTap: controller.openJobTheoryBook,
      child: Container(
        width: double.infinity,
        height: 139.h,
        padding: EdgeInsets.fromLTRB(26.w, 25.h, 26.w, 25.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(42.r),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
            width: 2.w,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(Icons.menu_book_rounded, size: 28.r, color: color),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                'Theory Book –\nRestaurant Basics\n12 pages of grammar & job\nrules',
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 28.r,
              color: const Color(0xFFC1A670),
            ),
          ],
        ),
      ),
    );
  }
}

class JobPhraseDetailsView extends GetView<PracticeHubController> {
  const JobPhraseDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(30.w, 24.h, 18.w, 48.h),
          child: Column(
            children: <Widget>[
              const _PhraseDetailsHeader(),
              SizedBox(height: 25.h),
              const _PhraseSearchField(),
              SizedBox(height: 31.h),
              Obx(
                () => Column(
                  children: controller.filteredJobPhrases
                      .map(
                        (Map<String, dynamic> phrase) => Padding(
                          padding: EdgeInsets.only(bottom: 24.h),
                          child: _PhraseCard(phrase: phrase),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhraseDetailsHeader extends GetView<PracticeHubController> {
  const _PhraseDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Map<String, dynamic> category = controller.currentJobPhraseCategory;

      return Row(
        children: <Widget>[
          GestureDetector(
            onTap: controller.onJobPhraseBackTap,
            child: Icon(
              Icons.arrow_back_rounded,
              size: 25.r,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(width: 23.w),
          Expanded(
            child: Text(
              category['title'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFont.font18.sp,
                height: 1,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 17.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE5FFD7),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: const Color(0xFFBDEDA6), width: 1.w),
            ),
            child: Center(
              child: Text(
                '${category['learned']} / ${category['total']} Phrases Learned',
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _PhraseSearchField extends GetView<PracticeHubController> {
  const _PhraseSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57.h,
      padding: EdgeInsets.symmetric(horizontal: 19.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search_rounded,
            size: 24.r,
            color: const Color(0xFFAFB2B5),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: TextField(
              controller: controller.jobPhraseSearchController,
              onChanged: controller.onJobPhraseSearchChanged,
              cursorColor: AppColors.primaryGreen,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search phrases...',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFC0C2C4),
                ),
              ),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3236),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhraseCard extends GetView<PracticeHubController> {
  final Map<String, dynamic> phrase;

  const _PhraseCard({required this.phrase});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String id = phrase['id'] as String;
      final bool isPlaying = controller.currentPlayingJobPhraseId.value == id;

      return GestureDetector(
        onTap: () => controller.playJobPhrase(id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          constraints: BoxConstraints(minHeight: isPlaying ? 265.h : 145.h),
          padding: EdgeInsets.fromLTRB(32.w, 31.h, 32.w, 28.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(43.r),
            border: Border.all(
              color: isPlaying ? const Color(0xFF70FF35) : AppColors.white,
              width: 2.w,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 18.r,
                offset: Offset(0, 9.h),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      phrase['italian'] as String,
                      style: TextStyle(
                        fontSize: 25.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCFFFAD),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                      size: 29.r,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  phrase['bangla'] as String,
                  style: TextStyle(
                    fontSize: 17.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF777C80),
                  ),
                ),
              ),
              if (isPlaying) ...<Widget>[
                SizedBox(height: 58.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: controller.currentJobPhraseAudioProgress.value,
                    minHeight: 6.h,
                    backgroundColor: const Color(0xFFE3E5E5),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
