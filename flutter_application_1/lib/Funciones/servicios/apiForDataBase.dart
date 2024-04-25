import 'package:flutter_application_1/Funciones/servicios/database_helper.dart';
import 'package:flutter_application_1/Funciones/database/data_model.dart';
import 'package:flutter_application_1/Funciones/servicios/updateIcon.dart';

/* Funcion para borrar los datos guardados en memoria */
Future<void> deleteData({required int id, required String title}) async {
  Note modelDelete = Note(
    id: id,
    title: title,
    description: '',
  );
  await DatabaseHelper.deleteNote(modelDelete, modelDelete.id);
}

/* Check si existe informacion por enviar en correo  */
Future<void> hasEmail(context, String title) async {
  final List<Note>? notes = await DatabaseHelper.getAllNote(2);
  if (notes != null && notes.isNotEmpty) {
    try {
      notes.firstWhere((note) => note.title == title);
      updateIconAppBar().triggerNotification(context, true);
    } catch (_) {}
  } else {}
}

/* Obtiene informacion de la base de datos */
Future<String> getDataCandados(String title) async {
  String description = '';
  final List<Note>? notes = await DatabaseHelper.getAllNote(2);
  if (notes != null && notes.isNotEmpty) {
    try {
      final Note note = notes.firstWhere((note) => note.title == title);
      description = note.description;
      description = description.substring(1, description.length - 1);
    } on StateError catch (_) {
      description =
          ''; // Si notes es nulo o está vacío, establece la descripción como '0'
    }
  } else {
    description =
        ''; // Si notes es nulo o está vacío, establece la descripción como '0'
  }
  return description;
}
