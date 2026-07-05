import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StatusColors {
  static const Color pageBg = Color(0xFFF6F7F6);
  static const Color darkText = Color(0xFF2E3234);
  static const Color bodyText = Color(0xFF626262);
  static const Color primaryGreen = Color(0xFF247207);
  static const Color deepGreen = Color(0xFF1F7800);
}

class ScrollableStatusBody extends StatelessWidget {
  final Widget child;

  const ScrollableStatusBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}

class StatusPageBackground extends StatelessWidget {
  final Widget child;
  final bool showColorGlows;
  final bool showKeyboardGlow;
  final bool showAccountGlow;

  const StatusPageBackground({
    super.key,
    required this.child,
    this.showColorGlows = false,
    this.showKeyboardGlow = false,
    this.showAccountGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(child: Container(color: StatusColors.pageBg)),

        if (showColorGlows) ...<Widget>[
          Positioned(
            left: -140.w,
            top: 134.h,
            child: const BlurGlow(
              color: Color(0xFF6DFF34),
              size: 220,
              blur: 105,
            ),
          ),
          Positioned(
            right: -128.w,
            top: 405.h,
            child: const BlurGlow(
              color: Color(0xFFB7DFFF),
              size: 235,
              blur: 100,
            ),
          ),
        ],

        if (showKeyboardGlow) ...<Widget>[
          Positioned(
            left: -82.w,
            top: 112.h,
            child: const BlurGlow(
              color: Color(0xFFDFF5DE),
              size: 170,
              blur: 80,
            ),
          ),
          Positioned(
            right: -95.w,
            top: 125.h,
            child: const BlurGlow(
              color: Color(0xFFDFEFFB),
              size: 185,
              blur: 80,
            ),
          ),
          Positioned(
            left: 74.w,
            top: 28.h,
            child: Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.42),
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 22.r,
                  ),
                ],
              ),
            ),
          ),
        ],

        if (showAccountGlow) ...<Widget>[
          Positioned(
            left: -120.w,
            top: 563.h,
            child: const BlurGlow(
              color: Color(0xFFE8F7EF),
              size: 175,
              blur: 85,
            ),
          ),
          Positioned(
            right: -116.w,
            top: 575.h,
            child: const BlurGlow(
              color: Color(0xFFE8F7EF),
              size: 175,
              blur: 85,
            ),
          ),
        ],

        Positioned.fill(child: child),
      ],
    );
  }
}

class BlurGlow extends StatelessWidget {
  final Color color;
  final double size;
  final double blur;

  const BlurGlow({
    super.key,
    required this.color,
    required this.size,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.45),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.75),
            blurRadius: blur.r,
            spreadRadius: 32.r,
          ),
        ],
      ),
    );
  }
}

class GreenShadowButton extends StatelessWidget {
  final double height;
  final double radius;
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  const GreenShadowButton({
    super.key,
    required this.height,
    required this.radius,
    required this.text,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: height - 7.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D5200),
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: height - 7.h,
                decoration: BoxDecoration(
                  color: StatusColors.deepGreen,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Icon(icon, color: Colors.white, size: 23.r),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThinOutlineButton extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  const ThinOutlineButton({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
    required this.text,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.36),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0xFFE1E1E1), width: 1.w),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 15.r, color: const Color(0xFF777777)),
              SizedBox(width: 8.w),
              Text(
                text,
                style: TextStyle(
                  color: const Color(0xFF6C6C6C),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BrightGreenButton extends StatelessWidget {
  final double width;
  final double height;
  final String text;
  final VoidCallback? onTap;

  const BrightGreenButton({
    super.key,
    required this.width,
    required this.height,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF72F236),
          borderRadius: BorderRadius.circular(35.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF72F236).withValues(alpha: 0.34),
              blurRadius: 28.r,
              offset: Offset(0, 13.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                color: const Color(0xFF173411),
                fontSize: 16.sp,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: 12.w),
            Icon(
              Icons.sync_rounded,
              color: const Color(0xFF173411),
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}

class GreenOutlineActionButton extends StatelessWidget {
  final double width;
  final double height;
  final String text;
  final VoidCallback? onTap;

  const GreenOutlineActionButton({
    super.key,
    required this.width,
    required this.height,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: StatusColors.primaryGreen, width: 2.w),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: StatusColors.primaryGreen,
              fontSize: 13.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.7,
            ),
          ),
        ),
      ),
    );
  }
}

