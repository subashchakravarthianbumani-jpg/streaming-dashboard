import 'package:flutter/material.dart';

/// A reusable loading overlay widgets that listens to a ChangeNotifier
/// and displays a full-screen loading indicator when isLoading is true
class LoadingOverlay extends StatelessWidget {
  final ChangeNotifier listenable;
  final bool Function(dynamic) isLoadingGetter;
  final String? loadingText;
  final Color? overlayColor;
  final Color? indicatorColor;

  const LoadingOverlay({
    Key? key,
    required this.listenable,
    required this.isLoadingGetter,
    this.loadingText,
    this.overlayColor,
    this.indicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, child) {
        final isLoading = isLoadingGetter(listenable);

        return isLoading
            ? Container(
                color: overlayColor ?? Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            indicatorColor ?? const Color(0xFF9A0F24),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "AppStrings ksPleaseWait",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}
