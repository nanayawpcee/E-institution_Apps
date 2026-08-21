import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_tokens.dart';

/// Dark mode is a switch on the profile screen in the design, so the choice is
/// app state and survives a restart.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _restore();
  }

  static const _key = 'tl_dark_mode';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool(_key);
    if (dark != null) state = dark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setDark(bool dark) async {
    state = dark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, dark);
  }

  Future<void> toggle() => setDark(state != ThemeMode.dark);
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class TLTheme {
  const TLTheme._();

  static ThemeData light() => _build(TLTokens.light, Brightness.light);
  static ThemeData dark() => _build(TLTokens.dark, Brightness.dark);

  static ThemeData _build(TLTokens t, Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[t],
      scaffoldBackgroundColor: t.bg,
      canvasColor: t.bg,
      dividerColor: t.border,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TLTokens.primary,
        brightness: brightness,
      ).copyWith(
        primary: TLTokens.primary,
        secondary: TLTokens.accent,
        error: TLTokens.danger,
        surface: t.card,
        onSurface: t.text,
      ),
      // Source Sans 3 reads; Poppins is applied per-widget through TLText so
      // headings stay deliberate rather than inherited by accident.
      textTheme: GoogleFonts.sourceSans3TextTheme(base.textTheme).apply(
        bodyColor: t.text,
        displayColor: t.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.bg,
        foregroundColor: t.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: t.text,
        ),
      ),
      cardTheme: CardThemeData(
        color: t.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TLTokens.rLg),
          side: BorderSide(color: t.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.sheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TLTokens.rXl),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.sheet,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: t.sheet,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF2C2D33)
            : const Color(0xFF1F2024),
        contentTextStyle: GoogleFonts.sourceSans3(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.input,
        hintStyle: GoogleFonts.sourceSans3(fontSize: 15, color: t.textSub),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: _fieldBorder(t.border),
        enabledBorder: _fieldBorder(t.border),
        focusedBorder: _fieldBorder(TLTokens.primary),
        errorBorder: _fieldBorder(TLTokens.danger),
        focusedErrorBorder: _fieldBorder(TLTokens.danger),
        errorStyle: GoogleFonts.sourceSans3(
          fontSize: 11.5,
          color: TLTokens.danger,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TLTokens.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TLTokens.rLg),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TLTokens.primary,
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? TLTokens.primary
              : t.border;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: TLTokens.primary),
    );
  }

  static OutlineInputBorder _fieldBorder(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: 1.5),
      );
}
