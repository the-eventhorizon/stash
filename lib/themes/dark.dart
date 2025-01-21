import 'package:flutter/material.dart';

const Color darkPrimaryColor = Color(0xff7986cb);
const Color darkSecondaryColor = Color(0xff4c5acb);
const Color darkBackgroundColor = Color(0xff121212);
const Color darkBackgroundVariantColor = Color(0xff333333);
const Color darkScaffoldBackgroundColor = Color(0xff1e1e1e);
const Color darkCardColor = Color(0xff1e1e1e);
const Color darkErrorColor = Color(0xffcf6679);
const Color darkAccentColor = Color(0xff03dac6);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: darkPrimaryColor,
  scaffoldBackgroundColor: darkScaffoldBackgroundColor,
  cardColor: darkCardColor,
  appBarTheme: AppBarTheme(
    backgroundColor: darkPrimaryColor,
    foregroundColor: Colors.white,
  ),
  colorScheme: ColorScheme.dark(
    primary: darkPrimaryColor,
    secondary: darkSecondaryColor,
    tertiary: darkAccentColor,
    surface: darkBackgroundColor,
    surfaceContainerHighest: darkBackgroundVariantColor,
    error: darkErrorColor,
  ),
);