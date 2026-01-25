import 'package:akiba/features/home/widget/transaction_list.dart';
import 'package:flutter/material.dart';

class TransactionBody extends StatelessWidget {
  const TransactionBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: TransactionList(),);
  }
}