import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:streaming_dashboard/core/config/toast_service/toast_service.dart';
import 'package:streaming_dashboard/core/constants/app_strings.dart';
import 'package:streaming_dashboard/features/views/live_camera/presentation/play_back.dart';
import '../../dashboard/model/camera_live_model.dart';
import '../view_model/video_view_model.dart';
import '../widgets/video_player_widget.dart';

class LiveCameraScreen extends StatefulWidget {
  final CameraData? cameraData;

  const LiveCameraScreen({
    super.key,
    this.cameraData, // Required parameter
  });

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  late CameraViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _viewModel = CameraViewModel();
    final String videoUrl = widget.cameraData?.rtspUrl ?? '';
    _viewModel.initializePlayer(videoUrl);
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  // Replace the _enterFullscreen method in live_camera_screen.dart with this:
  void _enterFullscreen() async {
    if (!_viewModel.isInitialized) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.ksVideoLoading)));
      return;
    }

    // Ensure the controller is playing before entering fullscreen
    if (!_viewModel.isPlaying) {
      _viewModel.player.play();
    }
    // Navigate to FullscreenVideoScreen - pass the viewModel directly
    await context.push('/full_video_screen', extra: _viewModel);
    // When returning from fullscreen, reset to portrait

    // When returning from fullscreen, reset to portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? const Color(0xFF1A1A1A)
        : Colors.grey.shade100;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final surfaceColor = isDarkMode ? const Color(0xFF3A3A3A) : Colors.white;
    final borderColor = isDarkMode
        ? const Color(0xFF3A3A3A)
        : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        // 1. Wrap the content with SingleChildScrollView
        child: SingleChildScrollView(
          // 2. Wrap the content with an Expanded,
          // which is usually implicit when SingleChildScrollView contains Column,
          // but it's good practice for clarity or if there were other siblings.
          // However, in this specific structure (SingleChildScrollView -> Column),
          // we don't strictly need Expanded here unless it was a Flexible/Expanded
          // inside another Column/Row, which is not the case.
          // The key is the SingleChildScrollView.
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircularIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () {
                        context.pop();
                      },
                      backgroundColor: backgroundColor,
                      iconColor: textColor,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      AppStrings.ksLiveCamera,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Quality selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Scrollable quality buttons
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (
                              int i = 0;
                              i < _viewModel.camera.availableQualities.length;
                              i++
                            ) ...[
                              QualityButton(
                                quality:
                                    _viewModel.camera.availableQualities[i],
                                isSelected:
                                    _viewModel.selectedQuality ==
                                    _viewModel.camera.availableQualities[i],
                                onTap: () => _viewModel.changeQuality(
                                  _viewModel.camera.availableQualities[i],
                                ),
                              ),
                              if (i <
                                  _viewModel.camera.availableQualities.length -
                                      1)
                                const SizedBox(width: 12),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16), // Add some spacing
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Playback/Live and Play/Pause buttons
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Playback/Live button
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_viewModel.isPlaybackMode) {
                          // If in playback mode, switch back to live
                          await _viewModel.switchToLive();
                          if (mounted) {
                            ToastService.showSuccess(
                              AppStrings.ksSwitchToliveStream,
                            );
                          }
                        } else {
                          // Show playback dialog to select time range
                          final result =
                              await showDialog<Map<String, DateTime?>>(
                                context: context,
                                builder: (context) => const PlaybackDialog(),
                              );

                          if (result != null) {
                            final fromTime = result['from'];
                            final toTime = result['to'];
                            // Check if both times are non-null
                            if (fromTime == null || toTime == null) {
                              if (mounted) {
                                ToastService.showInfo(
                                  AppStrings.ksStartTimeEndTime,
                                );
                              }
                              return;
                            }

                            // Validate time range
                            if (toTime.isBefore(fromTime)) {
                              if (mounted) {
                                ToastService.showInfo(
                                  AppStrings.ksEndTimeMustAfterStartTime,
                                );
                              }
                              return;
                            }

                            // Check if time range is reasonable (not more than 24 hours)
                            final duration = toTime.difference(fromTime);
                            if (duration.inHours > 24) {
                              if (mounted) {
                                ToastService.showInfo(
                                  AppStrings.ksPlaybackDuration,
                                );
                              }
                              return;
                            }

                            // Load playback video for the selected time range
                            await _viewModel.loadPlayback(fromTime, toTime);

                            if (mounted) {
                              ToastService.showInfo(
                                'Playing recording from ${_formatTime(fromTime)} to ${_formatTime(toTime)}',
                              );
                            }
                          }
                        }
                      },
                      icon: Icon(
                        _viewModel.isPlaybackMode
                            ? Icons.videocam
                            : Icons.history,
                        color: _viewModel.isPlaybackMode
                            ? Colors.white
                            : textColor,
                      ),
                      label: Text(
                        _viewModel.isPlaybackMode
                            ? AppStrings.ksSwitchToLive
                            : AppStrings.ksPlayback,
                        style: TextStyle(
                          fontSize: 16,
                          color: _viewModel.isPlaybackMode
                              ? Colors.white
                              : textColor,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _viewModel.isPlaybackMode
                            ? const Color(0xFF00A3FF)
                            : surfaceColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Play/Pause button
                    CircularIconButton(
                      icon: _viewModel.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      backgroundColor: surfaceColor,
                      onPressed: () => _viewModel.togglePlayback(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Video player section
              // Replace the video player section in your live_camera_screen.dart with this:

              // Video player section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      child: _InlineLiveBadge(
                        isPlaybackMode: _viewModel.isPlaybackMode,
                      ),
                    ),
                    GestureDetector(
                      onTap: _enterFullscreen,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black,
                          border: Border.all(color: borderColor, width: 20.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(
                              children: [
                                // Video Player (no controls)
                                Video(
                                  controller: _viewModel.videoController,
                                  fit: BoxFit.cover,
                                  controls: NoVideoControls,
                                ),

                                // Loading indicator when changing quality
                                if (_viewModel.isLoadingQuality)
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF00A3FF),
                                                ),
                                            strokeWidth: 3,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            AppStrings.ksSwitchingQuality,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                // Fullscreen button overlay (bottom-right)
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _enterFullscreen,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.fullscreen,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Camera info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CameraInfoCard(
                  division: widget.cameraData?.divisionName ?? AppStrings.ksNA,
                  district: widget.cameraData?.districtName ?? AppStrings.ksNA,
                  workId: widget.cameraData?.tenderNumber ?? AppStrings.ksNA,
                  workStatus: widget.cameraData?.workStatus ?? AppStrings.ksNA,
                  resolutionType: _viewModel.selectedQuality,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
// Replace the _InlineLiveBadge widget in live_camera_screen.dart with this:

class _InlineLiveBadge extends StatefulWidget {
  final bool isPlaybackMode;

  const _InlineLiveBadge({this.isPlaybackMode = false});

  @override
  State<_InlineLiveBadge> createState() => InlineLiveBadgeState();
}

class InlineLiveBadgeState extends State<_InlineLiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getResponsiveFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return 12.0;
    } else if (screenWidth < 400) {
      return 14.0;
    } else if (screenWidth < 600) {
      return 16.0;
    } else if (screenWidth < 900) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = _getResponsiveFontSize(context);
    final dotSize = fontSize * 0.5;

    // Show different badge based on mode
    if (widget.isPlaybackMode) {
      // Playback mode badge (blue, no animation)
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: fontSize * 0.6,
          vertical: fontSize * 0.3,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF00A3FF).withValues(alpha: .2),
          borderRadius: BorderRadius.circular(fontSize * 0.8),
          border: Border.all(color: const Color(0xFF00A3FF), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              color: const Color(0xFF00A3FF),
              size: fontSize * 0.8,
            ),
            SizedBox(width: dotSize * 0.5),
            Text(
              AppStrings.ksPlayback,
              style: TextStyle(
                color: const Color(0xFF00A3FF),
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Live mode badge (red, animated)
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: dotSize,
                height: dotSize,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: dotSize * 0.5),
              Text(
                AppStrings.ksLive,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Add this helper method to the _LiveCameraScreenState class
String _formatTime(DateTime dateTime) {
  return '${dateTime.day.toString().padLeft(2, '0')}'
      '/${dateTime.month.toString().padLeft(2, '0')}'
      '/${dateTime.year} '
      '${dateTime.hour.toString().padLeft(2, '0')}'
      ':${dateTime.minute.toString().padLeft(2, '0')}';
}
