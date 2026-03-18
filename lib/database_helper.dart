import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/step_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'steps_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE step_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_time TEXT,
        steps INTEGER,
        user_id TEXT
      )
    ''');
  }

  Future<int> insertRecord(StepRecord record) async {
    final db = await database;
    return await db.insert('step_records', record.toMap());
  }

  Future<List<StepRecord>> getRecords(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'step_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date_time DESC',
    );
    
    return maps.map((map) => StepRecord.fromMap(map)).toList();
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete(
      'step_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearAllRecords(String userId) async {
    final db = await database;
    return await db.delete(
      'step_records',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}