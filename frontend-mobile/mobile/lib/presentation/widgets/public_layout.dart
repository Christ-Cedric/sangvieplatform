import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/language_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';

class PublicLayout extends StatelessWidget {
  final Widget child;

  const PublicLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.droplets, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'SangVie',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          _buildLanguageButton(context, languageService, 'FR', 'fr'),
          const VerticalDivider(width: 1, indent: 20, endIndent: 20),
          _buildLanguageButton(context, languageService, 'EN', 'en'),
          const SizedBox(width: 8),
        ],
      ),
      body: child,
    );
  }

  Widget _buildLanguageButton(BuildContext context, LanguageService service, String label, String code) {
    final isSelected = service.locale.languageCode == code;
    return TextButton(
      onPressed: () => service.setLanguage(code),
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.mutedForeground,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
