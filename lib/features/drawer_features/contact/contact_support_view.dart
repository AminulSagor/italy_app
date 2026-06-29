import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'contact_controller.dart';

class ContactSupportView extends GetView<ContactController> {
  const ContactSupportView({super.key});

  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _green = Color(0xFF267A05);
  static const Color _darkGreen = Color(0xFF217000);
  static const Color _text = Color(0xFF2D3032);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(40.w, 39.h, 40.w, 58.h),
          child: Column(
            children: <Widget>[
              const _ContactTopBar(),

              // SizedBox(height: 53.h),
              Image.asset(
                'assets/heroes/Hero Section customer support.png',
                width: double.infinity,
              ),

              // const _SupportAvatar(),
              // SizedBox(height: 23.h),

              // Text(
              //   'How can we help you?',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: 30.sp,
              //     height: 1.12,
              //     fontWeight: FontWeight.w900,
              //     color: const Color(0xFF185E04),
              //     letterSpacing: -0.75,
              //   ),
              // ),
              // SizedBox(height: 9.h),

              // Text(
              //   'Select a way to connect with our team.',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: 16.sp,
              //     fontWeight: FontWeight.w500,
              //     color: const Color(0xFF666666),
              //     letterSpacing: -0.1,
              //   ),
              // ),
              SizedBox(height: 35.h),
              GestureDetector(
                onTap: controller.chatOnWhatsapp,
                child: SizedBox(
                  height: 210.h,
                  width: double.infinity,
                  child: Transform.scale(
                    scale: 1.45,
                    child: Image.asset(
                      'assets/heroes/Priority Card (WhatsApp).png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              //_WhatsAppCard(onTap: controller.chatOnWhatsapp),
              SizedBox(height: 16.h),

              Row(
                children: <Widget>[
                  Expanded(
                    child: _SmallContactCard(
                      icon: Icons.call_rounded,
                      title: 'gen_call_support'.tr.tr,
                      subtitle: 'gen_39_123_456_7890'.tr.tr,
                      bgColor: const Color(0xFFE8FFDD),
                      iconBgColor: Colors.white,
                      iconColor: _green,
                      subtitleColor: _green,
                      onTap: controller.callSupport,
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: _SmallContactCard(
                      icon: Icons.email_rounded,
                      title: 'gen_send_email'.tr.tr,
                      subtitle: 'gen_support_lumina_it'.tr.tr,
                      bgColor: Colors.white,
                      iconBgColor: const Color(0xFFF1F1F1),
                      iconColor: const Color(0xFF4C4C4C),
                      subtitleColor: const Color(0xFF555555),
                      onTap: controller.sendEmail,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 31.h),

              _FacebookCommunityCard(onTap: controller.joinFacebookCommunity),

              SizedBox(height: 62.h),

              Text(
                '🛡️ Our Guarantee: We aim to respond to all\ninquiries within 24 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8B8B8B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactTopBar extends StatelessWidget {
  const _ContactTopBar();

  static const Color _green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.r,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.045),
                      blurRadius: 12.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 25.r,
                  color: _green,
                ),
              ),
            ),
          ),
          Text(
            'Help & Support',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: _green,
              letterSpacing: -0.35,
            ),
          ),
        ],
      ),
    );
  }
}

// class _SupportAvatar extends StatelessWidget {
//   const _SupportAvatar();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 156.r,
//       height: 156.r,
//       padding: EdgeInsets.all(5.r),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.circle,
//         boxShadow: <BoxShadow>[
//           BoxShadow(
//             color: const Color(0xFF79F535).withValues(alpha: 0.28),
//             blurRadius: 42.r,
//             spreadRadius: 8.r,
//           ),
//         ],
//       ),
//       // child: ClipOval(
//       //   child: Image.asset(
//       //     'assets/support/support_agent.png',
//       //     fit: BoxFit.cover,
//       //     errorBuilder: (_, __, ___) => Container(
//       //       decoration: const BoxDecoration(
//       //         shape: BoxShape.circle,
//       //         gradient: LinearGradient(
//       //           begin: Alignment.topCenter,
//       //           end: Alignment.bottomCenter,
//       //           colors: <Color>[Color(0xFF315F5C), Color(0xFF173D45)],
//       //         ),
//       //       ),
//       //       child: Icon(
//       //         Icons.support_agent_rounded,
//       //         size: 104.r,
//       //         color: Colors.white.withValues(alpha: 0.95),
//       //       ),
//       //     ),
//       //   ),
//       // ),
//     );
//   }
// }

// class _WhatsAppCard extends StatelessWidget {
//   final VoidCallback onTap;

//   const _WhatsAppCard({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 210.h,
//         width: double.infinity,
//         padding: EdgeInsets.fromLTRB(32.w, 32.h, 26.w, 30.h),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(52.r),
//           gradient: const LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: <Color>[Color(0xFF46D900), Color(0xFF217000)],
//           ),
//           boxShadow: <BoxShadow>[
//             BoxShadow(
//               color: const Color(0xFF79F535).withValues(alpha: 0.28),
//               blurRadius: 34.r,
//               offset: Offset(-14.w, 18.h),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: <Widget>[
//             Positioned(
//               right: -4.w,
//               top: -8.h,
//               child: Container(
//                 width: 100.w,
//                 height: 100.h,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha: 0.18),
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//               ),
//             ),
//             Positioned(
//               right: 20.w,
//               top: 24.h,
//               child: CustomPaint(
//                 size: Size(78.w, 78.h),
//                 painter: _BubbleTailPainter(),
//               ),
//             ),
//             Positioned(
//               right: 6.w,
//               top: 31.h,
//               child: Container(
//                 height: 29.h,
//                 padding: EdgeInsets.symmetric(horizontal: 13.w),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha: 0.22),
//                   borderRadius: BorderRadius.circular(100.r),
//                   border: Border.all(
//                     color: Colors.white.withValues(alpha: 0.35),
//                   ),
//                 ),
//                 child: Row(
//                   children: <Widget>[
//                     Container(
//                       width: 11.r,
//                       height: 11.r,
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     SizedBox(width: 8.w),
//                     Text(
//                       'ONLINE NOW',
//                       style: TextStyle(
//                         fontSize: 10.sp,
//                         fontWeight: FontWeight.w900,
//                         color: Colors.white,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Container(
//               width: 64.r,
//               height: 64.r,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(22.r),
//               ),
//               child: Icon(
//                 Icons.chat_bubble_outline_rounded,
//                 size: 33.r,
//                 color: const Color(0xFF36B900),
//               ),
//             ),
//             Positioned(
//               left: 0,
//               bottom: 1.h,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     'Chat on WhatsApp',
//                     style: TextStyle(
//                       fontSize: 24.sp,
//                       height: 1,
//                       fontWeight: FontWeight.w900,
//                       color: Colors.white,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   SizedBox(height: 6.h),
//                   Text(
//                     'Fastest response for learning help.',
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white.withValues(alpha: 0.84),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _BubbleTailPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = Colors.white.withValues(alpha: 0.16)
//       ..style = PaintingStyle.fill;

//     final Path path = Path()
//       ..moveTo(0, 0)
//       ..lineTo(size.width, 0)
//       ..lineTo(0, size.height)
//       ..close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

class _SmallContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color iconBgColor;
  final Color iconColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _SmallContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.subtitleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 154.h,
        padding: EdgeInsets.fromLTRB(24.w, 25.h, 16.w, 20.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(46.r),
          border: Border.all(
            color: bgColor == Colors.white
                ? const Color(0xFFEDEDED)
                : Colors.transparent,
          ),
          boxShadow: bgColor == Colors.white
              ? <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 15.r,
                    offset: Offset(0, 7.h),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, size: 23.r, color: iconColor),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2D3032),
                letterSpacing: -0.25,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: subtitleColor,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FacebookCommunityCard extends StatelessWidget {
  final VoidCallback onTap;

  const _FacebookCommunityCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 145.h,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 20.w, 22.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3030),
          borderRadius: BorderRadius.circular(46.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 27.r,
              offset: Offset(0, 15.h),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -2.w,
              bottom: -1.h,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 14.r,
                    height: 14.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 19.r,
                    height: 19.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF48DC00),
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    size: 35.r,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 18.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Join our Facebook\nCommunity',
                        style: TextStyle(
                          fontSize: 18.sp,
                          height: 1.14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.35,
                        ),
                      ),
                      SizedBox(height: 7.h),
                      Text(
                        'Connect with 10k+ Bengali learners in\nItaly.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.48),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
