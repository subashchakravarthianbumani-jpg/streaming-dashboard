import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:streaming_dashboard/features/views/dashboard/data_model/home_view_model.dart';

class CameraViewModel extends ChangeNotifier {
  final Map<String, Player> players = {};
  final Map<String, VideoController> videoControllers = {};

  // Search bar state
  bool isSearchExpanded = false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  // In camera_page.dart - Update the _navigateToFilter method:
  void navigateToFilter(BuildContext context, HomeViewModel model) async {
    final result = await context.push<Map<String, String?>>('/filter');

    if (result != null) {
      // Show loading
      if (context.mounted) {
        model.isLoading = true;
      }

      try {
        // Fetch filtered data using the filter parameters
        await model.fetchFilteredCameraData(context, result);
      } catch (e) {
        print('Error fetching filtered data: $e');
      }

      if (context.mounted) {
        model.isLoading = false;
      }
    }
  }
}
