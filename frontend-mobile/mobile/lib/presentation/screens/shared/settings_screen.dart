import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/core/services/theme_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final user = authService.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    user?.nom.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SangVieTypography.h3(user?.nom ?? 'Utilisateur'),
                      SangVieTypography.small(user?.email ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Sections
          _buildSectionHeader('Compte'),
          _buildSettingTile(
            icon: LucideIcons.user,
            label: 'Mon Profil',
            onTap: () => context.push('/donor/profile'),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('Préférences'),
          _buildThemeToggle(context, themeService),
          
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('Assistance & Légal'),
          _buildSettingTile(
            icon: LucideIcons.helpCircle,
            label: 'Aide et Support',
            onTap: () => context.push('/info/help'),
          ),
          _buildSettingTile(
            icon: LucideIcons.shieldCheck,
            label: 'Politique de confidentialité',
            onTap: () => context.push('/info/privacy'),
          ),
          _buildSettingTile(
            icon: LucideIcons.info,
            label: 'À propos de l\'application',
            onTap: () => context.push('/info/about'),
          ),

          const SizedBox(height: AppSpacing.xl),
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SangVieButton(
              label: 'Déconnexion',
              onPressed: () {
                authService.logout();
                context.go('/login');
              },
              backgroundColor: AppColors.primarySoft,
              foregroundColor: AppColors.primary,
              icon: const Icon(LucideIcons.logOut, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(height: 100), // Bottom nav space
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.secondary.withOpacity(0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.foreground, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppColors.foreground,
        ),
      ),
      trailing: trailing ?? Icon(LucideIcons.chevronRight, color: AppColors.secondary.withOpacity(0.5), size: 18),
      onTap: onTap,
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeService themeService) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          themeService.isDarkMode ? LucideIcons.moon : LucideIcons.sun,
          color: AppColors.foreground,
          size: 20,
        ),
      ),
      title: Text(
        themeService.isDarkMode ? 'Mode Sombre' : 'Mode Clair',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppColors.foreground,
        ),
      ),
      trailing: Switch.adaptive(
        value: themeService.isDarkMode,
        onChanged: (val) {
          themeService.toggleTheme();
        },
        activeColor: AppColors.primary,
      ),
    );
  }
}
