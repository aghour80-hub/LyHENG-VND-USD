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

class EditRateScreen extends ConsumerStatefulWidget {
  const EditRateScreen({super.key});

  @override
  ConsumerState<EditRateScreen> createState() => _EditRateScreenState();
}

class _EditRateScreenState extends ConsumerState<EditRateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _buyRateController;
  late final TextEditingController _sellRateController;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(exchangeRateRepositoryProvider);
    _buyRateController = TextEditingController(
      text: repo.currentRate.buyRate.toString(),
    );
    _sellRateController = TextEditingController(
      text: repo.currentRate.sellRate.toString(),
    );
  }

  @override
  void dispose() {
    _buyRateController.dispose();
    _sellRateController.dispose();
    super.dispose();
  }

  void _proceedToPreview() {
    if (!_formKey.currentState!.validate()) return;

    final buy = CurrencyCalculator.parseAndValidateRate(_buyRateController.text);
    final sell = CurrencyCalculator.parseAndValidateRate(_sellRateController.text);

    if (buy == null || sell == null) return;

    context.push(
      '/admin/preview-rates',
      extra: {
        'buyRate': buy,
        'sellRate': sell,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentRate = ref.watch(exchangeRateRepositoryProvider).currentRate;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newRates),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBlueAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primaryBlueAccent, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Nhập tỷ giá mới cẩn thận. Tỷ giá sau khi xuất bản sẽ được đồng bộ ngay lập tức tới tất cả người dùng.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Current reference
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tỷ giá hiện tại (v${currentRate.version}):',
                      style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                    ),
                    Text(
                      'BUY: ${CurrencyFormatter.formatRate(currentRate.buyRate, includeSymbol: false)} | SELL: ${CurrencyFormatter.formatRate(currentRate.sellRate, includeSymbol: false)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // BUY RATE Input
              AppCard(
                padding: const EdgeInsets.all(16),
                borderColor: AppColors.buyRateGreen.withValues(alpha: 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward_rounded, color: AppColors.buyRateGreen, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          l10n.editBuyRate,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.buyRateGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Giá tiệm mua USD từ khách (VND cho 1 USD)',
                      style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _buyRateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      decoration: const InputDecoration(
                        suffixText: 'VND',
                        suffixStyle: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Vui lòng nhập giá mua';
                        final parsed = CurrencyCalculator.parseAndValidateRate(val);
                        if (parsed == null || parsed <= Decimal.zero) return l10n.invalidRate;
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // SELL RATE Input
              AppCard(
                padding: const EdgeInsets.all(16),
                borderColor: AppColors.sellRateRed.withValues(alpha: 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded, color: AppColors.sellRateRed, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          l10n.editSellRate,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.sellRateRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Giá tiệm bán USD cho khách (VND cho 1 USD)',
                      style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sellRateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      decoration: const InputDecoration(
                        suffixText: 'VND',
                        suffixStyle: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Vui lòng nhập giá bán';
                        final parsed = CurrencyCalculator.parseAndValidateRate(val);
                        if (parsed == null || parsed <= Decimal.zero) return l10n.invalidRate;
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              AppButton(
                text: l10n.previewNewRates,
                icon: Icons.visibility_rounded,
                onPressed: _proceedToPreview,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
