import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../shared/widgets/app_card.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    final languages = [
      {
        'code': AppConstants.localeVietnamese,
        'title': 'Tiếng Việt',
        'subtitle': 'Mặc định',
      },
      {
        'code': AppConstants.localeKhmer,
        'title': 'ខ្មែរ',
        'subtitle': 'Khmer',
      },
      {
        'code': AppConstants.localeEnglish,
        'title': 'English',
        'subtitle': 'English',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isSelected = currentLocale.languageCode == lang['code'];

          return AppCard(
            padding: const EdgeInsets.all(16),
            borderColor: isSelected ? AppColors.primaryBlueAccent : null,
            onTap: () {
              ref
                  .read(localeProvider.notifier)
                  .setLocale(Locale(lang['code']!));
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang['title']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.primaryBlueAccent : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lang['subtitle']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primaryBlueAccent,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
