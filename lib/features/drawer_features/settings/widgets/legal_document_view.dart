import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/legal_document_models.dart';
import 'settings_ui_widgets.dart';
import 'package:get/get.dart';

class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView({
    super.key,
    required this.document,
    required this.icon,
  });

  final LegalDocumentModel document;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUi.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 34.h, 24.w, 52.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SettingsTopBar(title: document.title),
              SizedBox(height: 24.h),
              _LegalHeader(
                icon: icon,
                effectiveDate: document.effectiveDate,
                introduction: document.introduction,
              ),
              SizedBox(height: 20.h),
              ...document.sections.map(
                (LegalSectionModel section) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _LegalSectionCard(section: section),
                ),
              ),
              SizedBox(height: 6.h),
              Center(
                child: Text(
                  'italir_pothe_document_effectivedate_touppercase'.trParams(<String, String>{'touppercase': document.effectiveDate.toUpperCase().toString()}),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF777A7D),
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

class _LegalHeader extends StatelessWidget {
  const _LegalHeader({
    required this.icon,
    required this.effectiveDate,
    required this.introduction,
  });

  final IconData icon;
  final String effectiveDate;
  final String introduction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8E4),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: const Color(0xFFCDEBC1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 52.r,
            height: 52.r,
            decoration: const BoxDecoration(
              color: Color(0xFF79F535),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: SettingsUi.darkGreen, size: 27.r),
          ),
          SizedBox(height: 18.h),
          Text(
            effectiveDate,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: SettingsUi.darkGreen,
            ),
          ),
          SizedBox(height: 10.h),
          SelectableText(
            introduction,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: SettingsUi.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSectionCard extends StatelessWidget {
  const _LegalSectionCard({required this.section});

  final LegalSectionModel section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: const Color(0xFFE7E7E7)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            section.title,
            style: TextStyle(
              fontSize: 17.sp,
              height: 1.25,
              fontWeight: FontWeight.w900,
              color: SettingsUi.darkGreen,
            ),
          ),
          if (section.paragraphs.isNotEmpty) SizedBox(height: 13.h),
          ...section.paragraphs.indexed.map(
            ((int, String) item) => Padding(
              padding: EdgeInsets.only(
                bottom: item.$1 == section.paragraphs.length - 1 ? 0 : 12.h,
              ),
              child: SelectableText(
                item.$2,
                style: _bodyStyle,
              ),
            ),
          ),
          if (section.bullets.isNotEmpty) SizedBox(height: 13.h),
          ...section.bullets.map(
            (String bullet) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 7.h),
                    child: Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: const BoxDecoration(
                        color: SettingsUi.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(width: 11.w),
                  Expanded(child: SelectableText(bullet, style: _bodyStyle)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _bodyStyle => TextStyle(
        fontSize: 14.sp,
        height: 1.58,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF44484B),
      );
}
