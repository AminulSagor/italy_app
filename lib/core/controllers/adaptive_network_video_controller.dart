import 'package:video_player/video_player.dart';

bool isHlsVideoUri(Uri uri) {
  return uri.path.toLowerCase().endsWith('.m3u8');
}

VideoPlayerController createAdaptiveNetworkVideoController({
  required Uri uri,
  Map<String, String> httpHeaders = const <String, String>{},
  bool forceHls = false,
}) {
  final bool shouldUseHls = forceHls || isHlsVideoUri(uri);

  return VideoPlayerController.networkUrl(
    uri,
    formatHint: shouldUseHls ? VideoFormat.hls : null,
    httpHeaders: httpHeaders,
  );
}