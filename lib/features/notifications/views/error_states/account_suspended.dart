import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/models/account_restriction_details.dart';
import '../../widgets/status_error_widgets.dart';

class AccountSuspendedView extends StatelessWidget {
  const AccountSuspendedView({
    super.key,
    required this.restriction,
    this.onContactSupportTap,
    this.onLogoutTap,
  });

  final AccountRestrictionDetails restriction;
  final VoidCallback? onContactSupportTap;
  final VoidCallback? onLogoutTap;

  @override
  Widget build(BuildContext context) {
    final String reason = restriction.reason.trim().isEmpty
        ? 'restriction_reason_unavailable'.tr
        : restriction.reason.trim();

    return Scaffold(
      backgroundColor: StatusColors.pageBg,
      body: PopScope(
        canPop: false,
        child: StatusPageBackground(
          showAccountGlow: true,
          child: ScrollableStatusBody(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 45.w),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 110.h),
                  Text(
                    'account_suspended'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StatusColors.darkText,
                      fontSize: 34.sp,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'account_access_restricted_description'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StatusColors.bodyText,
                      fontSize: 18.sp,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.15,
                    ),
                  ),
                  SizedBox(height: 42.h),
                  CustomPaint(
                    painter: DashedRRectPainter(
                      color: const Color(0xFFECA18F),
                      radius: 42.r,
                      strokeWidth: 1.4.w,
                      dash: 6.w,
                      gap: 6.w,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(32.w, 31.h, 32.w, 30.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7E5E0),
                        borderRadius: BorderRadius.circular(42.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 25.r,
                                color: const Color(0xFFC52B0B),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  'reason_for_suspension'.tr,
                                  style: TextStyle(
                                    color: const Color(0xFFC52B0B),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 21.h),
                          Text(
                            reason,
                            style: TextStyle(
                              color: StatusColors.darkText,
                              fontSize: 18.sp,
                              height: 1.55,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.15,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            height: 1.h,
                            width: double.infinity,
                            color: const Color(0xFFE6C9C1),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            _effectiveDateLabel(),
                            style: TextStyle(
                              color: const Color(0xFF999999),
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (restriction.caseNumber?.trim().isNotEmpty == true)
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                'moderation_case_reference'.trParams(
                                  <String, String>{
                                    'caseNumber': restriction.caseNumber!.trim(),
                                  },
                                ),
                                style: TextStyle(
                                  color: const Color(0xFF999999),
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 42.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(31.w, 34.h, 31.w, 24.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(44.r),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 45.r,
                          offset: Offset(0, 25.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'account_restriction_appeal_message'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: StatusColors.bodyText,
                            fontSize: 16.sp,
                            height: 1.42,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.15,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        GreenShadowButton(
                          height: 66.h,
                          radius: 34.r,
                          text: 'gen_contact_support'.tr,
                          icon: Icons.chat_bubble_outline_rounded,
                          onTap: onContactSupportTap,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ThinOutlineButton(
                    width: 244.w,
                    height: 47.h,
                    radius: 24.r,
                    text: 'log_out_of_this_account'.tr,
                    icon: Icons.logout_rounded,
                    onTap: onLogoutTap,
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _effectiveDateLabel() {
    final DateTime? value = restriction.effectiveAt;
    if (value == null) {
      return 'effective_date_unavailable'.tr;
    }

    final DateTime local = value.toLocal();
    final String day = local.day.toString().padLeft(2, '0');
    final String month = local.month.toString().padLeft(2, '0');
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');
    final String formatted = '$day/$month/${local.year} $hour:$minute';

    return 'effective_as_of'.trParams(<String, String>{'date': formatted});
  }
}
