import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlaybackDialog extends StatefulWidget {
  const PlaybackDialog({Key? key}) : super(key: key);

  @override
  State<PlaybackDialog> createState() => _PlaybackDialogState();
}

class _PlaybackDialogState extends State<PlaybackDialog> {
  DateTime? _fromDateTime;
  DateTime? _toDateTime;

  Future<void> _selectDateTime(BuildContext context, bool isFromTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF2A2A2A),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF4CAF50),
                onPrimary: Colors.white,
                surface: Color(0xFF2A2A2A),
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: const Color(0xFF2A2A2A),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isFromTime) {
            _fromDateTime = selectedDateTime;
          } else {
            _toDateTime = selectedDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogPadding = screenWidth < 360 ? 16.0 : 24.0;

    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: EdgeInsets.all(dialogPadding),
        constraints: BoxConstraints(maxWidth: screenWidth - 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select Playback Time',
                      style: TextStyle(
                        fontSize: screenWidth < 360 ? 18 : 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // From Time Selector
              _DateTimeCard(
                label: 'From',
                icon: Icons.calendar_today,
                dateTime: _fromDateTime,
                onTap: () => _selectDateTime(context, true),
              ),
              const SizedBox(height: 16),

              // Arrow indicator
              const Icon(
                Icons.arrow_downward,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              const SizedBox(height: 16),

              // To Time Selector
              _DateTimeCard(
                label: 'To',
                icon: Icons.event,
                dateTime: _toDateTime,
                onTap: () => _selectDateTime(context, false),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth < 360 ? 12 : 14,
                        ),
                        side: const BorderSide(
                          color: Color(0xFF3A3A3A),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenWidth < 360 ? 14 : 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _fromDateTime != null && _toDateTime != null
                          ? () {
                              if (_toDateTime!.isAfter(_fromDateTime!)) {
                                Navigator.pop(context, {
                                  'from': _fromDateTime,
                                  'to': _toDateTime,
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'End time must be after start time',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        disabledBackgroundColor: const Color(0xFF3A3A3A),
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth < 360 ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Play',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth < 360 ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTimeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? dateTime;
  final VoidCallback onTap;

  const _DateTimeCard({
    required this.label,
    required this.icon,
    required this.dateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: dateTime != null
                ? const Color(0xFF4CAF50).withOpacity(0.5)
                : const Color(0xFF3A3A3A),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: dateTime != null
                      ? const Color(0xFF4CAF50)
                      : Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: dateTime != null ? Colors.white : Colors.white54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (dateTime != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(dateTime!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeFormat.format(dateTime!),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Tap to select date & time',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Usage in your LiveCameraScreen:
// Replace the entire playback button Row with this:

/*
Center(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ElevatedButton.icon(
        onPressed: () async {
          // If currently playing live, pause it first
          if (_viewModel.isPlaying) {
            _viewModel.togglePlayback();
          } else {
            // Show playback dialog
            final result = await showDialog<Map<String, DateTime>>(
              context: context,
              builder: (context) => const PlaybackDialog(),
            );

            if (result != null) {
              final fromTime = result['from'];
              final toTime = result['to'];
              // Load playback video for the selected time range
              // _viewModel.loadPlayback(fromTime!, toTime!);
              print('From: $fromTime, To: $toTime');
            }
          }
        },
        icon: Icon(
          _viewModel.isPlaying ? Icons.pause_circle : Icons.play_circle,
          color: Colors.white,
        ),
        label: Text(
          _viewModel.isPlaying ? 'Pause' : 'Playback',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A3A3A),
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
      CircularIconButton(
        icon: Icons.chevron_right,
        backgroundColor: const Color(0xFF3A3A3A),
        onPressed: () {},
      ),
    ],
  ),
),
*/
