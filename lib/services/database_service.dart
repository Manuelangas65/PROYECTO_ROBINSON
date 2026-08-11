import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/game_record.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'galaxy_gyro.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE games(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            score INTEGER NOT NULL CHECK(score >= 0),
            enemies_destroyed INTEGER NOT NULL CHECK(enemies_destroyed >= 0),
            duration_seconds INTEGER NOT NULL CHECK(duration_seconds >= 0),
            played_at TEXT NOT NULL,
            context_mode TEXT NOT NULL CHECK(context_mode IN ('day', 'night'))
          )
        ''');
      },
    );
  }

  Future<int> insertGame(GameRecord record) async {
    final db = await database;
    return db.insert('games', record.toMap());
  }

  Future<List<GameRecord>> getGames({int limit = 50}) async {
    final db = await database;
    final rows = await db.query(
      'games',
      orderBy: 'score DESC, played_at DESC',
      limit: limit,
    );

    return rows.map(GameRecord.fromMap).toList();
  }

  Future<void> clearGames() async {
    final db = await database;
    await db.delete('games');
  }
}
