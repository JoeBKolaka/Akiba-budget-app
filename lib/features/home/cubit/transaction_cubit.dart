import 'package:akiba/models/transaction_model.dart';
import 'package:akiba/repository/transaction_local_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'transaction_state.dart';

// Cubit
class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionStateInitial());

  final transactionLocalRepository = TransactionLocalRepository();
  //final acountLocalRepository = AccountLocalRepository();
  final Uuid _uuid = Uuid();

  // Create new transaction with account balance validation
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
      await transactionLocalRepository.insertTransaction(
        transactionModel,
        user_id: user_id,
        category_id: category_id,
        account_id: account_id,
      );
      emit(TransactionStateAdd(transactionModel));
      print(transactionModel);
    } catch (e) {
      emit(TransactionStateError(e.toString()));
    }
  }

  // Validate account balance based on account type
}
