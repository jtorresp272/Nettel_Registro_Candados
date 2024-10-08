import 'package:flutter_application_1/Funciones/database/data_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbName = "Note.db";

  static Future<Database> _getDB(int? v) async {
    return openDatabase(join(await getDatabasesPath(), _dbName),
        onCreate: (db, version) async => await db.execute(
            "CREATE TABLE Note(id INTEGER PRIMARY KEY, title TEXT NOT NULL, description INTEGER SECUNDARY KEY);"),
        version: v ?? _version);
  }

/* Funcion para guardar informacion en la base de datos */
  static Future<int> addNote(Note note, int? v) async {
    final db = await _getDB(v ?? _version);
    return await db.insert("Note", note.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

/* Funcion para actualizar la base de datos */
  static Future<int> updateNote(Note note, int? v) async {
    final db = await _getDB(v ?? _version);
    return await db.update("Note", note.toJson(),
        where: 'id = ?',
        whereArgs: [note.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

/* Funcion para borrar informacion de la base de datos */
  static Future<int> deleteNote(Note note, int? v) async {
    final db = await _getDB(v ?? _version);
    return await db.delete(
      "Note",
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

/* Obtener toda la informacion de la base de datos */
  static Future<List<Note>?> getAllNote(int? v) async {
    final db = await _getDB(v ?? _version);
    final List<Map<String, dynamic>> maps = await db.query("Note");
    if (maps.isEmpty) {
      return null;
    }

    return List.generate(maps.length, (index) => Note.fromJson(maps[index]));
  }
}
