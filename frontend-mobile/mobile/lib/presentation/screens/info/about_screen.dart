import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.droplets, color: AppColors.primary, size: 60),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SangVieTypography.h2('SangVie v1.0.0'),
          const SizedBox(height: AppSpacing.md),
          SangVieTypography.body(
            'SangVie est une plateforme solidaire dédiée au don de sang. Notre mission est de connecter les donneurs de sang avec les établissements de santé de manière rapide et sécurisée.',
          ),
          const SizedBox(height: AppSpacing.lg),
          SangVieTypography.h3('Notre Vision'),
          const SizedBox(height: AppSpacing.sm),
          SangVieTypography.body(
            'Sauver des vies en facilitant l\'accès au don de sang partout et à tout moment.',
          ),
          const SizedBox(height: AppSpacing.lg),
          SangVieTypography.h3('Contactez-nous'),
          const SizedBox(height: AppSpacing.sm),
          const ListTile(
            leading: Icon(LucideIcons.mail, color: AppColors.primary),
            title: Text('contact@sangvie.com'),
          ),
          const ListTile(
            leading: Icon(LucideIcons.globe, color: AppColors.primary),
            title: Text('www.sangvie.com'),
          ),
        ],
      ),
    );
  }
}
