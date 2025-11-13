import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFCA4492),
        secondary: const Color(0xFFF7BEC4),
        surface: Colors.white,
        error: Colors.red,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((
          Set<MaterialState> states,
        ) {
          return IconThemeData(
            color: states.contains(MaterialState.selected)
                ? Color(0xFFCA4492)
                : Colors.grey,
          );
        }),
        labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((
          Set<MaterialState> states,
        ) {
          return TextStyle(
            color: states.contains(MaterialState.selected)
                ? Color(0xFFCA4492)
                : Colors.grey,
            fontWeight: states.contains(MaterialState.selected)
                ? FontWeight.w600
                : FontWeight.normal,
          );
        }),
      ),
    );
  }
}
