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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header with Gradient
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Paramètres',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // Profile Avatar Overlap
                Positioned(
                  bottom: -45,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: AppColors.primarySoft,
                      child: Text(
                        user?.nom.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 55),
            
            // User Information
            Text(
              user?.nom ?? 'Utilisateur',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondary.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            // Edit Profile Button
            OutlinedButton(
              onPressed: () => context.push('/donor/profile'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(140, 40),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Éditer le Profil',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Settings Groups
            _buildSectionHeader('COMPTE'),
            _buildSettingTile(
              icon: LucideIcons.bell,
              label: 'Notifications',
              onTap: () {},
              trailing: Switch.adaptive(
                value: true,
                onChanged: (_) {},
                activeColor: AppColors.primary,
              ),
            ),
            _buildSettingTile(
              icon: LucideIcons.heart,
              label: 'Favoris',
              onTap: () {},
            ),
            
            const SizedBox(height: 16),
            _buildSectionHeader('PRÉFÉRENCES'),
            _buildThemeToggle(context, themeService),
            _buildSettingTile(
              icon: LucideIcons.languages,
              label: 'Langues',
              onTap: () {},
              subtitle: 'Français',
            ),
            _buildSettingTile(
              icon: LucideIcons.shieldCheck,
              label: 'Confidentialité',
              onTap: () => context.push('/info/privacy'),
            ),
            
            const SizedBox(height: 16),
            _buildSectionHeader('AUTRES'),
            _buildSettingTile(
              icon: LucideIcons.helpCircle,
              label: 'Aide et Support',
              onTap: () => context.push('/info/help'),
            ),
            _buildSettingTile(
              icon: LucideIcons.info,
              label: 'À propos',
              onTap: () => context.push('/info/about'),
            ),
            
            const SizedBox(height: 32),
            
            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SangVieButton(
                label: 'Déconnexion',
                onPressed: () {
                  authService.logout();
                  context.go('/login');
                },
                backgroundColor: AppColors.destructive.withOpacity(0.1),
                foregroundColor: AppColors.destructive,
              ),
            ),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: Colors.grey.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(icon, color: AppColors.foreground.withOpacity(0.8), size: 22),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.foreground,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.secondary.withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(width: 8),
          trailing ?? Icon(LucideIcons.chevronRight, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeService themeService) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(
        themeService.isDarkMode ? LucideIcons.moon : LucideIcons.sun,
        color: AppColors.foreground.withOpacity(0.8),
        size: 22,
      ),
      title: Text(
        themeService.isDarkMode ? 'Mode Sombre' : 'Mode Clair',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.foreground,
        ),
      ),
      trailing: Switch.adaptive(
        value: themeService.isDarkMode,
        onChanged: (val) => themeService.toggleTheme(),
        activeColor: AppColors.primary,
      ),
    );
  }
}
