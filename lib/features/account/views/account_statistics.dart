import 'package:akiba/features/account/widget/barchart/account_barchart.dart';
import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widget/barchart/account_transaction.dart';

class AccountStatistics extends StatefulWidget {
  final String accountId;
  final String accountName;

  const AccountStatistics({
    super.key,
    required this.accountId,
    required this.accountName,
  });

  @override
  State<AccountStatistics> createState() => _AccountStatisticsState();
}

class _AccountStatisticsState extends State<AccountStatistics> {
  DateTime selectedDate = DateTime.now();
  String selectedView = 'weekly';
  int weekOffset = 0;
  int monthOffset = 0;
  int yearOffset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionCubit>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.accountName)),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          return Column(
            children: [
              AspectRatio(
                aspectRatio: 0.9,
                child: AccountBarchart(
                  key: ValueKey(widget.accountId),
                  accountId: widget.accountId,
                  accountName: widget.accountName,
                  selectedView: selectedView,
                  selectedDate: selectedDate,
                  onViewChanged: (view, week, month, year) {
                    setState(() {
                      selectedView = view;
                      weekOffset = week;
                      monthOffset = month;
                      yearOffset = year;
                    });
                  },
                ),
              ),
              Expanded(
                child: AccountTransactionList(
                  accountId: widget.accountId,
                  selectedView: selectedView,
                  weekOffset: weekOffset,
                  monthOffset: monthOffset,
                  yearOffset: yearOffset,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
