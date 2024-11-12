// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class AppColors {
  // Color Start
  static Color scaffoldGrey = HexColor('#DFDFDF');
  static Color scaffoldBackgroundColor = const Color(0xff141414);
  static Color bgGrey = HexColor("#303030");
  static Color txtGrey = HexColor("#8C8C8C");
  static Color white = HexColor("#ffffff");

  static Color textLight = HexColor('#86878B');
  static Color borderColorButton = HexColor('#E3E3E4');
  static Color greenColor = HexColor('#50E49D');
  static Color primaryColorTop = HexColor('#E92A4F');
  static Color primaryColorBottom = HexColor('#EC5270');
  static Color borderlight = HexColor('#D0D1D3');

  static Color primaryColor = HexColor('#EF274D');
  static const redColor = Color.fromRGBO(233, 75, 62, 1);

  static Color textPrimary = HexColor('#1E232C');
  static Color primaryIconColor = HexColor('#242424');
  static Color purple = HexColor('#5754FC');
  static Color orangeColor = HexColor('#e04a29');
  static Color lightOrangeColor = HexColor('#EFAC99');
  static Color borderColor = HexColor('#D8D8D8');
  static Color lightBorder = HexColor('#BCBCBC');
  static Color iconColor = HexColor('#787878');
  static Color lightText = HexColor('#181D27');
  static Color lightColorBlue = HexColor('#4272EF').withOpacity(0.51);

  static Color getMainBgColor() {
    // return AppColors.colorAccent.withOpacity(0.05);
    return AppColors.bgGrey;
  }

  static const List<Color> defaultColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }

    final hexNum = int.parse(hexColor, radix: 16);

    if (hexNum == 0) {
      return 0xff000000;
    }

    return hexNum;
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class ColorToHex extends Color {
  ///convert material colors to hexcolor
  static int _convertColorTHex(Color color) {
    var hex = '${color.value}';
    return int.parse(
      hex,
    );
  }

  ColorToHex(final Color color) : super(_convertColorTHex(color));

}