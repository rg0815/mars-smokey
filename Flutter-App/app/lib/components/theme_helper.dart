import 'package:flutter/material.dart';

class ThemeHelper {
  static ThemeData theme = ThemeData(
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff981212),
      titleTextStyle: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 20,
        letterSpacing: 0.15,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      toolbarTextStyle: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0.25,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
    ),
    applyElevationOverlayColor: false,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedLabelStyle: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0.25,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      unselectedLabelStyle: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0.25,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
    ),
    brightness: Brightness.light,
    buttonTheme: const ButtonThemeData(
      alignedDropdown: false,
      colorScheme: ColorScheme(
        background: Color(0xffe05e5e),
        brightness: Brightness.light,
        error: Color(0xffb00020),
        errorContainer: Color(0xffb00020),
        inversePrimary: Color(0xffffffff),
        inverseSurface: Color(0xff000000),
        onBackground: Color(0xff000000),
        onError: Color(0xffffffff),
        onErrorContainer: Color(0xffffffff),
        onInverseSurface: Color(0xffffffff),
        onPrimary: Color(0xff000000),
        onPrimaryContainer: Color(0xffffffff),
        onSecondary: Color(0xff000000),
        onSecondaryContainer: Color(0xff000000),
        onSurface: Color(0xff000000),
        onSurfaceVariant: Color(0xff000000),
        onTertiary: Color(0xff000000),
        onTertiaryContainer: Color(0xff000000),
        outline: Color(0xff000000),
        primary: Color(0xffd31919),
        primaryContainer: Color(0xff6200ee),
        secondary: Color(0xffff6400),
        secondaryContainer: Color(0xff03dac6),
        shadow: Color(0xff000000),
        surface: Color(0xffffffff),
        surfaceTint: Color(0xff6200ee),
        surfaceVariant: Color(0xffffffff),
        tertiary: Color(0xff03dac6),
        tertiaryContainer: Color(0xff03dac6),
      ),
      height: 36,
      layoutBehavior: ButtonBarLayoutBehavior.padded,
      minWidth: 88,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.elliptical(2, 2),
          topRight: Radius.elliptical(2, 2),
          bottomLeft: Radius.elliptical(2, 2),
          bottomRight: Radius.elliptical(2, 2),
        ),
        side: BorderSide(
          color: Color(0xff000000),
          width: 0,
          style: BorderStyle.none,
          strokeAlign: -1,
        ),
      ),
      textTheme: ButtonTextTheme.normal,
    ),
    canvasColor: const Color(0xff303030),
    cardColor: const Color(0xff424242),
    colorScheme: const ColorScheme(
      background: Color(0xffe05e5e),
      brightness: Brightness.light,
      error: Color(0xffb00020),
      errorContainer: Color(0xffb00020),
      inversePrimary: Color(0xffffffff),
      inverseSurface: Color(0xff000000),
      onBackground: Color(0xff000000),
      onError: Color(0xffffffff),
      onErrorContainer: Color(0xffffffff),
      onInverseSurface: Color(0xffffffff),
      onPrimary: Color(0xff000000),
      onPrimaryContainer: Color(0xffffffff),
      onSecondary: Color(0xff000000),
      onSecondaryContainer: Color(0xff000000),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      onTertiary: Color(0xff000000),
      onTertiaryContainer: Color(0xff000000),
      outline: Color(0xff000000),
      primary: Color(0xffd31919),
      primaryContainer: Color(0xff6200ee),
      secondary: Color(0xffff6400),
      secondaryContainer: Color(0xff03dac6),
      shadow: Color(0xff000000),
      surface: Color(0xffffffff),
      surfaceTint: Color(0xff6200ee),
      surfaceVariant: Color(0xffffffff),
      tertiary: Color(0xff03dac6),
      tertiaryContainer: Color(0xff03dac6),
    ),
    dialogBackgroundColor: const Color(0xff424242),
    disabledColor: const Color(0x62ffffff),
    dividerColor: const Color(0x1fffffff),
    focusColor: const Color(0x1fffffff),
    highlightColor: const Color(0x40cccccc),
    hintColor: const Color(0x99ffffff),
    hoverColor: const Color(0x0affffff),
    iconTheme: const IconThemeData(
      color: Color(0xdd000000),
    ),
    indicatorColor: const Color(0xffd31919),
    inputDecorationTheme: const InputDecorationTheme(
      alignLabelWithHint: false,
      filled: false,
      floatingLabelAlignment: FloatingLabelAlignment.start,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      isCollapsed: false,
      isDense: false,
    ),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    platform: TargetPlatform.windows,
    primaryColor: const Color(0xffd31919),
    primaryColorDark: const Color(0xff981212),
    primaryColorLight: const Color(0xffe57575),
    primaryIconTheme: const IconThemeData(
      color: Color(0xffffffff),
    ),
    primaryTextTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Color(0xffffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      bodyMedium: TextStyle(
        color: Color(0xffffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      bodySmall: TextStyle(
        color: Color(0xb3ffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      displayLarge: TextStyle(
        color: Color(0xb3ffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      displayMedium: TextStyle(
        color: Color(0xb3ffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      displaySmall: TextStyle(
        color: Color(0xb3ffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      headlineLarge: TextStyle(
        color: Color(0xb3ffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      headlineMedium: TextStyle(
        color: Color(0xb3ffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      headlineSmall: TextStyle(
        color: Color(0xffffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      labelLarge: TextStyle(
        color: Color(0xffffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      labelMedium: TextStyle(
        color: Color(0xffffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      labelSmall: TextStyle(
        color: Color(0xffffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      titleLarge: TextStyle(
        color: Color(0xffffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      titleMedium: TextStyle(
        color: Color(0xffffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
      titleSmall: TextStyle(
        color: Color(0xffffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Segoe UI',
        inherit: true,
      ),
    ),
    scaffoldBackgroundColor: const Color(0xff303030),
    secondaryHeaderColor: const Color(0xffe78181),
    shadowColor: const Color(0xff000000),
    splashColor: const Color(0x40cccccc),
    splashFactory: InkSplash.splashFactory,
    tabBarTheme: const TabBarTheme(
      labelStyle: TextStyle(
        color: Color(0xffffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        inherit: true,
        letterSpacing: 0.5,
        textBaseline: TextBaseline.alphabetic,
      ),
      unselectedLabelStyle: TextStyle(
        color: Color(0xffffffff),
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        inherit: true,
        letterSpacing: 0.5,
        textBaseline: TextBaseline.alphabetic,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: 0.5,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0.25,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodySmall: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 12,
        letterSpacing: 0.4,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      displayLarge: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w300,
        fontSize: 96,
        letterSpacing: -1.5,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      displayMedium: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w300,
        fontSize: 60,
        letterSpacing: -0.5,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      displaySmall: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w300,
        fontSize: 48,
        letterSpacing: 0,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      headlineLarge: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        inherit: true,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 34,
        letterSpacing: 0.25,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 24,
        letterSpacing: 0,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 1.25,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      labelMedium: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        inherit: true,
      ),
      labelSmall: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 10,
        letterSpacing: 1.5,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 20,
        letterSpacing: 0.15,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: 0.15,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
      titleSmall: TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 0.1,
        inherit: true,
        textBaseline: TextBaseline.alphabetic,
      ),
    ),
    typography: Typography(
      black: const TextTheme(
        bodyLarge: TextStyle(
          color: Color(0xdd000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        bodyMedium: TextStyle(
          color: Color(0xdd000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        bodySmall: TextStyle(
          color: Color(0x8a000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        displayLarge: TextStyle(
          color: Color(0x8a000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        displayMedium: TextStyle(
          color: Color(0x8a000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        displaySmall: TextStyle(
          color: Color(0x8a000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        headlineLarge: TextStyle(
          color: Color(0x8a000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        headlineMedium: TextStyle(
          color: Color(0x8a000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        headlineSmall: TextStyle(
          color: Color(0xdd000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        labelLarge: TextStyle(
          color: Color(0xdd000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        labelMedium: TextStyle(
          color: Color(0xff000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        labelSmall: TextStyle(
          color: Color(0xff000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        titleLarge: TextStyle(
          color: Color(0xdd000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        titleMedium: TextStyle(
          color: Color(0xdd000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        titleSmall: TextStyle(
          color: Color(0xff000000),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
      ),
      dense: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        displayLarge: TextStyle(
          fontSize: 112,
          fontWeight: FontWeight.w100,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        displayMedium: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        displaySmall: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        headlineLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        headlineMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w500,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
        titleSmall: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          inherit: false,
          textBaseline: TextBaseline.ideographic,
        ),
      ),
      englishLike: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        displayLarge: TextStyle(
          fontSize: 112,
          fontWeight: FontWeight.w100,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        displayMedium: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        displaySmall: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        headlineLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        headlineMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          inherit: false,
          letterSpacing: 1.5,
          textBaseline: TextBaseline.alphabetic,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          inherit: false,
          letterSpacing: 0.1,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
      tall: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        displayLarge: TextStyle(
          fontSize: 112,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        displayMedium: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        displaySmall: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        headlineLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        headlineMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        titleSmall: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
      white: const TextTheme(
        bodyLarge: TextStyle(
          color: Color(0xffffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        bodyMedium: TextStyle(
          color: Color(0xffffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        bodySmall: TextStyle(
          color: Color(0xb3ffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        displayLarge: TextStyle(
          color: Color(0xb3ffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        displayMedium: TextStyle(
          color: Color(0xb3ffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        displaySmall: TextStyle(
          color: Color(0xb3ffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        headlineLarge: TextStyle(
          color: Color(0xb3ffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        headlineMedium: TextStyle(
          color: Color(0xb3ffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        headlineSmall: TextStyle(
          color: Color(0xffffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        labelLarge: TextStyle(
          color: Color(0xffffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        labelMedium: TextStyle(
          color: Color(0xffffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        labelSmall: TextStyle(
          color: Color(0xffffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        titleLarge: TextStyle(
          color: Color(0xffffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        titleMedium: TextStyle(
          color: Color(0xffffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
        titleSmall: TextStyle(
          color: Color(0xffffffff),
          decoration: TextDecoration.none,
          fontFamily: 'Segoe UI',
          inherit: true,
        ),
      ),
    ),
    unselectedWidgetColor: const Color(0xb3ffffff),
    useMaterial3: false,
    visualDensity: VisualDensity.compact,
  );

  static TextStyle listTileTitle() {
    return const TextStyle(
      color: Colors.white,
      decoration: TextDecoration.none,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w500,
      fontSize: 20,
      letterSpacing: 0.15,
      inherit: true,
      textBaseline: TextBaseline.alphabetic,
    );
  }

  static TextStyle listTileSubtitle() {
    return const TextStyle(
      color: Colors.white38,
      decoration: TextDecoration.none,
      fontFamily: 'Roboto',
      // fontWeight: FontWeight.w900,
      // fontSize: 20,
      letterSpacing: 0.15,
      inherit: true,
      textBaseline: TextBaseline.alphabetic,
    );
  }

  InputDecoration textInputDecoration(String? labelText, String? hintText) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100.0),
          borderSide: const BorderSide(color: Colors.grey)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100.0),
          borderSide: BorderSide(color: Colors.grey.shade400)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0)),
    );
  }

  BoxDecoration inputBoxDecorationShadow() {
    return BoxDecoration(boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 5),
      )
    ]);
  }

  BoxDecoration buttonBoxDecoration(BuildContext context) {
    Color c1 = ThemeHelper.theme.primaryColor;
    Color c2 = ThemeHelper.theme.colorScheme.secondary;

    return BoxDecoration(
      boxShadow: const [
        BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 1.0],
        colors: [
          c1,
          c2,
        ],
      ),
      color: Colors.red.shade300,
      borderRadius: BorderRadius.circular(30),
    );
  }

  ButtonStyle buttonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      minimumSize: MaterialStateProperty.all(const Size(50, 50)),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
    );
  }

  AlertDialog alertDialog(String title, String content, BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black38)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
