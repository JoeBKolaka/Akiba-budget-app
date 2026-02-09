import 'package:akiba/models/account_model.dart';
import 'package:akiba/repository/account_local_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit() : super(AccountInitial());
  final accountLocalRepository = AccountLocalRepository();
  final uuid = Uuid();

  Future<void> createNewAccount({
    required String account_name,
    required double ammount,
    required String account_type,
    required String user_id,
  }) async {
    try {
      final accountModel = AccountModel(
        id: uuid.v4(),
        user_id: user_id,
        account_name: account_name,
        ammount: ammount,
        account_type: account_type,
        created_at: DateTime.now(),
      );
      await accountLocalRepository.insertAccount(
        accountModel,
        user_id: user_id,
      );
      emit(AccountStateAdd(accountModel));
    } catch (e) {
      emit(AccountStateError(e.toString()));
    }
  }

  Future<void> fetchAccounts() async {
    try {
      final accounts = await accountLocalRepository.getAccounts();
      emit(AccountStateLoaded(accounts));
    } catch (e) {
      emit(AccountStateError(e.toString()));
    }
  }

  Future<double> calculateNetWorth() async {
    try {
      final accounts = await accountLocalRepository.getAccounts();
      double totalNetWorth = 0.0;
      
      for (var account in accounts) {
        if (account.account_type == 'loans') {
          totalNetWorth -= account.ammount;
        } else {
          totalNetWorth += account.ammount;
        }
      }
      
      return totalNetWorth;
    } catch (e) {
      return 0.0;
    }
  }
}