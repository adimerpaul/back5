import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  static Database? _database;
  factory DatabaseHelper() => _instance;
  DatabaseHelper.internal();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDb();
    return _database;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'database.db');
    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        user_id TEXT,
        name TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE location (
        id INTEGER PRIMARY KEY,
        fecha TEXT,
        hora TIME,
        latitud TEXT,
        longitud TEXT,
        migrado BOOLEAN
      );
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database? db = await database;
    //prefuntar si existe el id 1
    var res = await db!.query('users', where: 'user_id = ?', whereArgs: ['1']);
    if (res.isNotEmpty) {
      return await db.update('users', row, where: 'user_id = ?', whereArgs: ['1']);
    } else {
      return await db.insert('users', row);
    }
  }
  Future<Map<String, dynamic>?> getUser() async {
    Database? db = await database;
    var res = await db!.query('users', where: 'user_id = ?', whereArgs: ['1']);
    return res.isNotEmpty ? res.first : null;
  }
}
