import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ponto.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pontos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pontos (
        id TEXT PRIMARY KEY,
        dataHora TEXT NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'entrada',
        fotoPath TEXT,
        latitude REAL,
        longitude REAL,
        homeOffice INTEGER DEFAULT 0
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Adiciona coluna homeOffice se não existir
      try {
        await db.execute(
          'ALTER TABLE pontos ADD COLUMN homeOffice INTEGER DEFAULT 0',
        );
      } catch (_) {
        // Coluna já existe, ignorar erro
      }
    }
  }

  Future<void> inserirPonto(Ponto ponto) async {
    final db = await instance.database;
    await db.insert('pontos', ponto.toMap());
  }

  Future<List<Ponto>> listarPontos() async {
    final db = await instance.database;
    final result = await db.query('pontos', orderBy: 'dataHora DESC');
    return result.map((json) => Ponto.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