class SkipPillButton extends StatelessWidget {
  final VoidCallback? onTap;

  const SkipPillButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 96.w,
        height: 49.h,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(color: Colors.black, width: 2.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'skip'.tr,
                      style: TextStyle(
                        color: const Color(0xFF707070),
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFF707070),
                      size: 18.r,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccentWordRow extends StatelessWidget {
  final String word;
  final IconData mark;
  final Color color;

  const AccentWordRow({
    super.key,
    required this.word,
    required this.mark,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          word,
          style: TextStyle(
            color: color,
            fontSize: 20.sp,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(width: 6.w),
        Icon(mark, size: 19.r, color: color),
      ],
    );
  }
}

class AssetOrNoInternetPlaceholder extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;

  const AssetOrNoInternetPlaceholder({
    super.key,
    required this.assetPath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment.center,
              radius: 0.78,
              colors: <Color>[
                Color(0xFF1D3F34),
                Color(0xFF294A42),
                Color(0xFFADCAC5),
              ],
            ),
            borderRadius: BorderRadius.circular(42.r),
          ),
          child: Center(
            child: Icon(
              Icons.cloud_off_rounded,
              color: const Color(0xFF217207),
              size: 94.r,
            ),
          ),
        );
      },
    );
  }
}

class AssetOrNoResultPlaceholder extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;

  const AssetOrNoResultPlaceholder({
    super.key,
    required this.assetPath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) {
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 124.r,
                height: 124.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE01822),
                    width: 18.r,
                  ),
                ),
              ),
              Icon(
                Icons.laptop_mac_rounded,
                size: 60.r,
                color: const Color(0xFF777777),
              ),
              Transform.rotate(
                angle: -0.78,
                child: Container(
                  width: 145.r,
                  height: 18.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE01822),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AssetOrKeyboardPlaceholder extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;

  const AssetOrKeyboardPlaceholder({
    super.key,
    required this.assetPath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFFDFF8D7),
                Color(0xFFE7F7EA),
                Color(0xFFE6F2FB),
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                right: 30.w,
                top: 34.h,
                child: Icon(
                  Icons.keyboard_rounded,
                  color: const Color(0xFF79BCD3),
                  size: 24.r,
                ),
              ),
              Positioned(
                left: 31.w,
                bottom: 31.h,
                child: Icon(
                  Icons.language_rounded,
                  color: const Color(0xFF95BE8E),
                  size: 27.r,
                ),
              ),
              Positioned(
                left: 66.w,
                top: 49.h,
                child: Transform.rotate(
                  angle: -0.07,
                  child: AccentKey(text: 'à', selected: false),
                ),
              ),
              Positioned(
                left: 145.w,
                top: 45.h,
                child: AccentKey(text: 'è', selected: true),
              ),
              Positioned(
                right: 65.w,
                top: 49.h,
                child: Transform.rotate(
                  angle: 0.07,
                  child: AccentKey(text: 'ò', selected: false),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 136.h,
                child: Center(
                  child: Container(
                    width: 64.w,
                    height: 39.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.r),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.13),
                          blurRadius: 12.r,
                          offset: Offset(0, 5.h),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(3.r),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.r),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(color: const Color(0xFF009246)),
                          ),
                          Expanded(child: Container(color: Colors.white)),
                          Expanded(
                            child: Container(color: const Color(0xFFCE2B37)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AccentKey extends StatelessWidget {
  final String text;
  final bool selected;

  const AccentKey({super.key, required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: selected ? 68.r : 64.r,
      height: selected ? 68.r : 64.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? StatusColors.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: selected ? 0.13 : 0.09),
            blurRadius: 12.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : StatusColors.primaryGreen,
          fontSize: 25.sp,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  const DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final RRect rRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rRect);

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dash != dash ||
        oldDelegate.gap != gap;
  }
}
