import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'contact_controller.dart';

class ContactSupportView extends GetView<ContactController> {
  const ContactSupportView({super.key});

  static const Color _background = Color(0xFFF5F8F7);

  static const Color _primary = Color(0xFF0A7C58);

  static const Color _primaryDark = Color(0xFF064E3B);

  static const Color _dark = Color(0xFF161F1D);

  static const Color _muted = Color(0xFF66736E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const _ContactTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 36.h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _SupportIntroduction(),

                        SizedBox(height: 22.h),

                        _WhatsAppSupportCard(
                          phone: controller.supportPhoneDisplay,
                          onTap: controller.chatOnWhatsapp,
                        ),

                        SizedBox(height: 16.h),

                        Column(
                          children: <Widget>[
                            _ContactActionCard(
                              icon: Icons.call_rounded,
                              title: 'gen_call_support'.tr,
                              value: controller.supportPhoneDisplay,
                              helper: 'Tap to start a phone call',
                              onTap: controller.callSupport,
                            ),

                            SizedBox(height: 14.h),

                            _ContactActionCard(
                              icon: Icons.email_rounded,
                              title: 'gen_send_email'.tr,
                              value: controller.supportEmail,
                              helper: 'Send us a support email',
                              onTap: controller.sendEmail,
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        _FacebookCommunityCard(
                          onTap: controller.joinFacebookCommunity,
                        ),

                        SizedBox(height: 18.h),

                        const _ResponsePromiseCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTopBar extends StatelessWidget {
  const _ContactTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 18.w, 8.h),
      child: SizedBox(
        height: 52.h,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: Get.back,
                  child: SizedBox(
                    width: 46.r,
                    height: 46.r,
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: ContactSupportView._primary,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              'help_support'.tr,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: ContactSupportView._dark,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportIntroduction extends StatelessWidget {
  const _SupportIntroduction();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE4ECE8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 62.r,
            height: 62.r,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7F0),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 34.r,
              color: ContactSupportView._primary,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'how_can_we_help_you'.tr,
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w800,
                    color: ContactSupportView._dark,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'support_contact_description'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: ContactSupportView._muted,
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

class _WhatsAppSupportCard extends StatelessWidget {
  const _WhatsAppSupportCard({required this.phone, required this.onTap});

  final String phone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'chat_on_whatsapp'.tr,
      child: Material(
        color: ContactSupportView._primary,
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(22.r),
            child: Row(
              children: <Widget>[
                Container(
                  width: 58.r,
                  height: 58.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(
                    Icons.chat_rounded,
                    size: 30.r,
                    color: ContactSupportView._primary,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'chat_on_whatsapp'.tr,
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'fastest_response_recommended'.tr,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 25.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactActionCard extends StatelessWidget {
  const _ContactActionCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.helper,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final String helper;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title: $value',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22.r),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 104.h),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 17.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(color: const Color(0xFFE2EAE6)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 54.r,
                  height: 54.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8F2),
                    borderRadius: BorderRadius.circular(17.r),
                  ),
                  child: Icon(
                    icon,
                    size: 26.r,
                    color: ContactSupportView._primary,
                  ),
                ),

                SizedBox(width: 15.w),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: ContactSupportView._dark,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: ContactSupportView._primary,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        helper,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: ContactSupportView._muted,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 10.w),

                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F6F4),
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 20.r,
                    color: ContactSupportView._primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FacebookCommunityCard extends StatelessWidget {
  const _FacebookCommunityCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Join our Facebook community',
      child: Material(
        color: ContactSupportView._dark,
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.all(21.r),
            child: Row(
              children: <Widget>[
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: ContactSupportView._primary,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    size: 31.r,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Join our Facebook community',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'facebook_community_description'.tr,
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.35,
                          color: Colors.white.withValues(alpha: 0.68),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 22.r,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResponsePromiseCard extends StatelessWidget {
  const _ResponsePromiseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F2),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.verified_user_outlined,
            size: 22.r,
            color: ContactSupportView._primary,
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Text(
              'support_response_time'.tr,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: ContactSupportView._primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
