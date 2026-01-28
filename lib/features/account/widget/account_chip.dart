import 'package:akiba/features/account/cubit/account_cubit.dart';
import 'package:akiba/models/account_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef AccountChipOnTap = void Function(String accountId, String accountName);

class AccountChip extends StatefulWidget {
  final AccountChipOnTap? onTap;
  const AccountChip({super.key, this.onTap});

  @override
  State<AccountChip> createState() => _AccountChipState();
}

class _AccountChipState extends State<AccountChip> {
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

  String _getEmojiForAccountType(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'savings':
        return '💰';
      case 'loans':
        return '🏦';
      case 'checkings':
        return '💳';
      default:
        return '🏦';
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
      child: Center(
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.center,
          children: List.generate(_accounts.length, (index) {
            return InkWell(
              onTap: () {
                // Pass both account ID and name
                widget.onTap?.call(
                  _accounts[index].id, // id is already String, no need for toString()
                  _accounts[index].account_name,
                );
              },
              child: Chip(
                avatar: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Text(
                    _getEmojiForAccountType(_accounts[index].account_type),
                  ),
                ),
                label: Text(_accounts[index].account_name),
                backgroundColor: Colors.transparent,
                side: BorderSide(color: Colors.grey[300]!),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }),
        ),
      ),
    );
  }
}