import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulation du splash screen (redirection vers home après 2s)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.droplet,
              color: AppColors.sangVieRed,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'SangVie',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
