import 'package:flutter/material.dart';

class GuideFaqItem {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<GuideStepItem> steps;
  final String? videoAssetPath;
  final String? expertTip;

  const GuideFaqItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.steps,
    this.videoAssetPath,
    this.expertTip,
  });

  bool get hasVideo => videoAssetPath?.trim().isNotEmpty ?? false;

  bool get hasExpertTip => expertTip?.trim().isNotEmpty ?? false;
}

class GuideStepItem {
  final String number;
  final String title;
  final String description;
  final Color color;
  final Color textColor;

  const GuideStepItem({
    required this.number,
    required this.title,
    required this.description,
    required this.color,
    required this.textColor,
  });
}
