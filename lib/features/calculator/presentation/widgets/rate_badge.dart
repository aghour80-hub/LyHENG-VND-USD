import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/exchange_rate.dart';

class RateBadgeSection extends StatelessWidget {
  final ExchangeRate rate;
  final bool isUsdToVndActive;
  final String buyLabel;
  final String sellLabel;
  final VoidCallback? onBuyTap;
  final VoidCallback? onSellTap;

  const RateBadgeSection({
    super.key,
    required this.rate,
    required this.isUsdToVndActive,
    required this.buyLabel,
    required this.sellLabel,
    this.onBuyTap,
    this.onSellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // BUY RATE CARD (Customer sells USD -> Uses BUY RATE)
        Expanded(
          child: _RateCard(
            label: buyLabel,
            rateText: CurrencyFormatter.formatRate(rate.buyRate, includeSymbol: false),
            subtext: 'VND / USD',
            isActive: isUsdToVndActive,
            themeColor: AppColors.buyRateGreen,
            lightBgColor: isUsdToVndActive ? AppColors.buyRateGreenLight : Colors.white,
            darkBgColor: isUsdToVndActive 
                ? const Color(0xFF064E3B) 
                : AppColors.darkSurface,
            onTap: onBuyTap,
          ),
        ),
        const SizedBox(width: 12),
        // SELL RATE CARD (Customer buys USD -> Uses SELL RATE)
        Expanded(
          child: _RateCard(
            label: sellLabel,
            rateText: CurrencyFormatter.formatRate(rate.sellRate, includeSymbol: false),
            subtext: 'VND / USD',
            isActive: !isUsdToVndActive,
            themeColor: AppColors.sellRateRed,
            lightBgColor: !isUsdToVndActive ? AppColors.sellRateRedLight : Colors.white,
            darkBgColor: !isUsdToVndActive 
                ? const Color(0xFF4C0519) 
                : AppColors.darkSurface,
            onTap: onSellTap,
          ),
        ),
      ],
    );
  }
}

class _RateCard extends StatelessWidget {
  final String label;
  final String rateText;
  final String subtext;
  final bool isActive;
  final Color themeColor;
  final Color lightBgColor;
  final Color darkBgColor;
  final VoidCallback? onTap;

  const _RateCard({
    required this.label,
    required this.rateText,
    required this.subtext,
    required this.isActive,
    required this.themeColor,
    required this.lightBgColor,
    required this.darkBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? darkBgColor : lightBgColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? themeColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isActive ? 2.0 : 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: isActive ? themeColor : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  rateText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
