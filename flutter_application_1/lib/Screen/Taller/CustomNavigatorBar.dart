import 'package:flutter/material.dart';
import 'package:flutter_application_1/Funciones/generales/get_color.dart';
import 'package:flutter_application_1/widgets/CustomTheme.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Variable para el color dependiendo del tema
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: getColorAlmostBlue(),
            width: 1.0,
          ),
        ),
      ),
      child: NavigationBar(
        backgroundColor: customColors.navigatorBar,
        onDestinationSelected: onTap,
        indicatorColor: getColorAlmostBlue().withOpacity(0.8),
        selectedIndex: currentIndex,
        labelTextStyle:
            WidgetStateProperty.all(TextStyle(color: customColors.label)),
        destinations: <Widget>[
          NavigationDestination(
            icon: Icon(
              Icons.construction_outlined,
              color: customColors.icons,
            ),
            selectedIcon: const Icon(Icons.construction),
            label: 'Taller',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.local_shipping_outlined,
              color: customColors.icons,
            ),
            selectedIcon: const Icon(Icons.local_shipping),
            label: 'Por llegar',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.menu_outlined,
              color: customColors.icons,
            ),
            selectedIcon: const Icon(Icons.menu),
            label: 'Información',
          ),
        ],
      ),
    );
  }
}
