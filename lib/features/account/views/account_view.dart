// ignore_for_file: unused_field

import 'package:akiba/features/account/widget/account_bottom_sheet.dart';
import 'package:akiba/features/account/widget/account_list.dart';
import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:akiba/features/account/cubit/account_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akiba/repository/account_local_repository.dart';
import 'package:akiba/models/account_model.dart';
import 'package:intl/intl.dart';

import '../../create account/cubit/currency_cubit.dart';

class AccountView extends StatefulWidget {
  final void Function(bool useLightMode) changeTheme;

  const AccountView({super.key, required this.changeTheme});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  late List<AccountModel> _accounts = [];
  late String _currencySymbol = 'Ksh ';
  late int _decimalPlaces = 2;
  late double _totalNetWorth = 0.0;

  void _showBottomSheet() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width > 480
            ? 480
            : double.infinity,
      ),
      builder: (context) => const AccountBottomSheet(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() async {
    if (!mounted) return;

    try {
      final currencyState = context.read<CurrencyCubit>().state;
      if (currencyState is CurrencyPicked) {
        _currencySymbol = currencyState.user.symbol;
        _decimalPlaces = currencyState.user.decimal_digits;
      }

      final repository = AccountLocalRepository();
      final accounts = await repository.getAccounts();

      double totalNetWorth = 0.0;
      for (var account in accounts) {
        if (account.account_type.toLowerCase().contains('loan') == true) {
          totalNetWorth -= account.ammount;
        } else {
          totalNetWorth += account.ammount;
        }
      }

      if (mounted) {
        setState(() {
          _accounts = accounts;
          _totalNetWorth = totalNetWorth;
        });
      }
    } catch (e) {}
  }

  String _formatNumber(double value) {
    return NumberFormat('#,##0.${'0' * _decimalPlaces}').format(value.abs());
  }

  Color _getNetWorthColor() {
    if (_totalNetWorth < 0) {
      return Colors.red;
    } else if (_totalNetWorth > 0) {
      return Colors.green;
    } else {
      return Theme.of(context).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final netWorthColor = _getNetWorthColor();

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
        BlocListener<CurrencyCubit, CurrencyState>(
          listener: (context, state) {
            if (state is CurrencyPicked) {
              if (mounted) {
                setState(() {
                  _currencySymbol = state.user.symbol;
                  _decimalPlaces = state.user.decimal_digits;
                });
              }
            }
          },
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Accounts',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Net Worth', style: TextStyle(fontSize: 12)),
                  Text(
                    '$_currencySymbol${_formatNumber(_totalNetWorth)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: netWorthColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: AccountList(
          onAccountSelected: (String accountId, String accountName) {},
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showBottomSheet,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
