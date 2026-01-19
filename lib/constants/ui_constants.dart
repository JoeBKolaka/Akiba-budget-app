import 'package:akiba/features/budget/view/budget_view.dart';
import 'package:akiba/features/statistics/views/statistics.dart';
import 'package:flutter/cupertino.dart';

class UiConstants {
  static List<Widget> bottomTabBarPages = [
    Text('Home'),
    Statistics(),
    BudgetView(),
  ];
}
