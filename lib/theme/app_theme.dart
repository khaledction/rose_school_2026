import 'package:flutter/material.dart';

import 'app_palette.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.royalBlue,
      primary: AppPalette.deepNavy,
      secondary: AppPalette.gold,
      tertiary: AppPalette.leafGreen,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppPalette.sky,
    fontFamily: 'Tahoma',
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
