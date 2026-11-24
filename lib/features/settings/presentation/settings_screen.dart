import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/widgets/app_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authRepositoryProvider);

    String getLocaleName(Locale loc) {
      switch (loc.languageCode) {
        case 'km':
          return 'ខ្មែរ (Khmer)';
        case 'en':
          return 'English';
        case 'vi':
        default:
          return 'Tiếng Việt';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Settings Section
          Text(
            l10n.settings.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),

          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.primaryBlueAccent),
                  title: Text(l10n.language),
                  subtitle: Text(getLocaleName(currentLocale)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/language'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.brightness_6_rounded, color: AppColors.warningAmber),
                  title: Text(l10n.theme),
                  subtitle: Text(_getThemeName(themeMode, l10n)),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    underline: const SizedBox.shrink(),
                    onChanged: (mode) {
                      if (mode != null) {
                        ref.read(themeModeProvider.notifier).setThemeMode(mode);
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(l10n.themeSystem),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(l10n.themeLight),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(l10n.themeDark),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.buyRateGreen),
                  title: Text(l10n.rateDetails),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/rate-details'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.article_outlined, color: AppColors.primaryNavyLight),
                  title: Text(l10n.about),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings/about'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Admin Section
          Text(
            'QUẢN TRỊ / ADMIN',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),

          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryNavy),
              title: Text(
                authState.isAuthenticated && authState.isAuthorizedAdmin
                    ? l10n.adminDashboard
                    : l10n.adminLogin,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                authState.isAuthenticated && authState.isAuthorizedAdmin
                    ? 'Đã đăng nhập: ${authState.userEmail ?? "Admin"}'
                    : 'Dành riêng cho nhân viên quản lý tỷ giá',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                if (authState.isAuthenticated && authState.isAuthorizedAdmin) {
                  context.push('/admin/dashboard');
                } else {
                  context.push('/admin/login');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
      case ThemeMode.system:
        return l10n.themeSystem;
    }
  }
}
