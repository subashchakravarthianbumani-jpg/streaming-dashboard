import 'package:flutter/cupertino.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../model/camera_model.dart';

class CameraViewModel extends ChangeNotifier {
  late Player _player;
  late VideoController _videoController;
  CameraModel _camera = CameraModel.dummy();

  String _selectedQuality = 'SD (480 p)';
  String _baseRtspUrl = ''; // Store the original base URL
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isLoadingQuality = false; // Track quality change loading state
  bool _isPlaybackMode = false; // Track if in playback mode

  Player get player => _player;
  VideoController get videoController => _videoController;
  CameraModel get camera => _camera;
  String get selectedQuality => _selectedQuality;
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _isInitialized;
  bool get isLoadingQuality => _isLoadingQuality; // Expose loading state
  bool get isPlaybackMode => _isPlaybackMode; // Expose playback mode

  void initializePlayer(String? rtspUrl) {
    // Store the base RTSP URL
    _baseRtspUrl = rtspUrl ?? '';

    // 1. Initialize Player
    _player = Player(configuration: const PlayerConfiguration());

    // 2. Initialize VideoController
    _videoController = VideoController(_player);

    // 3. Add listener for state changes (e.g., isPlaying)
    _player.stream.playing.listen((isPlaying) {
      if (_isPlaying != isPlaying) {
        _isPlaying = isPlaying;
        notifyListeners();
      }
    });

    // 4. Listen for errors
    _player.stream.error.listen((error) {
      print('MediaKit Error: $error');
    });

    // 5. Listen for duration to detect initialization
    _player.stream.duration.listen((duration) {
      if (duration.inMilliseconds > 0 && !_isInitialized) {
        _isInitialized = true;
        notifyListeners();
      }
    });

    // Automatically load the video with the initial quality URL
    final initialUrl = _getUrlForQuality(_selectedQuality);
    _player.open(Media(initialUrl), play: true);
  }

  /// Get the modified URL based on quality selection
  /// Handles RTSP URLs with @ symbols in passwords
  String _getUrlForQuality(String quality) {
    if (_baseRtspUrl.isEmpty) return '';

    try {
      // Manual parsing to handle @ symbols in password
      // Format: rtsp://admin:Admin@1234@43.252.94.42:8551/ch01.264

      // Find the last @ before the host (this separates credentials from host)
      final lastAtIndex = _baseRtspUrl.lastIndexOf('@');
      if (lastAtIndex == -1) {
        // No credentials in URL, just modify the path
        return _modifyUrlPath(_baseRtspUrl, quality);
      }

      // Split into: protocol+credentials and host+path
      final credentialsPart = _baseRtspUrl.substring(
        0,
        lastAtIndex,
      ); // rtsp://admin:Admin@1234
      final hostAndPath = _baseRtspUrl.substring(
        lastAtIndex + 1,
      ); // 43.252.94.42:8551/ch01.264

      // Find the path separator
      final pathSeparatorIndex = hostAndPath.indexOf('/');
      if (pathSeparatorIndex == -1) {
        // No path in URL
        return _baseRtspUrl;
      }

      final hostPart = hostAndPath.substring(
        0,
        pathSeparatorIndex,
      ); // 43.252.94.42:8551
      String path = hostAndPath.substring(pathSeparatorIndex + 1); // ch01.264

      // Modify the path based on quality
      path = _modifyPathForQuality(path, quality);

      // Reconstruct the URL
      final newUrl = '$credentialsPart@$hostPart/$path';

      print('Quality: $quality -> URL: $newUrl');
      return newUrl;
    } catch (e) {
      print('Error parsing URL: $e');
      return _baseRtspUrl;
    }
  }

  /// Modify just the URL path (for URLs without credentials)
  String _modifyUrlPath(String url, String quality) {
    final lastSlashIndex = url.lastIndexOf('/');
    if (lastSlashIndex == -1) return url;

    final basePart = url.substring(0, lastSlashIndex + 1);
    final path = url.substring(lastSlashIndex + 1);

    final modifiedPath = _modifyPathForQuality(path, quality);
    return '$basePart$modifiedPath';
  }

  /// Modify the path part (e.g., ch01.264) based on quality
  String _modifyPathForQuality(String path, String quality) {
    // Split filename and extension
    final lastDotIndex = path.lastIndexOf('.');
    String baseName = path;
    String extension = '';

    if (lastDotIndex != -1) {
      baseName = path.substring(0, lastDotIndex); // e.g., ch01
      extension = path.substring(lastDotIndex); // e.g., .264
    }

    // Remove any existing quality suffix (_fourth, _third)
    baseName = baseName.replaceAll(RegExp(r'_(fourth|third)$'), '');

    // Determine the quality suffix based on the selected quality
    String qualitySuffix = '';

    // Extract quality from format like "SD (480 p)", "HD (720 p)", "High (1080 p)"
    if (quality.contains('480')) {
      qualitySuffix = '_fourth';
    } else if (quality.contains('720')) {
      qualitySuffix = '_third';
    } else if (quality.contains('1080')) {
      qualitySuffix = ''; // No suffix for 1080p
    } else {
      // Default to no suffix if quality format is unexpected
      qualitySuffix = '';
    }

    // Reconstruct the path
    return '$baseName$qualitySuffix$extension';
  }

  Future<void> togglePlayback() async {
    await _player.playOrPause();
    // The player.stream.playing listener will handle notifyListeners()
  }

