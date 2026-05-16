import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_constants.dart';
import '../../../../../core/themes/app_font.dart';
import '../models/pro_checkout_models.dart';

class ProBackHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBackTap;

  const ProBackHeader({
    super.key,
    required this.title,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBackTap,
              child: SizedBox(
                width: 30.w,
                height: 30.w,
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryGreen,
                  size: 20.w,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class ProHeroIllustration extends StatelessWidget {
  const ProHeroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 20.h,
            child: Container(
              width: 144.w,
              height: 96.h,
              decoration: BoxDecoration(
                color: AppColors.proHeroBookBg,
                borderRadius: BorderRadius.circular(26.r),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.homeNeutralShadow,
                    blurRadius: 18.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 120.w,
            height: 90.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.proHeroBookLight,
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.primaryGreen,
              size: 64.w,
            ),
          ),
          ...<Widget>[
            _floatingLetter('C', -88, -42, AppColors.proLetterTan),
            _floatingLetter('I', -8, -60, AppColors.primaryGreen),
            _floatingLetter('O', 76, -48, AppColors.primaryGreen),
            _floatingLetter('A', 104, -18, AppColors.proLetterTan),
            _floatingLetter('M', 104, 42, AppColors.proLetterTan),
            _floatingLetter('N', 40, 74, AppColors.proLetterTan),
            _floatingLetter('L', -24, 78, AppColors.primaryGreen),
            _floatingLetter('e', -96, -10, AppColors.homeOrange),
          ],
        ],
      ),
    );
  }

  Widget _floatingLetter(String letter, double x, double y, Color color) {
    return Transform.translate(
      offset: Offset(x.w, y.h),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: AppFont.font22.sp,
          fontWeight: FontWeight.w900,
          color: color.withValues(alpha: 0.78),
        ),
      ),
    );
  }
}

class ProFeatureGrid extends StatelessWidget {
  final List<ProFeatureModel> features;

  const ProFeatureGrid({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: features.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, int index) {
        return ProFeatureCard(feature: features[index]);
      },
    );
  }
}

class ProFeatureCard extends StatelessWidget {
  final ProFeatureModel feature;

  const ProFeatureCard({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final Color bg = _bgColor(feature.tone);
    final Color iconColor = _iconColor(feature.tone);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(kRadius48.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon(feature.iconName), color: iconColor, size: 24.w),
          ),
          SizedBox(height: 14.h),
          Text(
            feature.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.font16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimaryText,
              height: 1.12,
            ),
          ),
        ],
      ),
    );
  }

  Color _bgColor(String tone) {
    switch (tone) {
      case 'orange':
        return AppColors.proFeatureOrangeBg;
      case 'blue':
        return AppColors.proFeatureBlueBg;
      case 'purple':
        return AppColors.proFeaturePurpleBg;
      default:
        return AppColors.proFeatureGreenBg;
    }
  }

  Color _iconColor(String tone) {
    switch (tone) {
      case 'orange':
        return AppColors.proOrangeIcon;
      case 'blue':
        return AppColors.coursesChapterBlue;
      case 'purple':
        return AppColors.proPurpleIcon;
      default:
        return AppColors.primaryGreen;
    }
  }

  IconData _icon(String iconName) {
    switch (iconName) {
      case 'smart_toy':
        return Icons.smart_toy_outlined;
      case 'description':
        return Icons.description_outlined;
      case 'workspace_premium':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.school_outlined;
    }
  }
}

class ProCurrencyToggle extends StatelessWidget {
  final ProCurrency selectedCurrency;
  final ValueChanged<ProCurrency> onChanged;

  const ProCurrencyToggle({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.proToggleBg,
        borderRadius: BorderRadius.circular(kHomePillRadius.r),
      ),
      child: Row(
        children: <Widget>[
          _CurrencySegment(
            label: 'EUR',
            isSelected: selectedCurrency == ProCurrency.eur,
            onTap: () => onChanged(ProCurrency.eur),
          ),
          _CurrencySegment(
            label: 'BDT',
            isSelected: selectedCurrency == ProCurrency.bdt,
            onTap: () => onChanged(ProCurrency.bdt),
          ),
        ],
      ),
    );
  }
}

class _CurrencySegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencySegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : AppColors.transparent,
            borderRadius: BorderRadius.circular(kHomePillRadius.r),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.homeNeutralShadow,
                      blurRadius: 7.r,
                      offset: Offset(0, 2.h),
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppFont.font14.sp,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.primaryGreen : AppColors.bodyText,
            ),
          ),
        ),
      ),
    );
  }
}
