import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/legal_document_models.dart';
import '../models/settings_localization.dart';
import 'settings_ui_widgets.dart';

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
      backgroundColor: SettingsUi.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 30.h),
          children: <Widget>[
            SettingsTopBar(title: document.title),
            SizedBox(height: 16.h),
            _DocumentHeader(document: document, icon: icon),
            SizedBox(height: 12.h),
            for (final LegalSectionModel section in document.sections) ...<Widget>[
              _LegalSection(section: section),
              SizedBox(height: 10.h),
            ],
            SizedBox(height: 8.h),
            Text(
              SettingsL10n.text('legal_contact'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.4,
                color: SettingsUi.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentHeader extends StatelessWidget {
  const _DocumentHeader({required this.document, required this.icon});

  final LegalDocumentModel document;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F2),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46.r,
                height: 46.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24.r, color: SettingsUi.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      document.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: SettingsUi.text,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      document.effectiveDate,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: SettingsUi.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SelectableText(
            document.introduction,
            style: TextStyle(
              fontSize: 12.5.sp,
              height: 1.55,
              color: SettingsUi.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.section});

  final LegalSectionModel section;

  @override
  Widget build(BuildContext context) {
    final TextStyle bodyStyle = TextStyle(
      fontSize: 12.5.sp,
      height: 1.55,
      color: const Color(0xFF49534F),
    );

    return Container(
      padding: EdgeInsets.all(17.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: SettingsUi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            section.title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: SettingsUi.text,
            ),
          ),
          if (section.paragraphs.isNotEmpty) SizedBox(height: 10.h),
          for (int index = 0; index < section.paragraphs.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == section.paragraphs.length - 1 ? 0 : 9.h,
              ),
              child: SelectableText(
                section.paragraphs[index],
                style: bodyStyle,
              ),
            ),
          if (section.bullets.isNotEmpty) SizedBox(height: 10.h),
          for (int index = 0; index < section.bullets.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == section.bullets.length - 1 ? 0 : 8.h,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 7.h),
                    child: Container(
                      width: 5.r,
                      height: 5.r,
                      decoration: const BoxDecoration(
                        color: SettingsUi.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(width: 9.w),
                  Expanded(
                    child: SelectableText(
                      section.bullets[index],
                      style: bodyStyle,
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
