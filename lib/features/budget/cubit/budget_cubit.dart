import 'package:akiba/models/budget_model.dart';
import 'package:akiba/repository/budget_local_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit() : super(BudgetStateInitial());
  final budgetLocalRepository = BudgetLocalRepository();
  final Uuid uuid = Uuid();

  Future<void> createNewBudget({
    required String category_id,
    required String user_id,
    required String repetition,
    required double budget_amount,
  }) async {
    try {
      final budgetModel = BudgetModel(
        id: uuid.v4(),
        user_id: user_id,
        category_id: category_id,
        budget_amount: budget_amount,
        repetition: repetition,
        created_at: DateTime.now(),
      );
      await budgetLocalRepository.insertBudget(
        budgetModel,
        user_id: user_id,
        category_id: category_id,
      );
      emit(BudgetStateAdd(budgetModel));
    } catch (e) {
      emit(BudgetStateError('Failed to save'));
    }
  }
}
