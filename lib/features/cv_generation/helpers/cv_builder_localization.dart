import 'package:get/get.dart';

import '../models/cv_template_model.dart';

String cvSectionLabel(CvSectionDefinition section) {
  return _translationOrFallback('cvb_section_${section.key}', section.label);
}

String cvFieldLabel(CvFieldDefinition field) {
  final String normalizedKey = field.key.replaceAll('.', '_');
  return _translationOrFallback('cvb_field_$normalizedKey', field.label);
}

String cvOptionLabel(String option) {
  const Map<String, String> keys = <String, String>{
    'full-time': 'cvb_option_full_time',
    'part-time': 'cvb_option_part_time',
    'contract': 'cvb_option_contract',
    'freelance': 'cvb_option_freelance',
    'internship': 'cvb_option_internship',
    'temporary': 'cvb_option_temporary',
    'apprenticeship': 'cvb_option_apprenticeship',
    'native': 'cvb_option_native',
    'fluent': 'cvb_option_fluent',
    'professional': 'cvb_option_professional',
    'intermediate': 'cvb_option_intermediate',
    'basic': 'cvb_option_basic',
  };

  final String? key = keys[option.trim().toLowerCase()];
  return key == null ? option : _translationOrFallback(key, option);
}

String cvCategoryLabel(String category) {
  final String normalized = category.trim().toLowerCase();
  const Map<String, String> keys = <String, String>{
    'professional': 'cvb_category_professional',
    'modern': 'cvb_category_modern',
    'classic': 'cvb_category_classic',
    'creative': 'cvb_category_creative',
    'minimal': 'cvb_category_minimal',
    'academic': 'cvb_category_academic',
    'hospitality': 'cvb_category_hospitality',
  };

  final String? key = keys[normalized];
  if (key != null) return _translationOrFallback(key, category);

  return category
      .split(RegExp(r'[-_\s]+'))
      .where((String part) => part.isNotEmpty)
      .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _translationOrFallback(String key, String fallback) {
  final String translated = key.tr;
  return translated == key ? fallback : translated;
}
