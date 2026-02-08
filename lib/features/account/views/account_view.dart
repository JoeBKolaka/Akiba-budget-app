import 'package:akiba/features/account/widget/account_bottom_sheet.dart';
import 'package:akiba/features/account/widget/account_list.dart';
import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountView extends StatefulWidget {
  final void Function(bool useLightMode) changeTheme;

  const AccountView({super.key, required this.changeTheme});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Accounts'),
        actions: [
          BlocBuilder<TransactionCubit, TransactionState>(
            builder: (context, state) {
              double totalNetWorth = 12367778;

              if (state is TransactionStateLoaded) {
                // Calculate net worth here if needed
              }

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Net Worth', style: TextStyle(fontSize: 12)),
                    Text(
                      'Ksh ${totalNetWorth.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: AccountList(
        onAccountSelected: (String accountId, String accountName) {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBottomSheet,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
