import 'package:flutter/material.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SangVieTypography.h2('Politique de confidentialité'),
          const SizedBox(height: AppSpacing.md),
          SangVieTypography.small('Dernière mise à jour : 13 Mars 2024'),
          const SizedBox(height: AppSpacing.xl),
          SangVieTypography.h3('1. Collecte des données'),
          const SizedBox(height: AppSpacing.sm),
          SangVieTypography.body(
            'Nous collectons vos informations personnelles (Nom, contact, groupe sanguin) uniquement pour faciliter le processus de don de sang.',
          ),
          const SizedBox(height: AppSpacing.lg),
          SangVieTypography.h3('2. Utilisation des données'),
          const SizedBox(height: AppSpacing.sm),
          SangVieTypography.body(
            'Vos données permettent aux hôpitaux de vous contacter en cas de besoin urgent et de valider votre éligibilité au don.',
          ),
          const SizedBox(height: AppSpacing.lg),
          SangVieTypography.h3('3. Sécurité'),
          const SizedBox(height: AppSpacing.sm),
          SangVieTypography.body(
            'SangVie utilise des protocoles de chiffrement avancés pour garantir la sécurité de vos données de santé.',
          ),
          const SizedBox(height: AppSpacing.lg),
          SangVieTypography.h3('4. Vos droits'),
          const SizedBox(height: AppSpacing.sm),
          SangVieTypography.body(
            'Vous disposez d\'un droit d\'accès, de rectification et de suppression de vos données à tout moment depuis votre profil.',
          ),
        ],
      ),
    );
  }
}
