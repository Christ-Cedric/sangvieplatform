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

    return Scaffold(body: child);
  }

  Widget _buildLanguageButton(BuildContext context, LanguageService service,
      String label, String code) {
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
