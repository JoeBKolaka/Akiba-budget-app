import 'package:akiba/features/account/widget/account_chip.dart';
import 'package:flutter/material.dart';

class AccountBottom extends StatefulWidget {
  final Function(String accountId, String accountName)? onAccountSelected;

  const AccountBottom({super.key, this.onAccountSelected});

  @override
  State<AccountBottom> createState() => _AccountBottomState();
}

class _AccountBottomState extends State<AccountBottom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 300,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Choose an account',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Center(
            child: AccountChip(
              onTap: (accountId, accountName) {
                widget.onAccountSelected?.call(accountId, accountName);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
