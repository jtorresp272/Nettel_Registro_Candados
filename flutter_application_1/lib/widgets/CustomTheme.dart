import 'package:flutter/material.dart';

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
  final Color? customOne;
  final Color? customTwo;
  final Color? customThree;

  const CustomColors({this.customOne, this.customTwo, this.customThree});

  @override
  ThemeExtension<CustomColors> copyWith({
    Color? customOne,
    Color? customTwo,
    Color? customThree,
  }) {
    return CustomColors(
      customOne: customOne ?? this.customOne,
      customTwo: customTwo ?? this.customTwo,
      customThree: customTwo ?? this.customThree,
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
      customOne: Color.lerp(customOne, other.customOne, t),
      customTwo: Color.lerp(customTwo, other.customTwo, t),
      customThree: Color.lerp(customThree, other.customThree, t),
    );
  }

  static const dark = CustomColors(
    customOne: Colors.white,
    customTwo: Color.fromARGB(255, 68, 91, 164),
    customThree: Color.fromARGB(141, 68, 90, 164),
  );
  static const light = CustomColors(
    customOne: Color.fromARGB(255, 68, 91, 164),
    customTwo: Colors.white,
    customThree: Colors.white54,
  );
}
