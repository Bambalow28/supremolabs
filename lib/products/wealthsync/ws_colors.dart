import 'package:flutter/material.dart';

class AppColors {
  static Color backgroundColor = HexColor('1D1D1D');
  static Color cardColor = HexColor('35374B');
  static Color cardContentColor = HexColor('414141');
  static Color greenColor = HexColor('005B41');
  static Color buttonColor = HexColor('363062');
  static Color greyColor = HexColor('8D8FA1');
  static Color toolColor = HexColor('465C88');
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add full opacity if not provided
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
