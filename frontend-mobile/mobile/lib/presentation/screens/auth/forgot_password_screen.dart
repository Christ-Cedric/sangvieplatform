import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/language_service.dart';
import 'package:sangvie/presentation/widgets/public_layout.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFF0F2F5),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.droplets,
                        size: 40,
                        color: Color(0xFFE53E3E),
                      ),
                    ).animate().fadeIn().scale(delay: 100.ms),
                  ),
                  const SizedBox(height: 32),

                  _isSent ? _buildSentView(t) : _buildFormView(t),
                ],
              ),
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
        const Text(
          "Mot de passe oublié?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          t('auth.forgot.subtitle'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF718096),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 32),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: "Email ou Téléphone",
              labelStyle: const TextStyle(
                color: Color(0xFF718096),
                fontWeight: FontWeight.w500,
              ),
              hintText: "votre@email.com ou +226...",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE53E3E),
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 24),

        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => setState(() => _isSent = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "RÉINITIALISER",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 16),

        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text(
            "Retour à la connexion",
            style: TextStyle(
              color: Color(0xFFE53E3E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildSentView(String Function(String, {Map<String, String>? params}) t) {
    return Column(
      children: [
        const Icon(LucideIcons.mail, size: 64, color: Color(0xFFE53E3E)),
        const SizedBox(height: 24),
        const Text(
          "Email Envoyé",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A5568),
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        Text(
          t('auth.forgot.sentDescription', params: {'identifier': _controller.text}),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF718096),
            fontSize: 15,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "RETOUR AU LOGIN",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Pas reçu?",
              style: TextStyle(color: Color(0xFF718096)),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Renvoyer",
                style: TextStyle(
                  color: Color(0xFFE53E3E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }
}
