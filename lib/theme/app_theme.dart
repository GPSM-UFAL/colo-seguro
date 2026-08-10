import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF137A63);
  static const brandDark = Color(0xFF0C5446);
  static const textDark = Color(0xFF1E2A28);
  static const textMuted = Color(0xFF5C6B66);
  static const bgRose = Color(0xFFFFF7F4);
  static const bgSurface = Color(0xFFFFFDFC);
  static const surfaceWarm = Color(0xFFFFFDFA);
  static const surfaceLavender = Color(0xFFF1E7F1);
  static const borderWarm = Color(0xFFEAD8D2);
  static const borderLight = Color(0xFFEADFD6);
  static const surfacePink = Color(0xFFF4E8EF);
  static const surfaceLilac = Color(0xFFF5EEF4);
  static const alertBg = Color(0xFFF8DDE7);
  static const alert = Color(0xFF7C3E61);
  static const primaryDark = Color(0xFF6F4A62);
  static const primaryDarkest = Color(0xFF59394F);
  static const primaryShadow = Color(0x427C4A67);
  static const textDarkWarm = Color(0xFF2A1724);
  static const textBody = Color(0xFF3F3038);
  static const textSecondary = Color(0xFF6B5A61);
  static const textTertiary = Color(0xFF71635F);
  static const textMutedWarm = Color(0xFFA8959B);
  static const textOnPrimary = Color(0xFFFFFDFC);
  static const primaryPlum = Color(0xFF7C4A67);
  static const primaryDarker = Color(0xFF5C3B52);
  static const shadowLight = Color(0x176B4452);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgRose,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.bgRose,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgRose,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
