import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkModeProvider extends ChangeNotifier {
  static const String _key = 'dark_mode_enabled';
  bool _isDark = false;

  bool get isDark => _isDark;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDark);
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    _isDark = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDark);
    notifyListeners();
  }
}

class DarkModeToggleWidget extends StatelessWidget {
  const DarkModeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = DarkModeProvider();
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => provider.toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD9E7F3)),
        ),
        child: Icon(
          provider.isDark ? Icons.dark_mode : Icons.light_mode,
          size: 20,
          color: const Color(0xFF0F1F45),
        ),
      ),
    );
  }
}
