import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_font.dart';
import '../controllers/ai_chat_controller.dart';
import '../models/ai_tutor_guided_learning_models.dart';

class GuidedLearningTopicsView extends GetView<AiChatController> {
  final String level;
  final AiTutorGuidedMode mode;

  const GuidedLearningTopicsView({
    super.key,
    required this.level,
    required this.mode,
  });

  @override
  AiChatController get controller {
    if (Get.isRegistered<AiChatController>()) {
      return Get.find<AiChatController>();
    }
    return Get.put<AiChatController>(AiChatController());
  }

  static List<_GuidedTopic> _topics = <_GuidedTopic>[
    _GuidedTopic(
      title: 'gen_comprare_un_nbiglietto'.tr,
      subtitle: 'বাসের টিকিট কেনা'.tr,
      icon: Icons.directions_bus_rounded,
    ),
    _GuidedTopic(
      title: 'gen_ordinare_al_bar'.tr,
      subtitle: 'বারে কফি অর্ডার করা'.tr,
      icon: Icons.local_cafe_rounded,
    ),
    _GuidedTopic(
      title: 'gen_fare_la_spesa'.tr,
      subtitle: 'সুপারমার্কেটে কেনাকাটা'.tr,
      icon: Icons.shopping_cart_rounded,
    ),
    _GuidedTopic(
      title: 'gen_chiedere_nindicazioni'.tr,
      subtitle: 'রাস্তা জিজ্ঞাসা করা'.tr,
      icon: Icons.map_outlined,
    ),
    _GuidedTopic(
      title: 'gen_dal_dottore'.tr,
      subtitle: 'ডাক্তারের কাছে'.tr,
      icon: Icons.medical_services_outlined,
    ),
    _GuidedTopic(
      title: 'gen_prenotare_un_nhotel'.tr,
      subtitle: 'হোটেল বুক করা'.tr,
      icon: Icons.hotel_rounded,
    ),
    _GuidedTopic(
      title: 'gen_in_posta'.tr,
      subtitle: 'পোস্ট অফিসে'.tr,
      icon: Icons.email_outlined,
    ),
    _GuidedTopic(
      title: 'gen_incontrare_namici'.tr,
      subtitle: 'বন্ধুদের সাথে দেখা'.tr,
      icon: Icons.group_outlined,
    ),
    _GuidedTopic(
      title: 'gen_al_lavoro'.tr,
      subtitle: 'কাজের জায়গায়'.tr,
      icon: Icons.work_outline_rounded,
    ),
    _GuidedTopic(
      title: 'gen_al_ristorante'.tr,
      subtitle: 'রেস্টুরেন্টে'.tr,
      icon: Icons.restaurant_rounded,
    ),
  ];

  String get _lessonDescription {
    switch (mode) {
      case AiTutorGuidedMode.guided:
        return 'listen_to_one_italian_phrase_and_repeat_it_n'.tr +
            'exactly before moving to the next phrase.';
      case AiTutorGuidedMode.assisted:
        return 'answer_the_ai_questions_in_italian_and_get_nsimple'.tr;
      case AiTutorGuidedMode.free:
        return 'practice_a_natural_real_life_italian_nconversation'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(30.w, 27.h, 30.w, 70.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () => Get.back<void>(),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 24.r,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(height: 28.h),
              Center(
                child: Text(
                  'level_topics'.trParams(<String, String>{
                    'level': level.toString(),
                  }),
                  style: TextStyle(
                    fontSize: 24.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: Text(
                  _lessonDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF666D6A),
                  ),
                ),
              ),
              SizedBox(height: 31.h),
              ..._topics.map((_GuidedTopic item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: _TopicCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: item.icon,
                    onTap: () => controller.onGuidedTopicTap(
                      level: level,
                      mode: mode,
                      topicTitle: item.title.replaceAll('\n', ' '),
                    ),
                  ),
                );
              }),
              SizedBox(height: 3.h),
              const _TipCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidedTopic {
  const _GuidedTopic({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _TopicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 108),
        padding: EdgeInsets.fromLTRB(25.w, 18.h, 25.w, 17.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(46.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 22.r,
              offset: Offset(0, 11.h),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 54.r,
              height: 54.r,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF8E8),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 25.r, color: AppColors.primaryGreen),
            ),
            SizedBox(width: 22.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.sp,
                      height: 1.18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                      color: const Color(0xFF303837),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6D7471),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Container(
              width: 49.r,
              height: 49.r,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 26.r,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(25.w, 24.h, 25.w, 27.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE9FFD8),
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 28.r,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'tip_for_chatting'.tr,
                  style: TextStyle(
                    fontSize: AppFont.font14.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 13.h),
                Text(
                  'ai_scenario_tip'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7C8581),
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
