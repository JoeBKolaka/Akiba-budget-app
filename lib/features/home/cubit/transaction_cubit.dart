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
    // Load transactions immediately when cubit is created
    _init();
  }

  final TransactionLocalRepository _transactionLocalRepository = TransactionLocalRepository();
  final CategoryLocalRepository _categoryLocalRepository = CategoryLocalRepository();
  final AccountLocalRepository _accountLocalRepository = AccountLocalRepository();
  final Uuid _uuid = Uuid();

  // Public getters for repositories
  TransactionLocalRepository get transactionLocalRepository => _transactionLocalRepository;
  CategoryLocalRepository get categoryLocalRepository => _categoryLocalRepository;
  AccountLocalRepository get accountLocalRepository => _accountLocalRepository;

  // Private initialization
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

      // Get account details
      final account = await _accountLocalRepository.getAccountById(account_id);
      if (account == null) {
        emit(TransactionStateError('Account not found'));
        return;
      }

      // Calculate new account amount
      double updatedAmount = account.ammount;
      
      if (transaction_type == 'income') {
        updatedAmount += transaction_amount;
      } else if (transaction_type == 'expense') {
        updatedAmount -= transaction_amount;
        
        final accountType = account.account_type.toLowerCase();
        if (accountType == 'saving' && updatedAmount < 0) {
          emit(TransactionStateError('Cannot have negative balance in saving account'));
          return;
        } else if (accountType == 'checking' && updatedAmount < 0) {
          emit(TransactionStateError('Insufficient funds in checking account'));
          return;
        }
      }

      // Create transaction model
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

      // Insert transaction
      await _transactionLocalRepository.insertTransaction(
        transactionModel,
        user_id: user_id,
        category_id: category_id,
        account_id: account_id,
      );

      // Update account balance
      await _accountLocalRepository.updateAccountAmount(account_id, updatedAmount);

      // Reload all transactions
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
}