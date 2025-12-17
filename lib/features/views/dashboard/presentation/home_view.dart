import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:streaming_dashboard/core/config/shared_preferences/shared_preference_service.dart';
import 'package:streaming_dashboard/core/config/toast_service/toast_service.dart';
import 'package:streaming_dashboard/core/constants/app_asset_images.dart';
import 'package:streaming_dashboard/core/constants/app_strings.dart';
import 'package:streaming_dashboard/core/theme/app_themes.dart';
import 'package:streaming_dashboard/features/views/dashboard/data_model/home_view_model.dart';
import 'package:streaming_dashboard/features/views/dashboard/model/camera_live_model.dart';
import '../../live_camera/presentation/live_camera_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  late HomeViewModel _viewModel;

  final Map<String, Player> _players = {};
  final Map<String, VideoController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Future<void> loadData() async {
    await _viewModel.fetchCameraData(context);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.getBackgroundColor(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildHeader(constraints),
                _buildActionButtons(constraints),
                _buildCameraGridView(constraints),
              ],
            );
          },
        ),
      ),
    );
  }

  DeviceType _getDeviceType(BoxConstraints constraints) {
    if (constraints.maxWidth >= 1024) {
      return DeviceType.ipad;
    } else if (constraints.maxWidth >= 600) {
      return DeviceType.tablet;
    } else {
      return DeviceType.phone;
    }
  }

  Widget _buildHeader(BoxConstraints constraints) {
    final deviceType = _getDeviceType(constraints);
    final isLargeScreen = deviceType == DeviceType.ipad;

    return Container(
      color: AppThemes.getSurfaceColor(context),
      padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: isLargeScreen ? 32 : 24,
            backgroundColor: Colors.grey,
            child: Icon(
              Icons.person,
              size: isLargeScreen ? 40 : 32,
              color: Colors.white,
            ),
          ),
          SizedBox(width: isLargeScreen ? 24 : 16),
          Text(
            AppStrings.ksAdmin,
            style: TextStyle(
              color: AppThemes.getTextColor(context),
              fontSize: isLargeScreen ? 28 : 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // IconButton(
          //   icon: Icon(
          //     Icons.refresh,
          //     color: AppThemes.getTextColor(context),
          //     size: isLargeScreen ? 32 : 24,
          //   ),
          //   onPressed: loadData,
          // ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BoxConstraints constraints) {
    final deviceType = _getDeviceType(constraints);
    final isLargeScreen = deviceType == DeviceType.ipad;
    final buttonPadding = isLargeScreen ? 24.0 : 16.0;
    final iconSize = isLargeScreen ? 56.0 : 40.0;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: buttonPadding,
            vertical: isLargeScreen ? 16.0 : 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
                  decoration: BoxDecoration(
                    color:
                        _viewModel.showGridView || _viewModel.showFilterOptions
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    gridImg,
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
                onTap: () {
                  setState(() {
                    if (!_viewModel.showGridView) {
                      _viewModel.showGridView = true;
                      _viewModel.showFilterOptions = false;
                      _viewModel.selectedFilter = null;
                    } else if (!_viewModel.showFilterOptions) {
                      _viewModel.showFilterOptions = true;
                    } else {
                      _viewModel.showFilterOptions = false;
                      _viewModel.selectedFilter = null;
                    }
                  });
                },
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/filter');
                },
                icon: Icon(
                  Icons.analytics,
                  color: AppThemes.getTextColor(context),
                  size: isLargeScreen ? 28 : 24,
                ),
                label: Text(
                  AppStrings.ksReports,
                  style: TextStyle(
                    color: AppThemes.getTextColor(context),
                    fontSize: isLargeScreen ? 20 : 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.8),
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 32 : 24,
                    vertical: isLargeScreen ? 20 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_viewModel.showFilterOptions && _viewModel.showGridView)
          _buildFilterOptions(deviceType, buttonPadding),
      ],
    );
  }

  Widget _buildFilterOptions(DeviceType deviceType, double horizontalPadding) {
    final isLargeScreen = deviceType == DeviceType.ipad;
    final fontSize = isLargeScreen ? 16.0 : 14.0;

    final filters = [
      {
        'label': AppStrings.ksTotalWorks,
        'value': 'all',
        'count': _viewModel.getTotalCameraCount(),
        'icon': Icons.work_outline,
      },
      {
        'label': AppStrings.ksInprogress,
        'value': 'In-Progress',
        'count': _viewModel.getStatusCount('In-Progress'),
        'icon': Icons.refresh,
      },
      {
        'label': AppStrings.ksSlowProgress,
        'value': 'Slow-Progress',
        'count': 0,
        'icon': Icons.access_time,
      },
      {
        'label': AppStrings.ksCompleted,
        'value': 'Completed',
        'count': _viewModel.getStatusCount('Completed'),
        'icon': Icons.check_circle_outline,
      },
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filters.map((filter) {
              final isSelected =
                  _viewModel.selectedFilter == filter['value'] ||
                  (_viewModel.selectedFilter == null &&
                      filter['value'] == 'all');

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (filter['value'] == 'all') {
                      _viewModel.selectedFilter = null;
                    } else {
                      _viewModel.selectedFilter = filter['value'] as String;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                        : AppThemes.getTextColor(
                            context,
                          ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : AppThemes.getTextColor(
                              context,
                            ).withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter['icon'] as IconData,
                        color: AppThemes.getTextColor(context),
                        size: fontSize + 2,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${filter['count']}',
                        style: TextStyle(
                          color: AppThemes.getTextColor(context),
                          fontSize: fontSize + 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        filter['label'] as String,
                        style: TextStyle(
                          color: AppThemes.getTextColor(context),
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _viewModel.selectedFilter = 'camera-alerts';
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _viewModel.selectedFilter == 'camera-alerts'
                    ? Colors.red.withValues(alpha: 0.3)
                    : AppThemes.getTextColor(context).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _viewModel.selectedFilter == 'camera-alerts'
                      ? Colors.red
                      : AppThemes.getTextColor(context).withValues(alpha: 0.2),
                  width: _viewModel.selectedFilter == 'camera-alerts' ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: AppThemes.getTextColor(context),
                    size: fontSize + 2,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_viewModel.getInvalidCameraCount()}',
                    style: TextStyle(
                      color: AppThemes.getTextColor(context),
                      fontSize: fontSize + 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.ksCameraAlerts,
                    style: TextStyle(
                      color: AppThemes.getTextColor(context),
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraGridView(BoxConstraints constraints) {
    final deviceType = _getDeviceType(constraints);
    final padding = deviceType == DeviceType.ipad ? 24.0 : 16.0;

    if (_viewModel.isLoading) {
      return Expanded(
        child: Center(
          child: CircularProgressIndicator(
            color: AppThemes.getTextColor(context),
          ),
        ),
      );
    }

    if (_viewModel.errorMessage != null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _viewModel.errorMessage!,
                style: TextStyle(color: AppThemes.getTextColor(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text(AppStrings.ksRetry),
              ),
            ],
          ),
        ),
      );
    }

    if (_viewModel.cameraData == null ||
        _viewModel.cameraData!.data == null ||
        _viewModel.cameraData!.data!.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            AppStrings.ksCameraDataNotAvailable,
            style: TextStyle(
              color: AppThemes.getTextColor(context),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    List<CameraData> filteredCameras = _viewModel.cameraData!.data!;
    if (_viewModel.selectedFilter != null &&
        _viewModel.selectedFilter != 'all') {
      if (_viewModel.selectedFilter == 'camera-alerts') {
        filteredCameras = filteredCameras
            .where(
              (camera) => camera.rtspUrl == null || camera.rtspUrl!.isEmpty,
            )
            .toList();
      } else {
        filteredCameras = filteredCameras
            .where(
              (camera) =>
                  camera.workStatus?.toLowerCase() ==
                  _viewModel.selectedFilter!.toLowerCase(),
            )
            .toList();
      }
    }

    if (filteredCameras.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.filter_alt_off,
                color: AppThemes.getTextColor(context).withValues(alpha: 0.5),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'No cameras found for "${_viewModel.selectedFilter ?? 'All'}"',
                style: TextStyle(
                  color: AppThemes.getTextColor(context),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: ListView.builder(
          itemCount: (filteredCameras.length / 2).ceil(),
          itemBuilder: (context, index) {
            final firstIndex = index * 2;
            final secondIndex = firstIndex + 1;
            final hasSecondItem = secondIndex < filteredCameras.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCameraCard(
                      filteredCameras[firstIndex],
                      deviceType,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: hasSecondItem
                        ? _buildCameraCard(
                            filteredCameras[secondIndex],
                            deviceType,
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraCard(CameraData camera, DeviceType deviceType) {
    final fontSize = deviceType == DeviceType.ipad ? 14.0 : 12.0;
    final cameraId = camera.rtspUrl ?? '';

    return GestureDetector(
      onTap: () {
        if (camera.rtspUrl == null || camera.rtspUrl!.isEmpty) {
          ToastService.showWarning(AppStrings.ksVideoURLNotAvailable);
          return;
        }
        context.push('/live_camera', extra: camera);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveCameraScreen(cameraData: camera),
          ),
        );
      },
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: AppThemes.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppThemes.getTextColor(context).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Div:${camera.divisionName ?? 'N/A'}',
                          style: TextStyle(
                            color: AppThemes.getTextColor(context),
                            fontSize: fontSize,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _InlineLiveBadge(fontSize: fontSize),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'District:${camera.districtName ?? 'N/A'}',
                    style: TextStyle(
                      color: AppThemes.getTextColor(context),
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(camera.workStatus),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      camera.workStatus ?? 'Unknown',
                      style: TextStyle(
                        color: _getStatusColor(camera.workStatus),
                        fontSize: fontSize - 1,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: camera.rtspUrl != null && camera.rtspUrl!.isNotEmpty
                      ? _buildVideoPlayer(cameraId, camera.rtspUrl!)
                      : Center(
                          child: Icon(
                            Icons.videocam_off,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 48,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.ksLastUpdated,
                    style: TextStyle(
                      color: AppThemes.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: fontSize - 2,
                    ),
                  ),
                  Text(
                    _formatTimestamp(),
                    style: TextStyle(
                      color: AppThemes.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: fontSize - 2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Player _getOrCreatePlayer(String cameraId, String url) {
    if (!_players.containsKey(cameraId)) {
      final player = Player();
      final controller = VideoController(player);

      _players[cameraId] = player;
      _videoControllers[cameraId] = controller;

      player.open(Media(url), play: true);
    }
    return _players[cameraId]!;
  }

  VideoController? _getVideoController(String cameraId) {
    return _videoControllers[cameraId];
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'in-progress':
        return Colors.green;
      case 'not-started':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildVideoPlayer(String cameraId, String url) {
    final _ = _getOrCreatePlayer(cameraId, url);
    final controller = _getVideoController(cameraId);

    if (controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Video(
      controller: controller,
      controls: NoVideoControls,
      fit: BoxFit.cover,
    );
  }

  String _formatTimestamp() {
    final now = DateTime.now();
    final hour12 = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  void dispose() {
    for (var player in _players.values) {
      player.dispose();
    }
    _players.clear();
    _videoControllers.clear();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

enum DeviceType { phone, tablet, ipad }

class _InlineLiveBadge extends StatefulWidget {
  final double fontSize;

  const _InlineLiveBadge({required this.fontSize});

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                AppStrings.ksLive,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: widget.fontSize - 1,
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
