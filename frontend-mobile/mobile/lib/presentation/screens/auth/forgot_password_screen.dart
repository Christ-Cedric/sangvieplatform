import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/language_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/public_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSent = false;

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final t = languageService.t;

    return PublicLayout(
      child: Container(
        color: const Color(0xFFF9F9F9),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: _isSent ? _buildSentView(t) : _buildFormView(t),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(String Function(String, {Map<String, String>? params}) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SangVieTypography.h1(t('auth.forgot.title'), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        SangVieTypography.body(t('auth.forgot.subtitle'), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        SangVieInput(
          label: t('auth.forgot.identifier'),
          hint: "votre@email.com ou +226...",
          controller: _controller,
        ),
        const SizedBox(height: 24),
        SangVieButton(
          label: t('auth.forgot.submit'),
          onPressed: () => setState(() => _isSent = true),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            t('auth.forgot.backToLogin'),
            style: const TextStyle(color: AppColors.mutedForeground),
          ),
        ),
      ],
    );
  }

  Widget _buildSentView(String Function(String, {Map<String, String>? params}) t) {
    return Column(
      children: [
        const Icon(LucideIcons.mail, size: 64, color: AppColors.sangVieRed),
        const SizedBox(height: 24),
        SangVieTypography.h1(t('auth.forgot.sentTitle'), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        SangVieTypography.body(
          t('auth.forgot.sentDescription', params: {'identifier': _controller.text}),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SangVieButton(
          label: t('auth.forgot.backToLogin'),
          onPressed: () => context.go('/login'),
          isFullWidth: true,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SangVieTypography.small(t('auth.forgot.notReceived')),
            TextButton(
              onPressed: () {},
              child: Text(
                t('auth.forgot.resend'),
                style: const TextStyle(color: AppColors.sangVieRed, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
