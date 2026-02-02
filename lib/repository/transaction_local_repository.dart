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
    final results = await db.query(
      tableName,
      orderBy: 'created_at DESC',
    );

    if (results.isNotEmpty) {
      List<TransactionModel> transactions = [];
      for (final elem in results) {
        transactions.add(TransactionModel.fromMap(elem));
      }
      return transactions;
    }
    return [];
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    final results = await db.query(
      tableName,
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: 'created_at ASC',
    );

    if (results.isNotEmpty) {
      List<TransactionModel> transactions = [];
      for (final elem in results) {
        transactions.add(TransactionModel.fromMap(elem));
      }
      return transactions;
    }
    return [];
  }

  Future<List<TransactionModel>> getTransactionsForDay(DateTime day) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getTransactionsByDateRange(startOfDay, endOfDay);
  }

  Future<List<TransactionModel>> getTransactionsForWeek(
    DateTime weekStart,
  ) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return getTransactionsByDateRange(weekStart, weekEnd);
  }

  Future<List<TransactionModel>> getTransactionsForMonth(
    DateTime monthStart,
  ) async {
    final monthEnd = DateTime(
      monthStart.year,
      monthStart.month + 1,
      1,
    );
    return getTransactionsByDateRange(monthStart, monthEnd);
  }

  Future<List<TransactionModel>> getTransactionsForYear(
    DateTime yearStart,
  ) async {
    final yearEnd = DateTime(yearStart.year + 1, 1, 1);
    return getTransactionsByDateRange(yearStart, yearEnd);
  }

  Future<List<TransactionModel>> getTransactionsByCategory(
    String category_id,
  ) async {
    final db = await database;
    final results = await db.query(
      tableName,
      where: 'category_id = ?',
      whereArgs: [category_id],
      orderBy: 'created_at DESC',
    );

    if (results.isNotEmpty) {
      List<TransactionModel> transactions = [];
      for (final elem in results) {
        transactions.add(TransactionModel.fromMap(elem));
      }
      return transactions;
    }
    return [];
  }

  Future<List<TransactionModel>> getTransactionsByCategoryAndDateRange(
    String categoryId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    final results = await db.query(
      tableName,
      where: 'category_id = ? AND created_at BETWEEN ? AND ?',
      whereArgs: [categoryId, startTimestamp, endTimestamp],
      orderBy: 'created_at ASC',
    );

    if (results.isNotEmpty) {
      List<TransactionModel> transactions = [];
      for (final elem in results) {
        transactions.add(TransactionModel.fromMap(elem));
      }
      return transactions;
    }
    return [];
  }

  Future<double> getTodayExpensesByCategory(String categoryId) async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;
    final endOfDay = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
      999,
    ).millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''
    SELECT SUM(transaction_amount) as total
    FROM $tableName 
    WHERE category_id = ? 
    AND transaction_type = 'expense'
    AND created_at BETWEEN ? AND ?
  ''',
      [categoryId, startOfDay, endOfDay],
    );

    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getThisWeekExpensesByCategory(String categoryId) async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startTimestamp = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    ).millisecondsSinceEpoch;
    final endTimestamp = now.millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''
    SELECT SUM(transaction_amount) as total
    FROM $tableName 
    WHERE category_id = ? 
    AND transaction_type = 'expense'
    AND created_at BETWEEN ? AND ?
  ''',
      [categoryId, startTimestamp, endTimestamp],
    );

    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getThisMonthExpensesByCategory(String categoryId) async {
    final db = await database;
    final now = DateTime.now();
    final startOfMonth = DateTime(
      now.year,
      now.month,
      1,
    ).millisecondsSinceEpoch;
    final endOfMonth = now.millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''
    SELECT SUM(transaction_amount) as total
    FROM $tableName 
    WHERE category_id = ? 
    AND transaction_type = 'expense'
    AND created_at BETWEEN ? AND ?
  ''',
      [categoryId, startOfMonth, endOfMonth],
    );

    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getThisYearExpensesByCategory(String categoryId) async {
    final db = await database;
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1).millisecondsSinceEpoch;
    final endOfYear = now.millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''
    SELECT SUM(transaction_amount) as total
    FROM $tableName 
    WHERE category_id = ? 
    AND transaction_type = 'expense'
    AND created_at BETWEEN ? AND ?
  ''',
      [categoryId, startOfYear, endOfYear],
    );

    return result.first['total'] as double? ?? 0.0;
  }

  // Get total income/expense for a category in date range
  Future<Map<String, double>> getCategoryTotalsByDateRange(
    String categoryId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    final incomeResult = await db.rawQuery('''
      SELECT SUM(transaction_amount) as total
      FROM $tableName 
      WHERE category_id = ?
      AND transaction_type = 'income'
      AND created_at BETWEEN ? AND ?
    ''', [categoryId, startTimestamp, endTimestamp]);

    final expenseResult = await db.rawQuery('''
      SELECT SUM(transaction_amount) as total
      FROM $tableName 
      WHERE category_id = ?
      AND transaction_type = 'expense'
      AND created_at BETWEEN ? AND ?
    ''', [categoryId, startTimestamp, endTimestamp]);

    final income = incomeResult.first['total'] as double? ?? 0.0;
    final expense = expenseResult.first['total'] as double? ?? 0.0;

    return {
      'income': income,
      'expense': expense,
      'net': income - expense,
    };
  }

  // Get transaction by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    final db = await database;
    final results = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return TransactionModel.fromMap(results.first);
    }
    return null;
  }
}