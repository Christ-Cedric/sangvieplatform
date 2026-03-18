import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/core/services/language_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/public_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final isFrench = languageService.locale.languageCode == 'fr';

    return PublicLayout(
      child: Stack(
        children: [
          // Premium Background Gradient & Pattern
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              gradient: RadialGradient(
                center: const Alignment(0.8, -0.6),
                radius: 1.2,
                colors: [
                  AppColors.primarySoft.withOpacity(0.6),
                  AppColors.background,
                ],
              ),
            ),
          ),
          
          // Floating Shapes for Depth
          Positioned(
            top: -50,
            right: -50,
            child: _buildDecorativeCircle(200, AppColors.primarySoft.withOpacity(0.4)),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: _buildDecorativeCircle(250, AppColors.primarySoft.withOpacity(0.3)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  
                  // Logo/Icon Animation
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.droplets, color: AppColors.primary, size: 50),
                      ),
                    ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).fadeIn(),
                  ),
                  
                  const SizedBox(height: AppSpacing.xxl),

                  // Main Headline
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: AppColors.foreground,
                        height: 1.1,
                        letterSpacing: -1.5,
                      ),
                      children: [
                        TextSpan(
                          text: isFrench ? "Sauvez des " : "Save ",
                        ),
                        const TextSpan(
                          text: "VIES",
                          style: TextStyle(color: AppColors.primary, letterSpacing: -1),
                        ),
                        TextSpan(
                          text: isFrench ? "\nen un clic." : "\nin a click.",
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      isFrench
                        ? "La plateforme moderne qui connecte les donneurs aux hôpitaux pour un impact immédiat."
                        : "The modern platform connecting donors with hospitals for immediate impact.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.2, end: 0),

                  const Spacer(flex: 2),

                  // Action Buttons
                  Column(
                    children: [
                      SangVieButton(
                        label: isFrench ? "Commencer" : "Get Started",
                        onPressed: () => context.push('/login'),
                        icon: const Icon(LucideIcons.arrowRight, size: 20),
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      TextButton(
                        onPressed: () => context.push('/register'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isFrench ? "Créer un compte" : "Create an account",
                              style: const TextStyle(
                                color: AppColors.foreground,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 800.ms),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
