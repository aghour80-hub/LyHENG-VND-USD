import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusBanner extends StatelessWidget {
  final bool isOffline;
  final bool isDemo;
  final String? lastSyncedTime;
  final String offlineText;
  final String demoText;

  const StatusBanner({
    super.key,
    required this.isOffline,
    required this.isDemo,
    this.lastSyncedTime,
    required this.offlineText,
    required this.demoText,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && !isDemo) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDemo 
            ? AppColors.warningAmberLight 
            : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDemo ? AppColors.warningAmber : AppColors.sellRateRed,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isDemo ? Icons.warning_amber_rounded : Icons.cloud_off_rounded,
            size: 20,
            color: isDemo ? AppColors.warningAmber : AppColors.sellRateRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDemo ? demoText : offlineText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDemo 
                        ? const Color(0xFF92400E) 
                        : const Color(0xFF991B1B),
                  ),
                ),
                if (isOffline && lastSyncedTime != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Đồng bộ lần cuối: $lastSyncedTime',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF991B1B).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
