import 'package:akiba/models/category_model.dart';
import 'package:akiba/models/transaction_model.dart';
import 'package:akiba/repository/transaction_local_repository.dart';
import 'package:akiba/repository/category_local_repository.dart';
import 'package:akiba/repository/account_local_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionStateInitial()) {
    _init();
  }

  final TransactionLocalRepository _transactionLocalRepository =
      TransactionLocalRepository();
  final CategoryLocalRepository _categoryLocalRepository =
      CategoryLocalRepository();
  final AccountLocalRepository _accountLocalRepository =
      AccountLocalRepository();
  final Uuid _uuid = Uuid();

  TransactionLocalRepository get transactionLocalRepository =>
      _transactionLocalRepository;
  CategoryLocalRepository get categoryLocalRepository =>
      _categoryLocalRepository;
  AccountLocalRepository get accountLocalRepository => _accountLocalRepository;

  Future<void> _init() async {
    await loadTransactions();
  }

  Future<void> createTransaction({
    required String user_id,
    required String category_id,
    required String account_id,
    required String transaction_name,
    required double transaction_amount,
    required String transaction_type,
  }) async {
    try {
      emit(TransactionStateLoading());

      final account = await _accountLocalRepository.getAccountById(account_id);
      if (account == null) {
        emit(TransactionStateError('Account not found'));
        return;
      }

      double updatedAmount = account.ammount;
      final accountType = account.account_type.toLowerCase();

      if (accountType == 'loan') {
        if (transaction_type == 'income') {
          updatedAmount -= transaction_amount;
          if (updatedAmount < 0) {
            emit(
              TransactionStateError(
                'Paying too much - cannot have negative loan balance',
              ),
            );
            return;
          }
        } else if (transaction_type == 'expense') {
          updatedAmount += transaction_amount;
        }
      } else {
        if (transaction_type == 'income') {
          updatedAmount += transaction_amount;
        } else if (transaction_type == 'expense') {
          updatedAmount -= transaction_amount;

          if (accountType == 'saving' && updatedAmount < 0) {
            emit(
              TransactionStateError(
                'Cannot have negative balance in saving account',
              ),
            );
            return;
          } else if (accountType == 'normal' && updatedAmount < 0) {
            emit(
              TransactionStateError('Insufficient funds in checking account'),
            );
            return;
          }
        }
      }

      final transactionModel = TransactionModel(
        id: _uuid.v4(),
        user_id: user_id,
        category_id: category_id,
        account_id: account_id,
        transaction_name: transaction_name,
        transaction_amount: transaction_amount,
        transaction_type: transaction_type,
        created_at: DateTime.now(),
      );

      await _transactionLocalRepository.insertTransaction(
        transactionModel,
        user_id: user_id,
        category_id: category_id,
        account_id: account_id,
      );

      await _accountLocalRepository.updateAccountAmount(
        account_id,
        updatedAmount,
      );

      await loadTransactions();
    } catch (e) {
      print('Error creating transaction: $e');
      emit(TransactionStateError(e.toString()));
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      return await _categoryLocalRepository.getCategories();
    } catch (e) {
      emit(TransactionStateError(e.toString()));
      return [];
    }
  }

  Future<void> loadTransactions() async {
    try {
      emit(TransactionStateLoading());

      final transactions = await _transactionLocalRepository.getTransactions();
      emit(TransactionStateLoaded(transactions));
    } catch (e) {
      print('Error loading transactions: $e');
      emit(TransactionStateError(e.toString()));
    }
  }

  // Get transactions from current state
  List<TransactionModel> get transactions {
    if (state is TransactionStateLoaded) {
      return (state as TransactionStateLoaded).transactions;
    }
    return [];
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      emit(TransactionStateLoading());

      // Get the transaction to get account info
      final transaction = await _transactionLocalRepository.getTransactionById(
        transactionId,
      );
      if (transaction == null) {
        emit(TransactionStateError('Transaction not found'));
        return;
      }

      // Get the account to update its balance
      final account = await _accountLocalRepository.getAccountById(
        transaction.account_id,
      );
      if (account == null) {
        emit(TransactionStateError('Account not found'));
        return;
      }

      // Update account balance by reversing the transaction
      double updatedAmount = account.ammount;
      final accountType = account.account_type.toLowerCase();

      if (accountType == 'loan') {
        if (transaction.transaction_type == 'income') {
          updatedAmount += transaction.transaction_amount;
        } else if (transaction.transaction_type == 'expense') {
          updatedAmount -= transaction.transaction_amount;
        }
      } else {
        if (transaction.transaction_type == 'income') {
          updatedAmount -= transaction.transaction_amount;
        } else if (transaction.transaction_type == 'expense') {
          updatedAmount += transaction.transaction_amount;
        }
      }

      // Update account balance
      await _accountLocalRepository.updateAccountAmount(
        account.id,
        updatedAmount,
      );

      // Delete the transaction
      await _transactionLocalRepository.deleteTransaction(transactionId);

      // Reload transactions
      await loadTransactions();
    } catch (e) {
      print('Error deleting transaction: $e');
      emit(TransactionStateError(e.toString()));
    }
  }

  // Keep other methods as they were...
  Future<List<TransactionModel>> getTransactionsByCategoryId(
    String categoryId,
  ) async {
    try {
      final allTransactions = await _transactionLocalRepository
          .getTransactions();
      final categoryTransactions = allTransactions
          .where((transaction) => transaction.category_id == categoryId)
          .toList();
      return categoryTransactions;
    } catch (e) {
      print('Error getting transactions by category: $e');
      return [];
    }
  }

  Future<List<TransactionModel>> getTransactionsByCategoryAndDateRange(
    String categoryId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final allTransactions = await _transactionLocalRepository
          .getTransactions();

      List<TransactionModel> filteredTransactions = allTransactions
          .where((transaction) => transaction.category_id == categoryId)
          .toList();

      if (startDate != null) {
        filteredTransactions = filteredTransactions
            .where(
              (transaction) =>
                  transaction.created_at.isAfter(startDate) ||
                  transaction.created_at.isAtSameMomentAs(startDate),
            )
            .toList();
      }

      if (endDate != null) {
        filteredTransactions = filteredTransactions
            .where(
              (transaction) =>
                  transaction.created_at.isBefore(endDate) ||
                  transaction.created_at.isAtSameMomentAs(endDate),
            )
            .toList();
      }

      return filteredTransactions;
    } catch (e) {
      print('Error getting transactions by category and date range: $e');
      return [];
    }
  }

  Future<List<TransactionModel>> getTransactionsByAccountId(
    String accountId,
  ) async {
    try {
      final allTransactions = await _transactionLocalRepository
          .getTransactions();
      final accountTransactions = allTransactions
          .where((transaction) => transaction.account_id == accountId)
          .toList();
      return accountTransactions;
    } catch (e) {
      print('Error getting transactions by account: $e');
      return [];
    }
  }

  Future<List<TransactionModel>> getTransactionsByAccountAndDateRange(
    String accountId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final allTransactions = await _transactionLocalRepository
          .getTransactions();

      List<TransactionModel> filteredTransactions = allTransactions
          .where((transaction) => transaction.account_id == accountId)
          .toList();

      if (startDate != null) {
        filteredTransactions = filteredTransactions
            .where(
              (transaction) =>
                  transaction.created_at.isAfter(startDate) ||
                  transaction.created_at.isAtSameMomentAs(startDate),
            )
            .toList();
      }

      if (endDate != null) {
        filteredTransactions = filteredTransactions
            .where(
              (transaction) =>
                  transaction.created_at.isBefore(endDate) ||
                  transaction.created_at.isAtSameMomentAs(endDate),
            )
            .toList();
      }

      return filteredTransactions;
    } catch (e) {
      print('Error getting transactions by account and date range: $e');
      return [];
    }
  }

  Future<Map<String, double>> getAccountTotalsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _transactionLocalRepository.getAccountTotalsByDateRange(
        accountId,
        startDate,
        endDate,
      );
    } catch (e) {
      print('Error getting account totals: $e');
      return {'income': 0.0, 'expense': 0.0, 'net': 0.0};
    }
  }

  Future<Map<String, dynamic>> getAccountDataForBarchart(
    String accountId,
    String viewType,
    int weekOffset,
    int monthOffset,
    int yearOffset,
  ) async {
    try {
      DateTime startDate;
      DateTime endDate;
      final now = DateTime.now();

      if (viewType == 'weekly') {
        final baseDate = now.add(Duration(days: 7 * weekOffset));
        startDate = baseDate.subtract(Duration(days: baseDate.weekday - 1));
        endDate = startDate.add(const Duration(days: 6));
      } else if (viewType == 'monthly') {
        startDate = DateTime(now.year, now.month + monthOffset, 1);
        endDate = DateTime(startDate.year, startDate.month + 1, 0);
      } else if (viewType == 'yearly') {
        final year = now.year + yearOffset;
        startDate = DateTime(year, 1, 1);
        endDate = DateTime(year, 12, 31);
      } else {
        endDate = now;
        startDate = now.subtract(const Duration(days: 365));
      }

      Map<DateTime, double> barchartData;
      if (viewType == 'weekly' || viewType == 'monthly') {
        barchartData = await _transactionLocalRepository.getDailyAccountTotals(
          accountId,
          startDate,
          endDate,
        );
      } else {
        barchartData = await _transactionLocalRepository
            .getMonthlyAccountTotals(accountId, startDate, endDate);
      }

      final transactions = await getTransactionsByAccountAndDateRange(
        accountId,
        startDate: startDate,
        endDate: endDate,
      );

      return {
        'barchartData': barchartData,
        'transactions': transactions,
        'startDate': startDate,
        'endDate': endDate,
      };
    } catch (e) {
      print('Error getting account data for barchart: $e');
      return {
        'barchartData': {},
        'transactions': [],
        'startDate': DateTime.now(),
        'endDate': DateTime.now(),
      };
    }
  }
}