  Future<void> changeQuality(String quality) async {
    if (_selectedQuality == quality) return;

    print('Changing quality from $_selectedQuality to $quality');
    _selectedQuality = quality;
    _isLoadingQuality = true; // Start loading
    notifyListeners();

    try {
      // Get the new URL for the selected quality
      final newUrl = _getUrlForQuality(quality);

      // Pause current playback
      await _player.pause();

      // Open new stream with the quality-specific URL
      await _player.open(Media(newUrl), play: true);

      print('Successfully changed to quality: $quality with URL: $newUrl');

      // Wait a bit for the stream to stabilize
      await Future.delayed(const Duration(milliseconds: 500));

      _isLoadingQuality = false; // Stop loading
      notifyListeners();
    } catch (e) {
      print('Error changing quality: $e');
      _isLoadingQuality = false; // Stop loading on error
      notifyListeners();
    }
  }

  Future<void> loadCameraData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _camera = CameraModel.dummy();

    // Re-open the media with the new URL if it changed
    if (_isInitialized) {
      final currentQualityUrl = _getUrlForQuality(_selectedQuality);
      _player.open(Media(currentQualityUrl), play: false);
    }
    notifyListeners();
  }

  void disposePlayer() {
    _player.dispose();
  }

  @override
  void dispose() {
    disposePlayer();
    super.dispose();
  }

  /// Extract channel number from RTSP URL
  /// e.g., "ch01" -> 1, "ch02" -> 2
  int _extractChannelNumber(String url) {
    final match = RegExp(r'ch(\d+)', caseSensitive: false).firstMatch(url);
    if (match != null) {
      final channelStr = match.group(1);
      return int.tryParse(channelStr ?? '1') ?? 1;
    }
    return 1; // Default to channel 1
  }

  /// Get stream type based on quality (0 = main stream, 1 = substream)
  int _getStreamType(String quality) {
    // Main stream (1080p) = 0, Substream (480p, 720p) = 1
    if (quality.contains('1080')) {
      return 0; // Main stream
    }
    return 1; // Substream
  }

  /// Build playback URL from base RTSP URL and time range
  /// Format: rtsp://ip:port/recording?ch=X&stream=Y&start=YYYYMMDDHHMMSS&stop=YYYYMMDDHHMMSS
  String _buildPlaybackUrl(DateTime startTime, DateTime endTime) {
    try {
      // Parse the base URL to extract credentials and host
      final lastAtIndex = _baseRtspUrl.lastIndexOf('@');
      if (lastAtIndex == -1) return _baseRtspUrl;

      final credentialsPart = _baseRtspUrl.substring(
        0,
        lastAtIndex,
      ); // rtsp://admin:Admin@1234
      final hostAndPath = _baseRtspUrl.substring(
        lastAtIndex + 1,
      ); // 43.252.94.42:8551/ch01.264

      // Extract host and port
      final pathSeparatorIndex = hostAndPath.indexOf('/');
      if (pathSeparatorIndex == -1) return _baseRtspUrl;

      final hostPart = hostAndPath.substring(
        0,
        pathSeparatorIndex,
      ); // 43.252.94.42:8551

      // Extract channel number from the URL
      final channelNumber = _extractChannelNumber(_baseRtspUrl);

      // Get stream type based on current quality
      final streamType = _getStreamType(_selectedQuality);

      // Format timestamps as YYYYMMDDHHMMSS
      final startStr = _formatTimestamp(startTime);
      final endStr = _formatTimestamp(endTime);

      // Build the playback URL
      final playbackUrl =
          '$credentialsPart@$hostPart/recording?ch=$channelNumber&stream=$streamType&start=$startStr&stop=$endStr';

      print('Playback URL: $playbackUrl');
      return playbackUrl;
    } catch (e) {
      print('Error building playback URL: $e');
      return _baseRtspUrl;
    }
  }

  /// Format DateTime to YYYYMMDDHHMMSS
  String _formatTimestamp(DateTime dateTime) {
    return '${dateTime.year}'
        '${dateTime.month.toString().padLeft(2, '0')}'
        '${dateTime.day.toString().padLeft(2, '0')}'
        '${dateTime.hour.toString().padLeft(2, '0')}'
        '${dateTime.minute.toString().padLeft(2, '0')}'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Load playback video for a specific time range
  Future<void> loadPlayback(DateTime startTime, DateTime endTime) async {
    print('Loading playback from $startTime to $endTime');

    _isLoadingQuality = true;
    _isPlaybackMode = true;
    notifyListeners();

    try {
      // Build the playback URL
      final playbackUrl = _buildPlaybackUrl(startTime, endTime);

      // Pause current playback
      await _player.pause();

      // Open playback stream
      await _player.open(Media(playbackUrl), play: true);

      print('Successfully loaded playback:$playbackUrl');

      await Future.delayed(const Duration(milliseconds: 500));

      _isLoadingQuality = false;
      notifyListeners();
    } catch (e) {
      print('Error loading playback: $e');
      _isLoadingQuality = false;
      _isPlaybackMode = false;
      notifyListeners();
    }
  }

  /// Switch back to live stream
  Future<void> switchToLive() async {
    if (!_isPlaybackMode) return;

    print('Switching back to live stream');

    _isLoadingQuality = true;
    notifyListeners();

    try {
      // Get the live URL with current quality
      final liveUrl = _getUrlForQuality(_selectedQuality);

      // Pause current playback
      await _player.pause();

      // Open live stream
      await _player.open(Media(liveUrl), play: true);

      _isPlaybackMode = false;

      await Future.delayed(const Duration(milliseconds: 500));

      _isLoadingQuality = false;
      notifyListeners();

      print('Successfully switched to live stream');
    } catch (e) {
      print('Error switching to live: $e');
      _isLoadingQuality = false;
      notifyListeners();
    }
  }
}
