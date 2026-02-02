import 'package:akiba/features/account/cubit/account_cubit.dart';
import 'package:akiba/features/account/widget/ammount_textfield.dart';
import 'package:akiba/features/create%20account/cubit/currency_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AccountType { normal, savings, loan }

class AccountBottomSheet extends StatefulWidget {
  const AccountBottomSheet({super.key});

  @override
  State<AccountBottomSheet> createState() => _AccountBottomSheetState();
}

class _AccountBottomSheetState extends State<AccountBottomSheet> {
  AccountType selectedAccount = AccountType.normal;
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void createNewAccount() async {
    if (formKey.currentState!.validate()) {
      CurrencyPicked user =
          context.read<CurrencyCubit>().state as CurrencyPicked;
      String amountText = _amountController.text
          .replaceAll('Ksh', '')
          .replaceAll(',', '')
          .trim();
      double amount = double.tryParse(amountText) ?? 0.0;
      await context.read<AccountCubit>().createNewAccount(
        account_name: _accountController.text.trim(),
        ammount: amount,
        account_type: selectedAccount.name,
        user_id: user.user.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is AccountStateAdd) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Container(
          color: Colors.white,
          height: 360,
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Account Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _accountController,
                      decoration: const InputDecoration(
                        hintText: 'Enter account name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter account name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AmmountTextfield(controller: _amountController),
                    const SizedBox(height: 12),
                    SegmentedButton<AccountType>(
                      selected: {selectedAccount},
                      segments: const <ButtonSegment<AccountType>>[
                        ButtonSegment<AccountType>(
                          value: AccountType.normal,
                          label: Text('Normal'),
                        ),
                        ButtonSegment<AccountType>(
                          value: AccountType.savings,
                          label: Text('Savings'),
                        ),
                        ButtonSegment<AccountType>(
                          value: AccountType.loan,
                          label: Text('Loan'),
                        ),
                      ],
                      onSelectionChanged: (Set<AccountType> newSelection) {
                        setState(() {
                          selectedAccount = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((
                              Set<MaterialState> states,
                            ) {
                              return Colors.transparent;
                            }),
                        foregroundColor:
                            MaterialStateProperty.resolveWith<Color>((
                              Set<MaterialState> states,
                            ) {
                              return states.contains(MaterialState.selected)
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey;
                            }),
                        side: MaterialStateProperty.all<BorderSide>(
                          const BorderSide(color: Colors.transparent),
                        ),
                        elevation: MaterialStateProperty.all<double>(0),
                        shadowColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                        surfaceTintColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: createNewAccount,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
