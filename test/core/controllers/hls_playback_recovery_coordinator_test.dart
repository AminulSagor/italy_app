import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/core/controllers/hls_playback_recovery_coordinator.dart';
import 'package:video_player/video_player.dart';

void main() {
  test('refreshes before the API-provided expiry', () async {
    final DateTime now = DateTime.utc(2026, 9, 21, 10);
    final List<HlsPlaybackRecoveryReason> reasons =
        <HlsPlaybackRecoveryReason>[];
    final HlsPlaybackRecoveryCoordinator coordinator =
        HlsPlaybackRecoveryCoordinator(
          now: () => now,
          expiryLeadTime: const Duration(milliseconds: 20),
          onRecover: ({required reason, required refreshAccess}) async {
            expect(refreshAccess, isTrue);
            reasons.add(reason);
            return true;
          },
          onRecoveryExhausted: (_) {},
        );

    coordinator.updateAccess(
      expiresAt: now.add(const Duration(milliseconds: 50)),
      requiresSignedAccess: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(reasons, isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(reasons, <HlsPlaybackRecoveryReason>[
      HlsPlaybackRecoveryReason.accessExpiring,
    ]);

    coordinator.dispose();
  });

  test('allows only one controller operation at a time', () async {
    final Completer<bool> recoveryResult = Completer<bool>();
    int recoveryCalls = 0;
    final HlsPlaybackRecoveryCoordinator coordinator =
        HlsPlaybackRecoveryCoordinator(
          onRecover: ({required reason, required refreshAccess}) {
            recoveryCalls++;
            return recoveryResult.future;
          },
          onRecoveryExhausted: (_) {},
        );

    final Future<bool> first = coordinator.recoverNow();
    final bool second = await coordinator.recoverNow();

    expect(second, isFalse);
    expect(recoveryCalls, 1);

    recoveryResult.complete(true);
    expect(await first, isTrue);
    coordinator.dispose();
  });

  test('reloads a stalled player without refreshing valid access', () async {
    bool? requestedAccessRefresh;
    final HlsPlaybackRecoveryCoordinator coordinator =
        HlsPlaybackRecoveryCoordinator(
          stallTimeout: const Duration(milliseconds: 10),
          onRecover: ({required reason, required refreshAccess}) async {
            expect(reason, HlsPlaybackRecoveryReason.bufferingStalled);
            requestedAccessRefresh = refreshAccess;
            return true;
          },
          onRecoveryExhausted: (_) {},
        );

    coordinator.updateAccess(expiresAt: null, requiresSignedAccess: false);
    coordinator.updatePlaybackValue(
      const VideoPlayerValue(
        duration: Duration(minutes: 30),
        isInitialized: true,
        isBuffering: true,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(requestedAccessRefresh, isFalse);
    coordinator.dispose();
  });

  test(
    'player errors refresh access when credentials are near expiry',
    () async {
      final DateTime now = DateTime.now();
      bool? requestedAccessRefresh;
      final HlsPlaybackRecoveryCoordinator coordinator =
          HlsPlaybackRecoveryCoordinator(
            now: () => now,
            onRecover: ({required reason, required refreshAccess}) async {
              expect(reason, HlsPlaybackRecoveryReason.playerError);
              requestedAccessRefresh = refreshAccess;
              return true;
            },
            onRecoveryExhausted: (_) {},
          );

      coordinator.updateAccess(
        expiresAt: now.add(const Duration(seconds: 30)),
        requiresSignedAccess: true,
      );
      coordinator.updatePlaybackValue(
        const VideoPlayerValue.erroneous('HLS segment request failed'),
      );

      await Future<void>.delayed(Duration.zero);
      expect(requestedAccessRefresh, isTrue);
      coordinator.dispose();
    },
  );

  test('a repeated automatic recovery forces fresh access', () async {
    final List<bool> accessRefreshes = <bool>[];
    final HlsPlaybackRecoveryCoordinator coordinator =
        HlsPlaybackRecoveryCoordinator(
          onRecover: ({required reason, required refreshAccess}) async {
            accessRefreshes.add(refreshAccess);
            return true;
          },
          onRecoveryExhausted: (_) {},
        );

    const VideoPlayerValue error = VideoPlayerValue.erroneous(
      'HLS segment request failed',
    );
    coordinator.updatePlaybackValue(error);
    await Future<void>.delayed(Duration.zero);
    coordinator.updatePlaybackValue(error);
    await Future<void>.delayed(Duration.zero);

    expect(accessRefreshes, <bool>[false, true]);
    coordinator.dispose();
  });

  test('automatic failures stop after the retry limit', () async {
    int recoveryCalls = 0;
    final Completer<HlsPlaybackRecoveryReason> exhausted =
        Completer<HlsPlaybackRecoveryReason>();
    final HlsPlaybackRecoveryCoordinator coordinator =
        HlsPlaybackRecoveryCoordinator(
          retryBaseDelay: const Duration(milliseconds: 5),
          onRecover: ({required reason, required refreshAccess}) async {
            recoveryCalls++;
            return false;
          },
          onRecoveryExhausted: exhausted.complete,
        );

    coordinator.updatePlaybackValue(
      const VideoPlayerValue.erroneous('HLS segment request failed'),
    );

    expect(
      await exhausted.future.timeout(const Duration(milliseconds: 100)),
      HlsPlaybackRecoveryReason.playerError,
    );
    expect(recoveryCalls, 2);
    coordinator.dispose();
  });

  test('dispose cancels a pending access refresh', () async {
    final DateTime now = DateTime.utc(2026, 9, 21, 10);
    int recoveryCalls = 0;
    final HlsPlaybackRecoveryCoordinator coordinator =
        HlsPlaybackRecoveryCoordinator(
          now: () => now,
          expiryLeadTime: const Duration(milliseconds: 10),
          onRecover: ({required reason, required refreshAccess}) async {
            recoveryCalls++;
            return true;
          },
          onRecoveryExhausted: (_) {},
        );

    coordinator.updateAccess(
      expiresAt: now.add(const Duration(milliseconds: 30)),
      requiresSignedAccess: true,
    );
    coordinator.dispose();

    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(recoveryCalls, 0);
  });
}
