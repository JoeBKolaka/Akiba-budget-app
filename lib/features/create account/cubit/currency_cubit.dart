import 'package:akiba/models/user_model.dart';
import 'package:akiba/repository/user_local_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  CurrencyCubit() : super(CurrencyInitial());
  final userLocalRepository = UserLocalRepository();
  final Uuid uuid = Uuid();

  void getUser() async {
    try {
      final userModel = await userLocalRepository.getUser();

      if (userModel != null) {
        emit(CurrencyPicked(userModel));
      } else {
      }
    } catch (e) {
      emit(CurrencyError('Failed to get user: $e'));
    }
  }

  void insertUser({
    required String name,
    required String symbol,
    required String flag,
    required int decimalDigits,
    required String thousandsSeparator,
  }) async {
    try {
      final userModel = UserModel(
        id: uuid.v4(),
        name: name,
        symbol: symbol,
        flag: flag,
        decimal_digits: decimalDigits,
        thousands_separator: thousandsSeparator,
        created_at: DateTime.now(),
      );
      await userLocalRepository.insertUser(userModel);
      emit(CurrencyPicked(userModel));
    } catch (e) {
      emit(CurrencyError('Failed to save user: $e'));
    }
  }
}