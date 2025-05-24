import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';
import 'package:flutter_application_1/Screen/enums.dart';

class CustomFloatingActionButtons extends StatelessWidget {
  final bool terminoObData;
  final bool isExpanded;
  final void Function() toggleExpand;
  final void Function(FloatingActions) onFloatingAction;

  const CustomFloatingActionButtons({
    super.key,
    required this.terminoObData,
    required this.isExpanded,
    required this.toggleExpand,
    required this.onFloatingAction,
  });

  @override
  Widget build(BuildContext context) {
    if (!terminoObData) return const SizedBox.shrink();
// Variable para el color dependiendo del tema
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isExpanded) ...[
          floatingDesing(
            icon: Icons.qr_code_scanner,
            label: 'QrScanner',
            contextForColor: context,
            onPressed: () => onFloatingAction(FloatingActions.qr),
          ),
          const SizedBox(height: 5),
          floatingDesing(
            icon: Icons.drive_file_rename_outline,
            label: 'Escribir número',
            contextForColor: context,
            onPressed: () => onFloatingAction(FloatingActions.write),
          ),
          const SizedBox(height: 5),
          floatingDesing(
            icon: Icons.receipt_long_outlined,
            label: 'Historial',
            contextForColor: context,
            onPressed: () => onFloatingAction(FloatingActions.historial),
          ),
          const SizedBox(height: 5),
        ],
        FloatingActionButton(
          heroTag: 'main',
          tooltip: isExpanded ? 'Minimizar' : 'Maximizar',
          onPressed: toggleExpand,
          backgroundColor: customColors.background,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: getColorAlmostBlue()),
          ),
          child: Icon(
            isExpanded
                ? Icons.keyboard_arrow_down_outlined
                : Icons.keyboard_arrow_up_outlined,
            color: customColors.icons,
          ),
        ),
      ],
    );
  }
}

FloatingActionButton floatingDesing({
  required IconData icon,
  required String label,
  required BuildContext contextForColor,
  required VoidCallback onPressed,
}) {
  // Variable para el color dependiendo del tema
  final customColors = Theme.of(contextForColor).extension<CustomColors>()!;

  return FloatingActionButton(
    heroTag: label,
    tooltip: label,
    onPressed: onPressed,
    mini: true, // Tamaño reducido
    backgroundColor: customColors.background,
    elevation: 0.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: getColorAlmostBlue()),
    ),
    child: Icon(
      icon,
      color: customColors.icons,
      size: 20, // Tamaño del icono
    ),
  );
}
