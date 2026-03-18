import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/core/services/language_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/public_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final authService = Provider.of<AuthService>(context);
    final t = languageService.t;

    Future<void> _handleLogin() async {
      final identifier = _identifierController.text.trim();
      final password = _passwordController.text;

      if (identifier.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez remplir tous les champs")),
        );
        return;
      }

      final success = await authService.login(identifier, password);
      if (success) {
        final type = authService.currentUserType;
        if (type == UserType.admin) {
          context.go('/admin/dashboard');
        } else if (type == UserType.hospital) {
          context.go('/hospital/dashboard');
        } else {
          context.go('/donor/feed');
        }
      } else if (authService.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.error!),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }

    return PublicLayout(
      child: Stack(
        children: [
          // Background accents
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primarySoft.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: const Icon(LucideIcons.droplets, size: 36, color: AppColors.primary),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  ),
                  
                  const SizedBox(height: AppSpacing.xxl),
                  
                  // Welcome Text
                  SangVieTypography.h1(
                    t('auth.login.title'),
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    t('auth.login.subtitle'),
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
                  
                  const SizedBox(height: AppSpacing.xxxl),
                  
                  // Form
                  SangVieInput(
                    label: t('auth.login.identifier'),
                    hint: "Email ou téléphone",
                    controller: _identifierController,
                    prefixIcon: const Icon(LucideIcons.user, color: AppColors.mutedForeground, size: 20),
                    keyboardType: TextInputType.emailAddress,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  SangVieInput(
                    label: t('auth.login.password'),
                    hint: "Votre mot de passe",
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    prefixIcon: const Icon(LucideIcons.lock, color: AppColors.mutedForeground, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                        color: AppColors.mutedForeground,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        t('auth.login.forgot'),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Submit
                  SangVieButton(
                    label: t('auth.login.submit'),
                    onPressed: _handleLogin,
                    isLoading: authService.isLoading,
                    icon: const Icon(LucideIcons.logIn, size: 20, color: Colors.white),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: AppSpacing.xxl),
                  
                  // Footer
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t('auth.login.noAccount'),
                          style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: Text(
                            t('auth.login.createAccount'),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
