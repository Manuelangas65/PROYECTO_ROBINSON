import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/game_record.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();

    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();

    final path = p.join(
      databasesPath,
      'galaxy_gyro.db',
    );

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createGamesTable(db);
        await _createUsersTable(db);
      },

      // ========================================================
      // ACTUALIZAR UNA BASE QUE YA EXISTE
      // ========================================================

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createUsersTable(db);
        }
      },
    );
  }

  // ============================================================
  // TABLA DE PARTIDAS
  // ============================================================

  Future<void> _createGamesTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE games(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        score INTEGER NOT NULL
        CHECK(score >= 0),

        enemies_destroyed INTEGER NOT NULL
        CHECK(enemies_destroyed >= 0),

        duration_seconds INTEGER NOT NULL
        CHECK(duration_seconds >= 0),

        played_at TEXT NOT NULL,

        context_mode TEXT NOT NULL
        CHECK(context_mode IN ('day', 'night'))
      )
    ''');
  }

  // ============================================================
  // TABLA DE USUARIOS
  // ============================================================

  Future<void> _createUsersTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        username TEXT NOT NULL UNIQUE,

        password_hash TEXT NOT NULL,

        salt TEXT NOT NULL,

        created_at TEXT NOT NULL
      )
    ''');
  }

  // ============================================================
  // GUARDAR PARTIDA
  // ============================================================

  Future<int> insertGame(
    GameRecord record,
  ) async {
    if (record.score < 0) {
      throw ArgumentError(
        'La puntuación no puede ser negativa',
      );
    }

    if (record.enemiesDestroyed < 0) {
      throw ArgumentError(
        'Los enemigos eliminados no pueden ser negativos',
      );
    }

    if (record.durationSeconds < 0) {
      throw ArgumentError(
        'La duración no puede ser negativa',
      );
    }

    if (record.contextMode != 'day' && record.contextMode != 'night') {
      throw ArgumentError(
        'Contexto no válido',
      );
    }

    final db = await database;

    return db.insert(
      'games',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ============================================================
  // OBTENER PARTIDAS
  // ============================================================

  Future<List<GameRecord>> getGames({
    int limit = 50,
  }) async {
    final safeLimit = limit.clamp(1, 100);

    final db = await database;

    final rows = await db.query(
      'games',
      orderBy: 'score DESC, played_at DESC',
      limit: safeLimit,
    );

    return rows.map(GameRecord.fromMap).toList();
  }

  // ============================================================
  // BORRAR PARTIDAS
  // ============================================================

  Future<void> clearGames() async {
    final db = await database;

    await db.delete('games');
  }

  // ============================================================
  // BUSCAR USUARIO
  // ============================================================

  Future<Map<String, Object?>?> getUserByUsername(
    String username,
  ) async {
    final db = await database;

    final rows = await db.query(
      'users',

      // Consulta parametrizada.
      where: 'username = ?',

      whereArgs: [
        username.toLowerCase().trim(),
      ],

      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  // ============================================================
  // CREAR USUARIO
  // ============================================================

  Future<int> insertUser({
    required String username,
    required String passwordHash,
    required String salt,
  }) async {
    final db = await database;

    return db.insert(
      'users',
      {
        'username': username.toLowerCase().trim(),
        'password_hash': passwordHash,
        'salt': salt,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}
