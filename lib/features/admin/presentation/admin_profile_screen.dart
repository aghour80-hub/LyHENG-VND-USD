import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminProfile),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryNavy,
              child: Icon(Icons.person_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              authState.userEmail ?? 'admin@lyheng.com',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.buyRateGreenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'QUẢN TRỊ VIÊN ĐƯỢC ỦY QUYỀN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.buyRateGreen,
                ),
              ),
            ),
            const SizedBox(height: 24),

            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileRow('ID Người dùng', authState.userId ?? 'N/A'),
                  const Divider(height: 20),
                  _buildProfileRow('Vai trò', 'Quản trị viên (Admin)'),
                  const Divider(height: 20),
                  _buildProfileRow('Bảo mật', 'Supabase RLS & PostgreSQL Functions'),
                ],
              ),
            ),

            const Spacer(),

            AppButton(
              text: l10n.signOut,
              icon: Icons.logout_rounded,
              backgroundColor: AppColors.sellRateRed,
              onPressed: () async {
                await ref.read(authRepositoryProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
