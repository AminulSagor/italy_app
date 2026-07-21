import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/shop_order_history_controller.dart';
import '../models/shop_order_models.dart';

class OrderHistoryView extends GetView<ShopOrderHistoryController> {
  const OrderHistoryView({super.key});

  static const Color _background = Color(0xFFF3F3F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.loadOrderHistory(reset: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
            child: Column(
              children: <Widget>[
                const _HistoryTopBar(),
                SizedBox(height: 40.h),
                const _FilterTabs(),
                SizedBox(height: 24.h),
                const _SearchBox(),
                SizedBox(height: 24.h),
                const _OrdersList(),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryTopBar extends StatelessWidget {
  const _HistoryTopBar();

  static const Color _green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.r,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 24.r,
                  color: _green,
                ),
              ),
            ),
          ),
          Text(
            'order_history'.tr,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: _green,
              letterSpacing: -0.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends GetView<ShopOrderHistoryController> {
  const _FilterTabs();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.orderHistoryFilters.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (BuildContext context, int index) {
          final String title = controller.orderHistoryFilters[index];
          return Obx(() {
            final bool selected =
                controller.selectedOrderHistoryFilter.value == title;
            return GestureDetector(
              onTap: () => controller.selectOrderHistoryFilter(title),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 50.h,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF267A05) : Colors.white,
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF267A05)
                        : const Color(0xFFC9DDBF),
                    width: 1.5.w,
                  ),
                  boxShadow: selected
                      ? <BoxShadow>[
                          BoxShadow(
                            color: const Color(
                              0xFF267A05,
                            ).withValues(alpha: 0.22),
                            blurRadius: 14.r,
                            offset: Offset(0, 7.h),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: selected ? Colors.white : const Color(0xFF267A05),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _SearchBox extends GetView<ShopOrderHistoryController> {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: const Color(0xFFD9D9D9)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: TextField(
        controller: controller.orderSearchTextController,
        onChanged: controller.onOrderSearchChanged,
        cursorColor: const Color(0xFF267A05),
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF333333),
        ),
        decoration: InputDecoration(
          hintText: 'gen_search_orders'.tr,
          hintStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9A9A9A),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 26.r,
            color: const Color(0xFF555555),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 16.h),
        ),
      ),
    );
  }
}

class _OrdersList extends GetView<ShopOrderHistoryController> {
  const _OrdersList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingHistory.value &&
          controller.orderHistoryItems.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: const CircularProgressIndicator(),
        );
      }

      final List<StoreOrderHistoryItemModel> orders =
          controller.filteredOrderHistoryItems;
      if (orders.isEmpty) return const _EmptyOrdersCard();

      return Column(
        children: <Widget>[
          ...List<Widget>.generate(
            orders.length,
            (int index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == orders.length - 1 ? 0 : 16.h,
              ),
              child: _OrderCard(item: orders[index]),
            ),
          ),
          if (controller.historyHasMore) ...<Widget>[
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.isLoadingMoreHistory.value
                    ? null
                    : () => controller.loadOrderHistory(reset: false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF267A05),
                  side: const BorderSide(color: Color(0xFF267A05)),
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
                child: controller.isLoadingMoreHistory.value
                    ? SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('load_more'.tr),
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _EmptyOrdersCard extends StatelessWidget {
  const _EmptyOrdersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34.r),
      ),
      child: Text(
        'no_orders_found'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF666666),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.item});

  final StoreOrderHistoryItemModel item;

  static const Color _text = Color(0xFF2D3032);
  static const Color _muted = Color(0xFF5F6265);
  static const Color _green = Color(0xFF267A05);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(42.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _OrderIcon(category: item.category),
              SizedBox(width: 18.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.sp,
                        height: 1.38,
                        fontWeight: FontWeight.w900,
                        color: _text,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.formattedDate,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    item.formattedAmount.isNotEmpty
                        ? item.formattedAmount
                        : '${item.currency} ${item.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w900,
                      color: _text,
                      letterSpacing: -0.25,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _StatusLabel(status: item.status),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(height: 1.h, color: const Color(0xFFE8E8E8)),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                text: 'id'.tr,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                  letterSpacing: 0.6,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: item.orderNumber.isNotEmpty
                        ? item.orderNumber
                        : item.id,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderIcon extends StatelessWidget {
  const _OrderIcon({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final bool course = category == 'course';
    final bool streak = category == 'streak_freeze';
    final bool cv = category == 'cv_credit';
    final Color background = course
        ? const Color(0xFFFF9700)
        : streak
        ? const Color(0xFFFFE7A3)
        : cv
        ? const Color(0xFFD7F3CA)
        : const Color(0xFFAED2FF);
    final Color foreground = course
        ? const Color(0xFF905000)
        : streak
        ? const Color(0xFF8A6400)
        : cv
        ? const Color(0xFF267A05)
        : const Color(0xFF0065A8);
    final IconData icon = course
        ? Icons.school_outlined
        : streak
        ? Icons.ac_unit_rounded
        : cv
        ? Icons.description_outlined
        : Icons.mic_none_rounded;

    return Container(
      width: 48.r,
      height: 48.r,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Icon(icon, size: 24.r, color: foreground),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final String normalized = status.toLowerCase();
    final bool successful = normalized == 'completed' || normalized == 'paid';
    final Color color = successful
        ? const Color(0xFF267A05)
        : normalized == 'refunded'
        ? const Color(0xFFB26A00)
        : const Color(0xFF777777);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          status.isEmpty ? 'pending'.tr : status.capitalizeFirst ?? status,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 0.35,
          ),
        ),
      ],
    );
  }
}


