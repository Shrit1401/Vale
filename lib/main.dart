import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vale/pages/home/home_page.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.dark),
      home: HomePage(),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final ThemeData baseTheme = ThemeData(brightness: brightness);

  return baseTheme.copyWith(
    textTheme: GoogleFonts.manropeTextTheme(baseTheme.textTheme)
        .apply(displayColor: null, bodyColor: null)
        .copyWith(
          bodyMedium: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: baseTheme.textTheme.bodyMedium?.fontSize,
            letterSpacing: baseTheme.textTheme.bodyMedium?.letterSpacing,
            height: baseTheme.textTheme.bodyMedium?.height,
            color: baseTheme.textTheme.bodyMedium?.color,
          ),
        ),
  );
}
