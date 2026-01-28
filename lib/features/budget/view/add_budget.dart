import 'package:flutter/material.dart';

class AddBudget extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const AddBudget());
  const AddBudget({super.key});

  @override
  State<AddBudget> createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Text('Budget'),
    );
  }
}