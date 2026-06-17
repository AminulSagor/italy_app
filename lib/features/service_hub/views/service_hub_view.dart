import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../sub_features/caf_administrative_help/views/caf_administrative_help_view.dart';
import '../sub_features/cv_builder/views/cv_builder_view.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_constants.dart';
import '../_widgets/expert_contact_card.dart';
import '../_widgets/service_action_card.dart';
import '../_widgets/students_assisted_card.dart';

class ServiceHubView extends StatelessWidget {
  const ServiceHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.homeBackground,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(12.w, 20.h, 12.w, 100.h),
        child: Column(
          children: <Widget>[
            ServiceActionCard(
              height: 150.h,
              gradientColors: const <Color>[
                AppColors.serviceHubBlueStart,
                AppColors.serviceHubBlueEnd,
              ],
              icon: Icons.description_outlined,
              title: 'CV Builder',
              subtitle: '২ মিনিটে আপনার সিভি তৈরি করুন',
              buttonText: 'CREATE MY CV',
              onTap: () => Get.to(() => const CvBuilderView()),
            ),
            SizedBox(height: kDefaultGap.h + 2.h),
            ServiceActionCard(
              height: 158.h,
              gradientColors: const <Color>[
                AppColors.serviceHubGreenStart,
                AppColors.serviceHubGreenEnd,
              ],
              icon: Icons.account_balance_outlined,
              title: 'CAF &\nAdministrative\nHelp',
              buttonText: 'EXPLORE SERVICES',
              onTap: () => Get.to(() => const CafAdministrativeHelpView()),
            ),
            SizedBox(height: kMediumBorderRadius.h),
            const ExpertContactCard(),
            SizedBox(height: kDefaultGap.h),
            const StudentsAssistedCard(),
          ],
        ),
      ),
    );
  }
}
