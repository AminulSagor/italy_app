import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_error_handler.dart';
import '../models/shop_order_models.dart';
import '../services/shop_api_service.dart';
import '../shop_controller.dart';

class ShopOrderHistoryController extends GetxController {
  ShopOrderHistoryController({required ShopApiService apiService})
    : _apiService = apiService;

  final ShopApiService _apiService;

  final RxBool isLoadingHistory = false.obs;
  final RxBool isLoadingMoreHistory = false.obs;
  final TextEditingController orderSearchTextController =
      TextEditingController();
  final RxString selectedOrderHistoryFilter =
      OrderHistoryFilterTitles.allOrders.obs;
  final RxString orderSearchQuery = ''.obs;
  final RxList<StoreOrderHistoryItemModel> orderHistoryItems =
      <StoreOrderHistoryItemModel>[].obs;
  final RxInt orderHistoryPage = 1.obs;
  final RxInt orderHistoryTotalPages = 1.obs;
  Timer? _searchDebounce;

  final List<String> orderHistoryFilters = const <String>[
    OrderHistoryFilterTitles.allOrders,
    OrderHistoryFilterTitles.courses,
    OrderHistoryFilterTitles.aiRefills,
    OrderHistoryFilterTitles.streakFreezes,
    OrderHistoryFilterTitles.cvCredits,
  ];

  @override
  void onInit() {
    super.onInit();
    loadOrderHistory(reset: true);
  }

  List<StoreOrderHistoryItemModel> get filteredOrderHistoryItems =>
      orderHistoryItems;

  bool get historyHasMore =>
      orderHistoryPage.value < orderHistoryTotalPages.value;

  Future<void> loadOrderHistory({required bool reset}) async {
    if (reset) {
      if (isLoadingHistory.value) return;
      isLoadingHistory.value = true;
      orderHistoryPage.value = 1;
    } else {
      if (isLoadingMoreHistory.value || !historyHasMore) return;
      isLoadingMoreHistory.value = true;
    }

    final int page = reset ? 1 : orderHistoryPage.value + 1;
    final ApiResult<StoreOrderHistoryResponseModel> result =
        await ApiErrorHandler.call<StoreOrderHistoryResponseModel>(
          () => _apiService.getOrderHistory(
            category: _historyCategory(selectedOrderHistoryFilter.value),
            search: orderSearchQuery.value,
            page: page,
          ),
        );

    if (result.isSuccess && result.data != null) {
      final StoreOrderHistoryResponseModel data = result.data!;
      if (reset) {
        orderHistoryItems.assignAll(data.items);
      } else {
        orderHistoryItems.addAll(data.items);
      }
      orderHistoryPage.value = data.page;
      orderHistoryTotalPages.value = data.totalPages;
    }

    isLoadingHistory.value = false;
    isLoadingMoreHistory.value = false;
  }

  void selectOrderHistoryFilter(String filter) {
    if (selectedOrderHistoryFilter.value == filter) return;
    selectedOrderHistoryFilter.value = filter;
    loadOrderHistory(reset: true);
  }

  void onOrderSearchChanged(String value) {
    orderSearchQuery.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () => loadOrderHistory(reset: true),
    );
  }

  void contactOrderSupport() {
    Get.snackbar('Support', 'Please contact support from the Help Center.');
  }

  String _historyCategory(String title) {
    switch (title) {
      case OrderHistoryFilterTitles.courses:
        return 'course';
      case OrderHistoryFilterTitles.aiRefills:
        return 'ai_refill';
      case OrderHistoryFilterTitles.streakFreezes:
        return 'streak_freeze';
      case OrderHistoryFilterTitles.cvCredits:
        return 'cv_credit';
      default:
        return 'all';
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    orderSearchTextController.dispose();
    super.onClose();
  }
}
