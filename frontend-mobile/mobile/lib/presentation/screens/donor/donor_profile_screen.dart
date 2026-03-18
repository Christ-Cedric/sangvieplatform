import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/donor_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';

class DonorProfileScreen extends StatelessWidget {
  const DonorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return DonorLayout(
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final initials = _initials(user.prenom, user.nom);

    return DonorLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primarySoft,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sangVieRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _roleLabel(user.role),
                style: const TextStyle(
                    color: AppColors.sangVieRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),

            const SizedBox(height: 32),

            // Infos from backend
            _infoCard(
              children: [
                if (user.email.isNotEmpty)
                  _infoRow(LucideIcons.mail, 'Email', user.email),
                if (user.telephone != null && user.telephone!.isNotEmpty)
                  _infoRow(LucideIcons.phone, 'Téléphone', user.telephone!),
                if (user.groupeSanguin != null && user.groupeSanguin!.isNotEmpty)
                  _infoRow(LucideIcons.droplet, 'Groupe Sanguin',
                      user.groupeSanguin!, iconColor: AppColors.sangVieRed),
              ],
            ),

            const SizedBox(height: 32),

            SangVieButton(
              label: 'Se déconnecter',
              onPressed: () async {
                await authService.logout();
                if (context.mounted) context.go('/');
              },
              backgroundColor: AppColors.inputBackground,
              foregroundColor: AppColors.destructive,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String _initials(String? prenom, String nom) {
    final p = prenom?.isNotEmpty == true ? prenom![0] : '';
    final n = nom.isNotEmpty ? nom[0] : '';
    return ('$p$n').toUpperCase();
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrateur';
      case 'hospital':
        return 'Établissement';
      default:
        return 'Donneur de sang';
    }
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color iconColor = AppColors.secondary}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.secondary, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
