import 'package:flutter/material.dart';
import 'package:sangvie/core/constants/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  Locale _locale = const Locale('fr', '');
  
  Locale get locale => _locale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('sangvie-language') ?? 'fr';
    _locale = Locale(langCode, '');
    notifyListeners();
  }

  void setLanguage(String langCode) async {
    _locale = Locale(langCode, '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sangvie-language', langCode);
    notifyListeners();
  }

  // Helper pour les traductions statiques (reproduit le behavior de useTranslation)
  String t(String key, {Map<String, String>? params}) {
    final lang = _locale.languageCode;
    String value = AppStrings.translations[lang]?[key] ?? AppStrings.translations['fr']?[key] ?? key;

    if (params != null) {
      params.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }

    return value;
  }
}
