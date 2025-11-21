// lib/services/localization.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Localization {
  final Locale locale;
  
  Localization(this.locale);
  
  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization)!;
  }
  
  Map<String, dynamic>? _localizedValues;
  
  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('lib/languages/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedValues = jsonMap;
    return true;
  }
  
  String translate(String key) {
    return _localizedValues?[key] ?? key;
  }
}

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  const LocalizationDelegate(); // Make sure this is const
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'fr'].contains(locale.languageCode);
  }
  
  @override
  Future<Localization> load(Locale locale) async {
    Localization localization = Localization(locale);
    await localization.load();
    return localization;
  }
  
  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}