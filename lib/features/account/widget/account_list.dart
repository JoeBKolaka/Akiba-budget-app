// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:akiba/features/account/views/account_statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:akiba/features/account/cubit/account_cubit.dart';
import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:akiba/models/account_model.dart';

class AccountList extends StatefulWidget {
  final Function(String accountId, String accountName)? onAccountSelected;
  const AccountList({
    Key? key,
    required this.onAccountSelected,
  }) : super(key: key);

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
    final accounts = await context
        .read<AccountCubit>()
        .accountLocalRepository
        .getAccounts();
    if (mounted) {
      setState(() {
        _accounts = accounts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AccountCubit, AccountState>(
          listener: (context, state) {
            if (state is AccountStateAdd) {
              _loadAccounts();
            }
          },
        ),
        BlocListener<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state is TransactionStateLoaded) {
              _loadAccounts();
            }
          },
        ),
      ],
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
              child: Center(child: Icon(iconData, color: Colors.white)),
            ),
            title: Text(account.account_name),
            trailing: Text('Ksh ${account.ammount.toStringAsFixed(2)}'),
            onTap: () {
              // Call the callback if provided
              widget.onAccountSelected?.call(
                account.id,
                account.account_name ,
              );
             

              // Navigate to CategoryStatistics with all required parameters
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountStatistics(
                    accountId: account.id,
                    accountName: account.account_name,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}