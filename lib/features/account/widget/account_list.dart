import 'package:akiba/features/account/cubit/account_cubit.dart';
import 'package:akiba/models/account_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountList extends StatefulWidget {
  const AccountList({super.key});

  @override
  State<AccountList> createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  late List<AccountModel> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() async {
    final accounts = await context.read<AccountCubit>().accountLocalRepository.getAccounts();
    if (mounted) {
      setState(() {
        _accounts = accounts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is AccountStateAdd) {
          _loadAccounts();
        }
      },
      child: ListView.builder(
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          
          Color backgroundColor;
          IconData iconData;
          
          switch (account.account_type) {
            case 'normal':
              backgroundColor = Colors.grey;
              iconData = Icons.account_balance_wallet;
              break;
            case 'savings':
              backgroundColor = Colors.green;
              iconData = Icons.savings;
              break;
            case 'loan':
              backgroundColor = Colors.red;
              iconData = Icons.money_off;
              break;
            default:
              backgroundColor = Colors.grey;
              iconData = Icons.account_balance_wallet;
          }
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: backgroundColor,
              child: Center(
                child: Icon(iconData, color: Colors.white),
              ),
            ),
            title: Text(account.account_name),
            trailing: Text('Ksh ${account.ammount.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}