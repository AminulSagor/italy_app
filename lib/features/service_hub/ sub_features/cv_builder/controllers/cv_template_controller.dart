import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/themes/app_colors.dart';

class CvTemplateController extends GetxController {
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt selectedTemplateIndex = 0.obs;
  final RxInt selectedColorIndex = 0.obs;

  final List<String> categories = <String>[
    'All',
    'Hotel',
    'Culinary',
    'Bar & Cafe',
  ];

  final List<Color> colors = <Color>[
    AppColors.primaryGreen,
    AppColors.legacyColorFF646C7A,
    AppColors.legacyColorFF0B4A7D,
    AppColors.adminBrown,
  ];

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  void selectTemplate(int index) {
    selectedTemplateIndex.value = index;
  }

  void selectColor(int index) {
    selectedColorIndex.value = index;
  }
}