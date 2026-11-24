import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/exchange_rate_repository.dart';
import '../../../features/calculator/domain/currency_calculator.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

class PreviewRateScreen extends ConsumerStatefulWidget {
  final Decimal newBuyRate;
  final Decimal newSellRate;

  const PreviewRateScreen({
    super.key,
    required this.newBuyRate,
    required this.newSellRate,
  });

  @override
  ConsumerState<PreviewRateScreen> createState() => _PreviewRateScreenState();
}

class _PreviewRateScreenState extends ConsumerState<PreviewRateScreen> {
  bool _isPublishing = false;
  String? _errorMessage;

  Future<void> _showConfirmDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.publishConfirmTitle),
        content: Text(l10n.publishConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _executePublish();
    }
  }

  Future<void> _executePublish() async {
    setState(() {
      _isPublishing = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(exchangeRateRepositoryProvider);
      await repo.publishNewRate(
        buyRate: widget.newBuyRate,
        sellRate: widget.newSellRate,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.publishedSuccess),
            backgroundColor: AppColors.buyRateGreen,
          ),
        );
        context.go('/admin/dashboard');
      }
    } catch (e) {
      setState(() {
        _isPublishing = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentRate = ref.watch(exchangeRateRepositoryProvider).currentRate;

    // Sample calculations with new rates for preview
    final sample100Usd = CurrencyCalculator.calculate(
      direction: CalculationDirection.usdToVnd,
      amount: Decimal.parse('100'),
      buyRate: widget.newBuyRate,
      sellRate: widget.newSellRate,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.previewNewRates),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.sellRateRed),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Comparison Table
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SO SÁNH TỶ GIÁ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lightTextSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Expanded(child: SizedBox.shrink()),
                      Expanded(
                        child: Text(
                          'Hiện tại (v${currentRate.version})',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Mới (v${currentRate.version + 1})',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // BUY RATE row
                  _buildComparisonRow(
                    label: l10n.buyRate,
                    currentVal: CurrencyFormatter.formatRate(currentRate.buyRate, includeSymbol: false),
                    newVal: CurrencyFormatter.formatRate(widget.newBuyRate, includeSymbol: false),
                    color: AppColors.buyRateGreen,
                  ),
                  const Divider(height: 20),

                  // SELL RATE row
                  _buildComparisonRow(
                    label: l10n.sellRate,
                    currentVal: CurrencyFormatter.formatRate(currentRate.sellRate, includeSymbol: false),
                    newVal: CurrencyFormatter.formatRate(widget.newSellRate, includeSymbol: false),
                    color: AppColors.sellRateRed,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Calculator Preview Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VÍ DỤ TÍNH TOÁN VỚI TỶ GIÁ MỚI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lightTextSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '100 USD (Khách bán USD) = ${sample100Usd.formattedResult}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            AppButton(
              text: l10n.publishRates,
              icon: Icons.cloud_upload_rounded,
              isLoading: _isPublishing,
              onPressed: _showConfirmDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required String currentVal,
    required String newVal,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: Text(
            currentVal,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            newVal,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
