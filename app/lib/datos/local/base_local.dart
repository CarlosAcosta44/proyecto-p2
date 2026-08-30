import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BaseLocal {
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB('rondas.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE punto_control (
        id INTEGER PRIMARY KEY,
        codigo TEXT UNIQUE NOT NULL,
        nombre TEXT NOT NULL,
        latitud REAL NOT NULL,
        longitud REAL NOT NULL,
        radio_m INTEGER NOT NULL DEFAULT 40,
        orden INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE marcacion_pendiente (
        id TEXT PRIMARY KEY,
        codigo TEXT NOT NULL,
        latitud REAL NOT NULL,
        longitud REAL NOT NULL,
        precision_m REAL NOT NULL,
        escaneada_en TEXT NOT NULL
      )
    ''');
  }

  Future<void> guardarPuntos(List<Map<String, dynamic>> puntos) async {
    final dbClient = await db;
    await dbClient.transaction((txn) async {
      await txn.delete('punto_control');
      for (final p in puntos) {
        await txn.insert('punto_control', p);
      }
    });
  }

  Future<List<Map<String, dynamic>>> obtenerPuntos() async {
    final dbClient = await db;
    return await dbClient.query('punto_control', orderBy: 'orden ASC');
  }

  Future<void> encolarMarcacion(Map<String, dynamic> marcacion) async {
    final dbClient = await db;
    await dbClient.insert('marcacion_pendiente', marcacion);
  }

  Future<List<Map<String, dynamic>>> obtenerMarcacionesPendientes() async {
    final dbClient = await db;
    return await dbClient.query('marcacion_pendiente');
  }

  Future<void> eliminarMarcacionesPendientes(List<String> ids) async {
    final dbClient = await db;
    await dbClient.transaction((txn) async {
      for (final id in ids) {
        await txn.delete('marcacion_pendiente', where: 'id = ?', whereArgs: [id]);
      }
    });
  }
}
