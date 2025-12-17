import 'package:flutter/material.dart';

class QualityButton extends StatelessWidget {
  final String quality;
  final bool isSelected;
  final VoidCallback onTap;

  const QualityButton({
    super.key,
    required this.quality,
    required this.isSelected,
    required this.onTap,
  });

  // Calculate responsive font size
  double _getResponsiveFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) return 10.0;
    if (screenWidth < 400) return 11.0;
    if (screenWidth < 600) return 12.0;
    if (screenWidth < 900) return 14.0;
    return 16.0;
  }

  // Calculate responsive padding
  EdgeInsetsGeometry _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    } else if (screenWidth < 400) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (screenWidth < 600) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    } else if (screenWidth < 900) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 28, vertical: 14);
    }
  }

  // Calculate border radius
  double _getBorderRadius(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) return 15.0;
    if (screenWidth < 400) return 18.0;
    if (screenWidth < 600) return 22.0;
    if (screenWidth < 900) return 26.0;
    return 30.0;
  }

  // Calculate border width
  double _getBorderWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) return 1.0;
    return 1.5;
  }

  @override
  Widget build(BuildContext context) {
    // Extract just the resolution part (e.g., "1080p" from "High (1080p)")
    String displayText = quality;
    if (quality.contains('(')) {
      // Get text inside parentheses
      final match = RegExp(r'\((.*?)\)').firstMatch(quality);
      if (match != null) {
        displayText = match.group(1)!.trim();
      }
    }
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colors based on theme and selection state
    final backgroundColor = isSelected
        ? const Color(0xFF00A3FF) // Blue when selected
        : (isDarkMode
              ? const Color(0xFF3A3A3A) // Dark gray for dark mode
              : Colors.white); // White for light mode

    final borderColor = isSelected
        ? const Color(0xFF00A3FF) // Blue border when selected
        : (isDarkMode
              ? const Color(0xFF555555) // Lighter gray border for dark mode
              : Colors.grey.shade300); // Light gray border for light mode

    final textColor = isSelected
        ? Colors
              .white // White text when selected
        : (isDarkMode
              ? Colors
                    .white70 // Light gray text for dark mode
              : Colors.black87); // Dark text for light mode

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: _getResponsivePadding(context),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_getBorderRadius(context)),
          border: Border.all(
            color: borderColor,
            width: _getBorderWidth(context),
          ),
          // boxShadow: isSelected
          //     ? [
          //         BoxShadow(
          //           color: const Color(0xFF00A3FF).withOpacity(0.3),
          //           blurRadius: 8,
          //           spreadRadius: 2,
          //         ),
          //       ]
          //     : [],
        ),
        child: Center(
          child: Text(
            displayText,
            style: TextStyle(
              color: textColor,
              fontSize: _getResponsiveFontSize(context),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class LiveBadge extends StatelessWidget {
  const LiveBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, color: Colors.red, size: 8),
          SizedBox(width: 6),
          Text(
            'Live',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CameraInfoCard extends StatelessWidget {
  final String division;
  final String district;
  final String workId;
  final String workStatus;
  final String resolutionType;
  /*  final String lastUpdated;*/

  const CameraInfoCard({
    super.key,
    required this.division,
    required this.district,
    required this.workId,
    required this.workStatus,
    required this.resolutionType,
    /*    required this.lastUpdated,*/
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Dynamic colors based on theme
    final cardBackgroundColor = isDarkMode
        ? const Color(0xFF3A3A3A)
        : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Div: ', division, textColor),
          const SizedBox(height: 12),
          _buildInfoRow('District: ', district, textColor),
          const SizedBox(height: 12),
          _buildInfoRow('Work ID: ', workId, textColor),
          const SizedBox(height: 12),
          _buildInfoRow('Work Status: ', workStatus, textColor),
          const SizedBox(height: 12),
          _buildInfoRow('Resolution Type: ', resolutionType, textColor),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textColor.withValues(alpha: .9),
            ),
          ),
        ),
      ],
    );
  }
}

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      icon: Icon(icon),
      color: iconColor ?? (isDarkMode ? Colors.white : Colors.black87),
      style: IconButton.styleFrom(
        backgroundColor:
            backgroundColor ??
            (isDarkMode ? const Color(0xFF3A3A3A) : Colors.white),
      ),
      onPressed: onPressed,
    );
  }
}
