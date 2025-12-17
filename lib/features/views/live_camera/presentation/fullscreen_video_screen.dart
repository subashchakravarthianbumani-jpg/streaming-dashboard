import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../widgets/video_player_widget.dart';
import '../view_model/video_view_model.dart';

class VideoScreen extends StatefulWidget {
  final CameraViewModel viewModel;

  const VideoScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleVideoAnimationController;
  Animation<double> _scaleVideoAnimation = const AlwaysStoppedAnimation<double>(
    1.0,
  );
  double? _targetVideoScale;

  double _lastZoomGestureScale = 1.0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _forceLandscape();

    _scaleVideoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 125),
      vsync: this,
    );

    // Listen to viewModel changes
    widget.viewModel.addListener(_onViewModelChanged);

    // Auto-hide controls after 3 seconds
    _startControlsTimer();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startControlsTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startControlsTimer();
    }
  }

  void setTargetNativeScale(double newValue) {
    if (!newValue.isFinite) {
      return;
    }
    _scaleVideoAnimation = Tween<double>(begin: 1.0, end: newValue).animate(
      CurvedAnimation(
        parent: _scaleVideoAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    if (_targetVideoScale == null) {
      _scaleVideoAnimationController.forward();
    }
    _targetVideoScale = newValue;
  }

  Future<void> _forceLandscape() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (e) {
      // Fallback: Just hide system UI and maximize video
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  Future<void> _forcePortrait() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _forcePortrait();
    _scaleVideoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qualities = widget.viewModel.camera.availableQualities;

    final mediaKitVideo = Video(
      controller: widget.viewModel.videoController,
      fit: BoxFit.contain,
    );

    return Scaffold(
      body: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: _toggleControls,
          onScaleUpdate: (details) {
            _lastZoomGestureScale = details.scale;
          },
          onScaleEnd: (details) {
            if (_lastZoomGestureScale > 1.0) {
              setState(() {
                _scaleVideoAnimationController.forward();
              });
            } else if (_lastZoomGestureScale < 1.0) {
              setState(() {
                _scaleVideoAnimationController.reverse();
              });
            }
            _lastZoomGestureScale = 1.0;
          },
          child: Stack(
            children: [
              Container(color: Colors.black),

              // VIDEO
              Center(
                child: ScaleTransition(
                  scale: _scaleVideoAnimation,
                  child: AspectRatio(aspectRatio: 16 / 9, child: mediaKitVideo),
                ),
              ),

              // Loading indicator when changing quality
              if (widget.viewModel.isLoadingQuality)
                Container(
                  color: Colors.black.withValues(alpha: .7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF00A3FF),
                          ),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Switching quality...',
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

              // Controls overlay
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: .7),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: .7),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Top bar with back button and live badge
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            left: 20,
                            right: 20,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const LiveBadge(),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Bottom bar with quality selector
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 20,
                            left: 20,
                            right: 20,
                          ),
                          child: Row(
                            children: [
                              // Play/Pause button
                              GestureDetector(
                                onTap: () => widget.viewModel.togglePlayback(),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.viewModel.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),

                              const Spacer(),

                              // Quality selector
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (
                                      int i = 0;
                                      i < qualities.length;
                                      i++
                                    ) ...[
                                      _QualityChip(
                                        quality: qualities[i],
                                        isSelected:
                                            widget.viewModel.selectedQuality ==
                                            qualities[i],
                                        onTap: () => widget.viewModel
                                            .changeQuality(qualities[i]),
                                      ),
                                      if (i < qualities.length - 1)
                                        const SizedBox(width: 8),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityChip extends StatelessWidget {
  final String quality;
  final bool isSelected;
  final VoidCallback onTap;

  const _QualityChip({
    required this.quality,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extract just the resolution (e.g., "480 p" from "SD (480 p)")
    String displayText = quality;
    if (quality.contains('(')) {
      final match = RegExp(r'\((.*?)\)').firstMatch(quality);
      if (match != null) {
        displayText = match.group(1)!.trim();
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00A3FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
