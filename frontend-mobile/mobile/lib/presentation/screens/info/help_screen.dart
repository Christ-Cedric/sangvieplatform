import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildFaqItem(
          'Comment puis-je donner du sang ?',
          'Il vous suffit de créer un compte donneur, de consulter les demandes à proximité sur la carte ou le flux, et de cliquer sur "Répondre".',
        ),
        _buildFaqItem(
          'Quels sont les critères pour être donneur ?',
          'Il faut généralement être majeur, peser plus de 50kg et être en bonne santé. Consultez un médecin en cas de doute.',
        ),
        _buildFaqItem(
          'Est-ce que SangVie est gratuit ?',
          'Oui, SangVie est une plateforme 100% gratuite pour les donneurs et les hôpitaux partenaires.',
        ),
        const SizedBox(height: AppSpacing.xl),
        SangVieTypography.h3('Besoin d\'une assistance directe ?'),
        const SizedBox(height: AppSpacing.md),
        SangVieButton(
          label: 'Envoyer un message au support',
          onPressed: () {
            // Action support
          },
          icon: const Icon(LucideIcons.messageSquare, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.foreground),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SangVieTypography.body(answer),
        ),
      ],
    );
  }
}
