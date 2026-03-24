import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vibrant, fluid Telegram/iOS inspired palette
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color lightBlue = Color(0xFF5AC8FA);
  static const Color darkBlue = Color(0xFF0056B3);
  static const Color accentGreen = Color(0xFF34C759);
  static const Color lightGreen = Color(0xFF71D88A);
  
  static const Color backgroundColor = Color(0xFFF2F2F7); // iOS grouped background
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  
  static const Color errorColor = Color(0xFFFF3B30);
  static const Color warningColor = Color(0xFFFF9500);

  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF000000);
  static const Color darkCardColor = Color(0xFF1C1C1E);
  static const Color darkTextPrimary = Color(0xFFF2F2F7);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkSurfaceColor = Color(0xFF2C2C2E);

  // Premium Mesh Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF34C759), Color(0xFF71D88A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue, brightness: Brightness.light),
      scaffoldBackgroundColor: backgroundColor,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0, // Using manual soft shadows instead of rigid elevations
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Modern squircle
        shadowColor: const Color(0x0A000000), // Ultra soft
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryBlue, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(color: textSecondary),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue, brightness: Brightness.dark),
      scaffoldBackgroundColor: darkBackgroundColor,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(bodyColor: darkTextPrimary, displayColor: darkTextPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(color: darkTextPrimary, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryBlue, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(color: darkTextSecondary),
      ),
    );
  }

  // Precomputed text styles
  static TextStyle getHeadingLarge(BuildContext c) => Theme.of(c).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w700, letterSpacing: -1);
  static TextStyle getHeadingMedium(BuildContext c) => Theme.of(c).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.5);
  static TextStyle getHeadingSmall(BuildContext c) => Theme.of(c).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600);
  static TextStyle getBodyLarge(BuildContext c) => Theme.of(c).textTheme.bodyLarge!;
  static TextStyle getBodyMedium(BuildContext c) => Theme.of(c).textTheme.bodyMedium!;
  static TextStyle getBodySmall(BuildContext c) => Theme.of(c).textTheme.bodySmall!;
  
  static Color getBackgroundColor(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  static Color getCardColor(BuildContext context) => Theme.of(context).cardTheme.color!;
  static Color getSurfaceColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkSurfaceColor : Colors.grey[50]!;
  static Color getTextPrimary(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
  static Color getTextSecondary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : textSecondary;

  // Global specific styles
  static const TextStyle balanceText = TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.5);
}
