import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/localization/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/repositories/exchange_rate_repository.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/status_banner.dart';
import '../domain/currency_calculator.dart';
import 'calculator_controller.dart';
import 'widgets/custom_keypad.dart';
import 'widgets/rate_badge.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rateAsync = ref.watch(activeExchangeRateStreamProvider);
    final repo = ref.watch(exchangeRateRepositoryProvider);
    final currentRate = rateAsync.value ?? repo.currentRate;
    final networkStatus = ref.watch(networkStatusProvider).value ?? NetworkStatus.online;
    final isOffline = networkStatus == NetworkStatus.offline;

    final calcState = ref.watch(calculatorControllerProvider);
    final calcController = ref.read(calculatorControllerProvider.notifier);

    final isUsdToVnd = calcState.direction == CalculationDirection.usdToVnd;

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(size: 34, showText: true),
        centerTitle: false,
        actions: [
          // Network connection badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: isOffline
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isOffline ? AppColors.statusOffline : AppColors.statusOnline,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isOffline ? l10n.statusOffline : l10n.statusOnline,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isOffline
                        ? const Color(0xFF991B1B)
                        : const Color(0xFF065F46),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(exchangeRateRepositoryProvider).refreshActiveRate();
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Status / Warning Banner
                      StatusBanner(
                        isOffline: isOffline,
                        isDemo: currentRate.isDemo,
                        lastSyncedTime: repo.lastSyncTime != null
                            ? DateFormatter.formatShort(repo.lastSyncTime!)
                            : null,
                        offlineText: l10n.offlineWarning,
                        demoText: l10n.demoWarning,
                      ),

                      // Exchange Rate Badges (BUY & SELL)
                      RateBadgeSection(
                        rate: currentRate,
                        isUsdToVndActive: isUsdToVnd,
                        buyLabel: l10n.buyRate,
                        sellLabel: l10n.sellRate,
                        onBuyTap: () => calcController.setDirection(CalculationDirection.usdToVnd),
                        onSellTap: () => calcController.setDirection(CalculationDirection.vndToUsd),
                      ),

                      const SizedBox(height: 8),

                      // Rate Metadata row (Version + Last updated)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l10n.rateVersion}: v${currentRate.version}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              '${l10n.lastUpdated}: ${DateFormatter.formatShort(currentRate.updatedAt)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Direction Selector Tabs
                      AppCard(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: _DirectionTab(
                                label: l10n.usdToVnd,
                                isSelected: isUsdToVnd,
                                activeColor: AppColors.buyRateGreen,
                                onTap: () => calcController.setDirection(CalculationDirection.usdToVnd),
                              ),
                            ),
                            Expanded(
                              child: _DirectionTab(
                                label: l10n.vndToUsd,
                                isSelected: !isUsdToVnd,
                                activeColor: AppColors.sellRateRed,
                                onTap: () => calcController.setDirection(CalculationDirection.vndToUsd),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Calculator Input & Result Box
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Direction description / formula
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    isUsdToVnd ? l10n.usdToVndDesc : l10n.vndToUsdDesc,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isUsdToVnd ? l10n.formulaUsdToVnd : l10n.formulaVndToUsd,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isUsdToVnd ? AppColors.buyRateGreen : AppColors.sellRateRed,
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 16),

                            // Input Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  isUsdToVnd ? 'USD' : 'VND',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isUsdToVnd ? AppColors.primaryBlueAccent : AppColors.sellRateRed,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    calcState.inputString.isEmpty ? '0' : calcState.inputString,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                if (calcState.inputString.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: calcController.clear,
                                    tooltip: l10n.clear,
                                  ),
                              ],
                            ),

                            const Divider(height: 16),

                            // Result Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  isUsdToVnd ? 'VND' : 'USD',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isUsdToVnd ? AppColors.sellRateRed : AppColors.primaryBlueAccent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      calcState.result?.formattedResult ?? '0',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: isUsdToVnd ? AppColors.buyRateGreen : AppColors.primaryNavy,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Action buttons: Copy, Share, Swap
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.copy_rounded, size: 16),
                                    label: Text(l10n.copy, style: const TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      minimumSize: Size.zero,
                                    ),
                                    onPressed: calcState.result == null
                                        ? null
                                        : () {
                                            Clipboard.setData(
                                              ClipboardData(text: calcState.result!.formattedResult),
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(l10n.copied),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.share_rounded, size: 16),
                                    label: Text(l10n.share, style: const TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      minimumSize: Size.zero,
                                    ),
                                    onPressed: calcState.result == null
                                        ? null
                                        : () {
                                            Share.share(
                                              'LyHENG VND-USD\n${calcState.result!.formulaDescription}',
                                              subject: 'Tỷ giá LyHENG VND-USD',
                                            );
                                          },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.outlined(
                                  icon: const Icon(Icons.swap_vert_rounded, size: 20),
                                  tooltip: l10n.swapDirection,
                                  onPressed: calcController.swapDirection,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Fast Numeric Keypad
                      CustomKeypad(
                        showDecimal: isUsdToVnd,
                        onKeyPress: calcController.appendInput,
                        onDelete: calcController.deleteChar,
                        onClear: calcController.clear,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DirectionTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _DirectionTab({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }
}
