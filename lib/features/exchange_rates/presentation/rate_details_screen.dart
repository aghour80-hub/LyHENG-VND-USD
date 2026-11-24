import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/repositories/exchange_rate_repository.dart';
import '../../../shared/widgets/app_card.dart';

class RateDetailsScreen extends ConsumerWidget {
  const RateDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rateAsync = ref.watch(activeExchangeRateStreamProvider);
    final repo = ref.watch(exchangeRateRepositoryProvider);
    final rate = rateAsync.value ?? repo.currentRate;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rateDetails),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow(l10n.buyRate, CurrencyFormatter.formatRate(rate.buyRate), AppColors.buyRateGreen),
                const Divider(height: 24),
                _buildRow(l10n.sellRate, CurrencyFormatter.formatRate(rate.sellRate), AppColors.sellRateRed),
                const Divider(height: 24),
                _buildRow('Cặp tiền tệ', '${rate.currencyBase} / ${rate.currencyQuote}'),
                const Divider(height: 24),
                _buildRow(l10n.rateVersion, 'v${rate.version}'),
                const Divider(height: 24),
                _buildRow(l10n.lastUpdated, DateFormatter.formatFull(rate.updatedAt)),
                const Divider(height: 24),
                _buildRow('Trạng thái nguồn', rate.isDemo ? 'DEMO (Chưa xuất bản)' : 'Đã xuất bản (Live)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, [Color? valueColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
