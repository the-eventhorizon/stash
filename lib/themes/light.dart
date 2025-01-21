import 'package:flutter/material.dart';

const Color primaryColor = Color(0xff5c6bc0);
const Color secondaryColor = Color(0xff8e99f3);
const Color backgroundColor = Color(0xffffffff);
const Color backgroundVariantColor = Color(0xfff5f5f5);
const Color scaffoldBackgroundColor = Color(0xfff6f6f6);
const Color cardColor = Color(0xffffffff);
const Color errorColor = Color(0xffd32f2f);
const Color accentColor = Color(0xff80deea);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: scaffoldBackgroundColor,
  cardColor: cardColor,
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor,
    surfaceTintColor: Colors.transparent,
    foregroundColor: Colors.white,
  ),
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
    tertiary: accentColor,
    surface: backgroundColor,
    surfaceContainerHighest: backgroundVariantColor,
    error: errorColor,
  ),
);
