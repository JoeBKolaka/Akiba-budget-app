import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/transaction_model.dart';

class TransactionLocalRepository {
  String tableName = "transactions";
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "transaction.db");
    
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            category_id TEXT NOT NULL,
            account_id TEXT NOT NULL,
            transaction_name TEXT NOT NULL,
            transaction_type TEXT NOT NULL,
            transaction_amount REAL NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertTransaction(
    TransactionModel transactionModel, {
    required String user_id,
    required String category_id,
    required String account_id,
  }) async {
    final db = await database;

    await db.insert(
      tableName,
      transactionModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final results = await db.query(tableName);

    if (results.isNotEmpty) {
      List<TransactionModel> transactions = [];
      for (final elem in results) {
        transactions.add(TransactionModel.fromMap(elem));
      }
      return transactions;
    }
    return [];
  }
}