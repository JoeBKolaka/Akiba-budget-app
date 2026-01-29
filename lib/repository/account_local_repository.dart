import 'package:akiba/models/account_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AccountLocalRepository {
  String tableName = "accounts";
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "finance.db"); // Use consistent database name
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            account_name TEXT NOT NULL,
            ammount DOUBLE NOT NULL,
            account_type TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id)
          )
        ''');
      },
    );
  }

  Future<void> insertAccount(
    AccountModel accountModel, {
    required String user_id,
    
  }) async {
    final db = await database;
    await db.insert(
      tableName,
      accountModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AccountModel>> getAccounts() async {
    final db = await database;
    final results = await db.query(tableName);
    if (results.isNotEmpty) {
      List<AccountModel> accounts = [];
      for (final elem in results) {
        accounts.add(AccountModel.fromMap(elem));
      }
      return accounts;
    }
    return [];
  }

  Future<AccountModel?> getAccountById(String account_id) async {
    final db = await database;
    final results = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [account_id],
    );

    if (results.isNotEmpty) {
      return AccountModel.fromMap(results.first);
    }
    return null;
  }

  Future<bool> hasSufficientBalance(String account_id, double ammount) async {
    final account = await getAccountById(account_id);
    if (account == null) return false;
    return account.ammount >= ammount;
  }

  Future<void> updateAccountBalance(
    String account_id,
    double new_ammount,
  ) async {
    final db = await database;
    await db.update(
      tableName,
      {'ammount': new_ammount},
      where: 'id = ?',
      whereArgs: [account_id],
    );
  }

  Future<void> addToAccountBalance(String account_id, double ammount) async {
    final account = await getAccountById(account_id);
    if (account != null) {
      final newBalance = account.ammount + ammount;
      await updateAccountBalance(account_id, newBalance);
    }
  }

  Future<void> subtractFromAccountBalance(
    String account_id,
    double ammount,
  ) async {
    final account = await getAccountById(account_id);
    if (account != null) {
      final newBalance = account.ammount - ammount;
      await updateAccountBalance(account_id, newBalance);
    }
  }
}
