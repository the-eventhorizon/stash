import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static final DBProvider instance = DBProvider.internal();
  static Database? database;

  factory DBProvider() => instance;

  DBProvider.internal();

  Future<Database> get db async {
    if (database != null) return database!;
    database = await initDB();
    return database!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'vana_sky_stash.db'),
      version: 1,
      onCreate: onCreate,
    );
  }

  Future<void> onCreate(Database db, int version) async {
    // Create households table
    await db.execute('''
      CREATE TABLE households (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        owner_id INTEGER,
        is_private INTEGER DEFAULT 0,
      )
    ''');

    // Create shopping lists table
    await db.execute('''
      CREATE TABLE shopping_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        household_id INTEGER NOT NULL,
        FOREIGN KEY (household_id) REFERENCES households (id)
      )
    ''');

    // Create items table
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        checked INTEGER DEFAULT 0,
        shopping_list_id INTEGER NOT NULL,
        FOREIGN KEY (shopping_list_id) REFERENCES shopping_lists (id)
      )
    ''');
  }
}
