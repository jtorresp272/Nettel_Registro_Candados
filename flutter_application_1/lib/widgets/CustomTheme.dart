import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';

Color titleLigthColor = getColorAlmostBlue();

class AppTheme {
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      CustomColors.light,
    ],
  );
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      CustomColors.dark,
    ],
  );
}

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color? icons;
  final Color? appBarTitle;
  final Color? background;
  final Color? navigatorBar;
  final Color? label;
  const CustomColors(
      {this.icons,
      this.appBarTitle,
      this.background,
      this.label,
      this.navigatorBar});

  @override
  ThemeExtension<CustomColors> copyWith({
    Color? appBarIcon,
    Color? appBarTitle,
    Color? background,
    Color? label,
    Color? navigatorBar,
  }) {
    return CustomColors(
      icons: appBarIcon ?? this.icons,
      appBarTitle: appBarTitle ?? this.appBarTitle,
      background: background ?? this.background,
      label: label ?? this.label,
      navigatorBar: navigatorBar ?? this.navigatorBar,
    );
  }

  @override
  CustomColors lerp(
    ThemeExtension<CustomColors>? other,
    double t,
  ) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      icons: Color.lerp(icons, other.icons, t),
      appBarTitle: Color.lerp(appBarTitle, other.appBarTitle, t),
      background: Color.lerp(background, other.background, t),
      label: Color.lerp(label, other.label, t),
      navigatorBar: Color.lerp(navigatorBar, other.navigatorBar, t),
    );
  }

  // Por el momento siempre sera ligth
  /*
  static final dark = CustomColors(
    background: Colors.black,
    icons: Colors.white,
    appBarTitle: titleLigthColor,
    label: Colors.white,
    navigatorBar: Colors.black,
  );
  */
  static final dark = CustomColors(
    background: Colors.white,
    icons: Colors.black,
    appBarTitle: titleLigthColor,
    label: Colors.black,
    navigatorBar: Colors.white,
  );
  static final light = CustomColors(
    background: Colors.white,
    icons: Colors.black,
    appBarTitle: titleLigthColor,
    label: Colors.black,
    navigatorBar: Colors.white,
  );
}
