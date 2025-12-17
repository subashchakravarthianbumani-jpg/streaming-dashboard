import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:streaming_dashboard/core/config/toast_service/toast_service.dart';
import 'package:streaming_dashboard/core/constants/app_asset_images.dart';
import 'package:streaming_dashboard/core/constants/app_strings.dart';
import 'package:streaming_dashboard/core/theme/app_themes.dart';
import 'package:streaming_dashboard/features/views/camera/data_model/camera_view_model.dart';
import 'package:streaming_dashboard/features/views/dashboard/data_model/home_view_model.dart';
import 'package:streaming_dashboard/features/views/dashboard/model/camera_live_model.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  late HomeViewModel _viewModel;
  late CameraViewModel _cameraModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _cameraModel = CameraViewModel();

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        // Collapse search bar when tapping outside
        if (_cameraModel.isSearchExpanded) {
          setState(() {
            _cameraModel.isSearchExpanded = false;
          });
          _cameraModel.searchFocusNode.unfocus();
        }
      },

      child: Scaffold(
        backgroundColor: AppThemes.getBackgroundColor(context),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _buildHeader(constraints, isDarkMode),
                  _buildActionButtons(constraints, isDarkMode),
                  _buildCameraGridView(constraints, isDarkMode),
                ],
              );
            },
          ),
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

  Widget _buildHeader(BoxConstraints constraints, bool isDarkMode) {
    final deviceType = _getDeviceType(constraints);
    final isLargeScreen = deviceType == DeviceType.ipad;

    return Container(
      color: AppThemes.getSurfaceColor(context),
      padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
      child: Row(
        children: [
          Text(
            AppStrings.ksCamera,
            style: TextStyle(
              color: AppThemes.getTextColor(context),
              fontSize: isLargeScreen ? 28 : 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BoxConstraints constraints, bool isDarkMode) {
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
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      _cameraModel.navigateToFilter(context, _viewModel);
                    },
                    child: Container(
                      padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
                      decoration: BoxDecoration(
                        color:
                            _viewModel
                                .isFilterApplied // Check isFilterApplied instead
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        filterImg,
                        width: iconSize,
                        height: iconSize,
                      ),
                    ),
                  ),
                  // Show indicator if filters are applied
                  if (_viewModel.isFilterApplied)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppThemes.getBackgroundColor(context),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // Show clear filter button if filters are applied
              if (_viewModel.isFilterApplied)
                GestureDetector(
                  onTap: () async {
                    await _viewModel.clearFiltersAndReload(context);
                    if (mounted) setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.clear,
                      size: iconSize,
                      // color: AppThemes.getTextColor(context),
                    ),
                  ),
                ),

              if (_viewModel.isFilterApplied) const SizedBox(width: 12),

              // Animated Search Box
              Expanded(
                child: _AnimatedSearchBar(
                  isExpanded: _cameraModel.isSearchExpanded,
                  controller: _cameraModel.searchController,
                  focusNode: _cameraModel.searchFocusNode,
                  isLargeScreen: isLargeScreen,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    setState(() {
                      _cameraModel.isSearchExpanded = true;
                    });
                    _cameraModel.searchFocusNode.requestFocus();
                  },
                  onClear: () {
                    setState(() {
                      _cameraModel.searchController.clear();
                      _cameraModel.isSearchExpanded = false;
                    });
                    _cameraModel.searchFocusNode.unfocus();
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),

              const SizedBox(width: 12),
            ],
          ),
        ),
        // Show filter status if applied
        if (_viewModel.isFilterApplied)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: buttonPadding),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_alt, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${AppStrings.ksFiltersApplied} ${_viewModel.getTotalCameraCount()} ${AppStrings.ksResults}',
                    style: TextStyle(
                      color: AppThemes.getTextColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_viewModel.isFilterApplied) const SizedBox(height: 8),
        // Filter options
        if (_viewModel.showFilterOptions && _viewModel.showGridView)
          _buildFilterOptions(deviceType, buttonPadding, isDarkMode),
      ],
    );
  }

  Widget _buildFilterOptions(
    DeviceType deviceType,
    double horizontalPadding,
    bool isDarkMode,
  ) {
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
                        ? (isDarkMode
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.blue.withValues(alpha: 0.2))
                        : (isDarkMode
                              ? Colors.white.withValues(alpha: .15)
                              : Colors.grey.withValues(alpha: .15)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue
                          : (isDarkMode
                                ? Colors.white.withValues(alpha: .2)
                                : Colors.grey.withValues(alpha: .3)),
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
                    ? Colors.red.withValues(alpha: .3)
                    : (isDarkMode
                          ? Colors.white.withValues(alpha: .15)
                          : Colors.grey.withValues(alpha: .15)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _viewModel.selectedFilter == 'camera-alerts'
                      ? Colors.red
                      : (isDarkMode
                            ? Colors.white.withValues(alpha: .2)
                            : Colors.grey.withValues(alpha: .3)),
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

  Widget _buildCameraGridView(BoxConstraints constraints, bool isDarkMode) {
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

    // Apply search filter
    if (_cameraModel.searchController.text.isNotEmpty) {
      final searchQuery = _cameraModel.searchController.text.toLowerCase();
      filteredCameras = filteredCameras.where((camera) {
        return (camera.divisionName?.toLowerCase().contains(searchQuery) ??
                false) ||
            (camera.districtName?.toLowerCase().contains(searchQuery) ??
                false) ||
            (camera.workStatus?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }

    // Apply status filter
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
                color: AppThemes.getTextColor(context).withValues(alpha: .5),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _cameraModel.searchController.text.isNotEmpty
                    ? '${AppStrings.ksNoCamerasFound} "${_cameraModel.searchController.text}"'
                    : '${AppStrings.ksNoCamerasFound} "${_viewModel.selectedFilter ?? AppStrings.ksAll}"',
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
                      isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: hasSecondItem
                        ? _buildCameraCard(
                            filteredCameras[secondIndex],
                            deviceType,
                            isDarkMode,
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

  Widget _buildCameraCard(
    CameraData camera,
    DeviceType deviceType,
    bool isDarkMode,
  ) {
    final fontSize = deviceType == DeviceType.ipad ? 14.0 : 12.0;
    final cameraId = camera.rtspUrl ?? '';

    return GestureDetector(
      onTap: () {
        if (camera.rtspUrl == null || camera.rtspUrl!.isEmpty) {
          ToastService.showWarning(AppStrings.ksVideoURLNotAvailable);
          return;
        }
        context.push('/live_camera', extra: camera);
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
                      camera.workStatus ?? AppStrings.ksUnknown,
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
                      ).withValues(alpha: .6),
                      fontSize: fontSize - 2,
                    ),
                  ),
                  Text(
                    _formatTimestamp(),
                    style: TextStyle(
                      color: AppThemes.getTextColor(
                        context,
                      ).withValues(alpha: .6),
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
    if (!_cameraModel.players.containsKey(cameraId)) {
      final player = Player();
      final controller = VideoController(player);

      _cameraModel.players[cameraId] = player;
      _cameraModel.videoControllers[cameraId] = controller;

      player.open(Media(url), play: true);
    }
    return _cameraModel.players[cameraId]!;
  }

  VideoController? _getVideoController(String cameraId) {
    return _cameraModel.videoControllers[cameraId];
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
    _cameraModel.searchController.dispose();
    _cameraModel.searchFocusNode.dispose();
    for (var player in _cameraModel.players.values) {
      player.dispose();
    }
    _cameraModel.players.clear();
    _cameraModel.videoControllers.clear();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

// Animated Search Bar Widget
class _AnimatedSearchBar extends StatefulWidget {
  final bool isExpanded;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLargeScreen;
  final bool isDarkMode;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;

  const _AnimatedSearchBar({
    required this.isExpanded,
    required this.controller,
    required this.focusNode,
    required this.isLargeScreen,
    required this.isDarkMode,
    required this.onTap,
    required this.onClear,
    required this.onChanged,
  });

  @override
  State<_AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<_AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: widget.isLargeScreen ? 56 : 48,
            decoration: BoxDecoration(
              color: widget.isExpanded
                  ? (widget.isDarkMode ? const Color(0xFF3a3d42) : Colors.white)
                  : (widget.isDarkMode
                        ? Colors.transparent
                        : Colors.grey.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: widget.isDarkMode
                    ? Colors.white.withValues(alpha: .2)
                    : Colors.grey.withValues(alpha: .3),
                width: widget.isExpanded ? 2 : 1,
              ),
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 12),
                    child: Icon(
                      Icons.search,
                      color: widget.isExpanded
                          ? (widget.isDarkMode
                                ? Colors.white
                                : Colors.grey.shade700)
                          : (widget.isDarkMode
                                ? Colors.white.withValues(alpha: .6)
                                : Colors.grey.shade600),
                      size: widget.isLargeScreen ? 28 : 24,
                    ),
                  ),
                  Expanded(
                    child: widget.isExpanded
                        ? FadeTransition(
                            opacity: _fadeAnimation,
                            child: TextField(
                              controller: widget.controller,
                              focusNode: widget.focusNode,
                              style: TextStyle(
                                color: widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: widget.isLargeScreen ? 18 : 16,
                              ),
                              decoration: InputDecoration(
                                hintText: AppStrings.ksSearchCameras,
                                hintStyle: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white.withValues(alpha: .5)
                                      : Colors.grey.shade500,
                                  fontSize: widget.isLargeScreen ? 18 : 16,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: widget.onChanged,
                            ),
                          )
                        : Text(
                            AppStrings.ksSearch,
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.white.withValues(alpha: .5)
                                  : Colors.grey.shade600,
                              fontSize: widget.isLargeScreen ? 18 : 16,
                            ),
                          ),
                  ),
                  if (widget.isExpanded && widget.controller.text.isNotEmpty)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                        onPressed: widget.onClear,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
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
