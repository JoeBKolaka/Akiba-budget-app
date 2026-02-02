import 'package:akiba/models/budget_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BudgetLocalRepository {
  String tableName = "budgets";
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "budgets.db");
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            category_id TEXT NOT NULL,
            budget_amount DOUBLE NOT NULL,
            repetition TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id)
            FOREIGN KEY (category_id) REFERENCES categories(id)
          )
        ''');
      },
    );
  }

  Future<void> insertBudget(
    BudgetModel budgetModel, {
    required String user_id,
    required String category_id
  }) async {
    final db = await database;

    // Check if budget already exists for this category
    final existing = await db.query(
      tableName,
      where: 'category_id = ?',
      whereArgs: [category_id],
    );
    
    if (existing.isNotEmpty) {
      throw Exception('Budget already exists for this category');
    }

    await db.insert(
      tableName,
      budgetModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BudgetModel>> getBudgets() async {
    final db = await database;
    final results = await db.query(tableName);

    if (results.isNotEmpty) {
      List<BudgetModel> budgets = [];
      for (final elem in results) {
        budgets.add(BudgetModel.fromMap(elem));
      }
      return budgets;
    }
    return [];
  }
}