import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const AppLogo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTextColor = textColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryNavy, Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryNavy.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.currency_exchange_rounded,
              color: AppColors.accentGreen,
              size: size * 0.58,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LyHENG',
                style: TextStyle(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w900,
                  color: effectiveTextColor,
                  letterSpacing: 0.5,
                  height: 1.1,
                ),
              ),
              Row(
                children: [
                  Text(
                    'VND',
                    style: TextStyle(
                      fontSize: size * 0.24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sellRateRed,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    ' ⇄ ',
                    style: TextStyle(
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    'USD',
                    style: TextStyle(
                      fontSize: size * 0.24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.buyRateGreen,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }
}
