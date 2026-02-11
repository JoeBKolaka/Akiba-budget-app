import 'package:akiba/features/account/views/account_statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:akiba/features/account/cubit/account_cubit.dart';
import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:akiba/models/account_model.dart';

import '../../create account/cubit/currency_cubit.dart';

class AccountList extends StatefulWidget {
  final Function(String accountId, String accountName)? onAccountSelected;
  const AccountList({Key? key, required this.onAccountSelected})
    : super(key: key);

  @override
  State<AccountList> createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  late List<AccountModel> _accounts = [];
  String _currencySymbol = '\$';
  int _decimalPlaces = 2;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() async {
    CurrencyPicked user = context.read<CurrencyCubit>().state as CurrencyPicked;
    final accounts = await context
        .read<AccountCubit>()
        .accountLocalRepository
        .getAccounts();
    if (mounted) {
      setState(() {
        _accounts = accounts;
        _currencySymbol = user.user.symbol;
        _decimalPlaces = user.user.decimal_digits;
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
          String emoji;

          switch (account.account_type) {
            case 'normal':
              backgroundColor = Colors.green;
              emoji = '💰';
              break;
            case 'savings':
              backgroundColor = Colors.green;
              emoji = '🏦';
              break;
            case 'loan':
              backgroundColor = Colors.red;
              emoji = '📈';
              break;
            default:
              backgroundColor = Colors.green;
              emoji = '💰';
          }

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: backgroundColor,
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            title: Text(account.account_name),
            trailing: Text(
              '$_currencySymbol${account.ammount.abs().toStringAsFixed(_decimalPlaces)}',
              style: TextStyle(
                color: account.account_type == 'loan' ? Colors.red : Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              widget.onAccountSelected?.call(account.id, account.account_name);

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