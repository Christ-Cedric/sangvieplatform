import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/hospital_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';

class HospitalProfileScreen extends StatelessWidget {
  const HospitalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const HospitalLayout(
          child: Center(
              child: CircularProgressIndicator(color: AppColors.primary)));
    }

    return HospitalLayout(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, user),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInfoCard(user),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSettingsSection(context, authService),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 100, AppSpacing.lg, 40),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 20)
                  ],
                ),
                child: const Center(
                  child: Icon(LucideIcons.building2,
                      color: AppColors.primary, size: 45),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: AppColors.successGreen, shape: BoxShape.circle),
                child: const Icon(LucideIcons.check,
                    color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            user.nom,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Établissement Certifié',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
            child: _statItem('Demandes', '12', LucideIcons.activity,
                AppColors.warningOrange)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child: _statItem('Réponses', '45', LucideIcons.users,
                AppColors.successGreen)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child: _statItem(
                'Urgent', '3', LucideIcons.alertTriangle, AppColors.destructive)),
      ],
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text(label,
              style: const TextStyle(color: AppColors.secondary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(dynamic user) {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informations Générales',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: AppSpacing.lg),
          _infoRow(LucideIcons.mail, 'Adresse Email', user.email),
          const Divider(height: 24),
          _infoRow(LucideIcons.phone, 'Contact Téléphonique',
              user.telephone ?? 'Non renseigné'),
          const Divider(height: 24),
          _infoRow(LucideIcons.mapPin, 'Siège Social / Adresse',
              'Libreville, Gabon'), // Mock address if not provided
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.secondary, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthService auth) {
    return Column(
      children: [
        _actionItem(LucideIcons.user, 'Modifier mes informations', () {}),
        const SizedBox(height: AppSpacing.md),
        _actionItem(LucideIcons.lock, 'Changer de mot de passe', () {}),
        const SizedBox(height: AppSpacing.md),
        _actionItem(LucideIcons.logOut, 'Déconnexion', () async {
          await auth.logout();
          if (context.mounted) context.go('/login');
        }, isLogout: true),
      ],
    );
  }

  Widget _actionItem(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    final color = isLogout ? AppColors.destructive : AppColors.foreground;
    return SangVieCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 16),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14, color: color)),
          const Spacer(),
          Icon(LucideIcons.chevronRight, size: 16, color: color.withOpacity(0.3)),
        ],
      ),
    );
  }
}
