import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isEnglishMode = false;

  bool get isEnglishMode => _isEnglishMode;

  void toggleLanguage(bool value) {
    _isEnglishMode = value;
    notifyListeners();
  }
}
