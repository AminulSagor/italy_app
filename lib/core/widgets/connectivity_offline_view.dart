import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/connectivity_service.dart';
import '../themes/app_colors.dart';

/// Keeps the active Navigator mounted while an offline surface blocks input.
///
/// Removing the Navigator from `MaterialApp.builder` disposes route state and
/// leaves GetX without an overlay for dialogs/snackbars triggered by requests
/// that fail during the connectivity transition.
class ConnectivityOfflineGate extends StatelessWidget {
  const ConnectivityOfflineGate({
    super.key,
    required this.isOffline,
    required this.child,
    this.header,
  });

  final bool isOffline;
  final Widget child;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (header case final Widget headerWidget) headerWidget,
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ExcludeSemantics(
                excluding: isOffline,
                child: TickerMode(
                  enabled: !isOffline,
                  child: IgnorePointer(ignoring: isOffline, child: child),
                ),
              ),
              if (isOffline)
                const Positioned.fill(child: ConnectivityOfflineView()),
            ],
          ),
        ),
      ],
    );
  }
}

class ConnectivityOfflineView extends StatelessWidget {
  const ConnectivityOfflineView({super.key});

  @override
  Widget build(BuildContext context) {
    final ConnectivityService connectivityService =
        Get.find<ConnectivityService>();

    return Material(
      color: AppColors.homeBackground,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      size: 48,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'no_internet_title'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF202723),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'no_internet_message'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF68716C),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Obx(() {
                    final bool isChecking =
                        connectivityService.isChecking.value;

                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isChecking
                            ? null
                            : () async {
                                await connectivityService.checkNow();
                              },
                        icon: isChecking
                            ? const SizedBox(
                                width: 19,
                                height: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded),
                        label: Text(
                          isChecking
                              ? 'checking_connection'.tr
                              : 'try_again'.tr,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primaryGreen
                              .withValues(alpha: 0.55),
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
