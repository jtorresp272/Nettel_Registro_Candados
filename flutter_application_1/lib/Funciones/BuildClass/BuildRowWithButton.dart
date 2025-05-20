// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';

class RowWithButton extends StatelessWidget {
  final List<String> name;
  final List<VoidCallback> onPressed;
  final List<bool> isPressed;

  const RowWithButton({
    super.key,
    required this.name,
    required this.onPressed,
    required this.isPressed,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(name.length, (index) {
        return InkWell(
          onTap: () {
            onPressed[index]();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: customColors.icons!,
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.transparent),
                        color: isPressed[index]
                            ? getColorAlmostBlue()
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  name[index],
                  style: TextStyle(
                    fontSize: 16.0,
                    color: customColors.label,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
