import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sangvie/app.dart';
import 'package:sangvie/core/services/auth_service.dart';
import 'package:sangvie/core/services/language_service.dart';
import 'package:sangvie/core/services/theme_service.dart';
import 'package:sangvie/core/providers/donor_provider.dart';
import 'package:sangvie/core/providers/hospital_provider.dart';
import 'package:sangvie/core/providers/admin_provider.dart';
import 'package:sangvie/core/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handlers pour les erreurs globales (évite les crash silencieux)-
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // Log en production
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Erreur globale: $error');
    return true;
  };

  try {
    // Initialisation du service de langue
    final languageService = LanguageService();
    await languageService.init();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: languageService),
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => ThemeService()),
          ChangeNotifierProvider(create: (_) => DonorProvider()),
          ChangeNotifierProvider(create: (_) => HospitalProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
          ChangeNotifierProxyProvider<AuthService, NotificationProvider>(
            create: (ctx) => NotificationProvider(
                Provider.of<AuthService>(ctx, listen: false)),
            update: (ctx, auth, previous) =>
                previous ?? NotificationProvider(auth),
          ),
        ],
        child: const SangVieApp(),
      ),
    );
  } catch (e) {
    debugPrint('Erreur fatale de démarrage: $e');
  }
}
