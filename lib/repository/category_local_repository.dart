import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/category_model.dart';

class CategoryLocalRepository {
  String tableName = "categories";
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "categories.db");
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            emoji TEXT NOT NULL,
            hex_color TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id)
          )
        ''');
      },
    );
  }

  Future<void> insertCategory(
    CategoryModel categoryModel, {
    required String user_id,
  }) async {
    final db = await database;

    await db.insert(
      tableName,
      categoryModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    final results = await db.query(tableName);

    if (results.isNotEmpty) {
      List<CategoryModel> categories = [];
      for (final elem in results) {
        categories.add(CategoryModel.fromMap(elem));
      }
      return categories;
    }
    return [];
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final db = await database;
    final results = await db.query(tableName, where: 'id = ?', whereArgs: [id]);

    if (results.isNotEmpty) {
      return CategoryModel.fromMap(results.first);
    }
    return null;
  }

  Future<void> updateCategory({
    required String name,
    required String emoji,
    required String hex_color,
    required String user_id,
  }) async {
    final db = await database;
    await db.update(
      tableName,
      {
        'name': name,
        'emoji': emoji,
        'hex_color': hex_color,
        'user_id': user_id,
      },
      where: 'name = ? AND user_id = ?',
      whereArgs: [name, user_id],
    );
  }
}
