import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/ai_content_report_model.dart';
import '../views/ai_content_report_bottom_sheet.dart';

class AiReportButton extends StatelessWidget {
  const AiReportButton({
    required this.source,
    super.key,
  });

  final AiContentReportSource source;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: source.hasAutomaticAttachment
          ? () {
        showAiContentReportBottomSheet(
          context: context,
          source: source,
        );
      }
          : null,
      icon: const Icon(
        Icons.flag_outlined,
        size: 17,
      ),
      label: Text(
        'ai_report_action'.tr,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}