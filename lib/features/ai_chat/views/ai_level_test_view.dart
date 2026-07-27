import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:italir_pothe/core/models/learning_activity_models.dart';
import 'package:italir_pothe/core/widgets/learning_activity_page_scope.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/native_bottom_inset.dart';
import '../controllers/ai_tutor_level_test_controller.dart';
import 'widgets/ai_tutor_level_test_widgets.dart';

class AiLevelTestView extends GetView<AiTutorLevelTestController> {
  const AiLevelTestView({super.key});

  @override
  AiTutorLevelTestController get controller {
    if (Get.isRegistered<AiTutorLevelTestController>()) {
      return Get.find<AiTutorLevelTestController>();
    }
    return Get.put<AiTutorLevelTestController>(AiTutorLevelTestController());
  }

  @override
  Widget build(BuildContext context) {
    return LearningActivityPageScope(
      activityKind: LearningActivityKind.aiTutor,
      sourceId: 'ai_level_test_view',
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFA),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(30.w, 29.h, 30.w, 175.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AiTutorLevelTestHeader(
                      title: 'gen_level_test'.tr,
                      onBackTap: () => Get.back<void>(),
                    ),
                    SizedBox(height: 29.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(25.w, 33.h, 25.w, 31.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(31.r),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'discover_your_exact_level'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25.sp,
                              height: 1.15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'ai_level_test_description'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white.withValues(alpha: 0.82),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 35.h),
                    Text(
                      'what_we_measure'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.7,
                        color: const Color(0xFF686E6B),
                      ),
                    ),
                    SizedBox(height: 17.h),
                    AiTutorLevelMeasureCard(
                      icon: Icons.mic_rounded,
                      iconColor: Color(0xFF1376FF),
                      iconBackground: Color(0xFFE7F0FF),
                      title: 'gen_speaking'.tr,
                      subtitle: 'gen_communication_fluency'.tr,
                    ),
                    SizedBox(height: 17.h),
                    AiTutorLevelMeasureCard(
                      icon: Icons.chat_bubble_rounded,
                      iconColor: Color(0xFFE93838),
                      iconBackground: Color(0xFFFFE5E5),
                      title: 'gen_vocabulary'.tr,
                      subtitle: 'gen_word_knowledge_context'.tr,
                    ),
                    SizedBox(height: 17.h),
                    AiTutorLevelMeasureCard(
                      icon: Icons.menu_book_rounded,
                      iconColor: Color(0xFF24A75A),
                      iconBackground: Color(0xFFDDF9E7),
                      title: 'gen_grammar'.tr,
                      subtitle: 'gen_sentence_structure_verbs'.tr,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 30.w,
                right: 30.w,
                bottom: 0,
                child: NativeBottomInset(
                  child: Container(
                    height: 149.h,
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      24.h,
                      20.w,
                      0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(34.r),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.025,
                          ),
                          blurRadius: 16.r,
                          offset: Offset(0, -6.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        AiTutorLevelPrimaryButton(
                          text: 'start_10_question_test'.tr,
                          onTap: controller.startTest,
                        ),
                        SizedBox(height: 18.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 12.r,
                              color: const Color(0xFF808784),
                            ),
                            SizedBox(width: 5.w),
                            Flexible(
                              child: Text(
                                'takes_about_5_minutes_'
                                    'results_stay_private'
                                    .tr,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF808784),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
