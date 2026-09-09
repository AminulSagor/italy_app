import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

enum _OutgoingCallTone { none, calling, ringing }

class CallRingbackService {
  static final AudioContext _toneAudioContext = AudioContext(
    android: const AudioContextAndroid(
      audioMode: AndroidAudioMode.normal,
      stayAwake: true,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.voiceCommunicationSignalling,
      audioFocus: AndroidAudioFocus.gainTransient,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playAndRecord,
      options: <AVAudioSessionOptions>{
        AVAudioSessionOptions.defaultToSpeaker,
        AVAudioSessionOptions.allowBluetooth,
      },
    ),
  );

  AudioPlayer? _player;

  _OutgoingCallTone _currentTone = _OutgoingCallTone.none;
  _OutgoingCallTone _requestedTone = _OutgoingCallTone.none;

  Future<void> _operationTail = Future<void>.value();

  bool _isDisposed = false;
  int _requestVersion = 0;

  Future<void> startCalling({bool forceRestart = false}) {
    return _requestTone(
      tone: _OutgoingCallTone.calling,
      assetPath: 'audio/caller_calling.mp3',
      volume: 0.45,
      forceRestart: forceRestart,
    );
  }

  Future<void> startRinging({bool forceRestart = false}) {
    return _requestTone(
      tone: _OutgoingCallTone.ringing,
      assetPath: 'audio/caller_ringback.mp3',
      volume: 0.55,
      forceRestart: forceRestart,
    );
  }

  Future<void> _requestTone({
    required _OutgoingCallTone tone,
    required String assetPath,
    required double volume,
    required bool forceRestart,
  }) {
    if (_isDisposed) {
      return Future<void>.value();
    }

    final int requestVersion = ++_requestVersion;
    _requestedTone = tone;

    return _enqueue(() async {
      if (!_isRequestValid(requestVersion, tone)) {
        return;
      }

      if (!forceRestart && _currentTone == tone && _player != null) {
        return;
      }

      final AudioPlayer? previousPlayer = _player;

      _player = null;
      _currentTone = _OutgoingCallTone.none;

      await _disposePlayer(previousPlayer);

      if (!_isRequestValid(requestVersion, tone)) {
        return;
      }

      final AudioPlayer newPlayer = AudioPlayer();

      try {
        /*
         * Agora may have changed Android to communication mode during
         * the previous call. Reset the global audio context before
         * preparing the outgoing call tone.
         */
        await AudioPlayer.global.ensureInitialized();

        if (!_isRequestValid(requestVersion, tone)) {
          await _disposePlayer(newPlayer);
          return;
        }

        await AudioPlayer.global.setAudioContext(_toneAudioContext);

        if (!_isRequestValid(requestVersion, tone)) {
          await _disposePlayer(newPlayer);
          return;
        }

        await newPlayer.setAudioContext(_toneAudioContext);

        await newPlayer.setReleaseMode(ReleaseMode.loop);

        await newPlayer.setVolume(volume);

        if (!_isRequestValid(requestVersion, tone)) {
          await _disposePlayer(newPlayer);
          return;
        }

        /*
         * Prepare the asset separately instead of using play() directly.
         * This reduces overlapping Android MediaPlayer state changes.
         */
        await newPlayer.setSource(AssetSource(assetPath));

        if (!_isRequestValid(requestVersion, tone)) {
          await _disposePlayer(newPlayer);
          return;
        }

        _player = newPlayer;

        await newPlayer.resume();

        if (!_isRequestValid(requestVersion, tone) ||
            !identical(_player, newPlayer)) {
          if (identical(_player, newPlayer)) {
            _player = null;
          }

          await _disposePlayer(newPlayer);
          return;
        }

        _currentTone = tone;
      } catch (_) {
        if (identical(_player, newPlayer)) {
          _player = null;
        }

        if (requestVersion == _requestVersion) {
          _currentTone = _OutgoingCallTone.none;
          _requestedTone = _OutgoingCallTone.none;
        }

        await _disposePlayer(newPlayer);
      }
    });
  }

  bool _isRequestValid(int requestVersion, _OutgoingCallTone tone) {
    return !_isDisposed &&
        requestVersion == _requestVersion &&
        _requestedTone == tone;
  }

  Future<void> stop() {
    if (_isDisposed) {
      return Future<void>.value();
    }

    final int requestVersion = ++_requestVersion;

    _requestedTone = _OutgoingCallTone.none;
    _currentTone = _OutgoingCallTone.none;

    return _enqueue(() async {
      /*
       * A newer playback request may have been queued after this stop.
       * In that case, the newer request owns the player lifecycle.
       */
      if (_isDisposed || requestVersion != _requestVersion) {
        return;
      }

      final AudioPlayer? currentPlayer = _player;
      _player = null;

      await _disposePlayer(currentPlayer);
    });
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final Future<void> result = _operationTail.then(
      (_) => operation(),
      onError: (_, _) => operation(),
    );

    _operationTail = result.catchError((Object _, StackTrace _) {});

    return result;
  }

  Future<void> _disposePlayer(AudioPlayer? player) async {
    if (player == null) {
      return;
    }

    /*
     * Do not call stop() here. Android can throw error -38 when stop()
     * is invoked while MediaPlayer is still preparing the source.
     */
    try {
      await player.dispose();
    } catch (_) {}
  }

  Future<void> dispose() {
    if (_isDisposed) {
      return _operationTail;
    }

    _isDisposed = true;
    _requestVersion++;

    _requestedTone = _OutgoingCallTone.none;
    _currentTone = _OutgoingCallTone.none;

    return _enqueue(() async {
      final AudioPlayer? currentPlayer = _player;
      _player = null;

      await _disposePlayer(currentPlayer);
    });
  }
}
