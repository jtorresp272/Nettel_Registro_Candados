import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Funciones/class_dato_lista.dart';

class CustomListViewBuilder extends StatelessWidget {
  final String where_from;
  final List<Candado> listaFiltrada;

  const CustomListViewBuilder({
    required this.where_from,
    required this.listaFiltrada,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: listaFiltrada.length,
        itemBuilder: (BuildContext context, int index) {
          Color colorContenedor = Colors.grey;
          if(where_from == 'Taller'){
            switch (listaFiltrada[index].lugar) {
            case 'I':
              colorContenedor = Colors.orange;
              break;
            case 'M':
              colorContenedor = Colors.yellow;
              break;
            case 'L':
              colorContenedor = Colors.green;
              break;
            case 'V':
              colorContenedor = Colors.red;
              break;
            default:
              colorContenedor = Colors.grey;
              break;
            }
          }
          
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            decoration: BoxDecoration(
              color: colorContenedor,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              trailing: IconButton(
                onPressed: () {
                  print('item $index');
                },
                icon: const Icon(Icons.expand_more),
              ),
              leading: Image.asset(
                listaFiltrada[index].image,
                fit: BoxFit.fitHeight,
                width: 60.0,
                height: 80.0,
              ),
              title: Text(
                listaFiltrada[index].numero,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Text(
                DateFormat('yyyy-MM-dd').format(listaFiltrada[index].fechaIngreso),
                style: const TextStyle(
                  fontSize: 12.0,
                ),
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
