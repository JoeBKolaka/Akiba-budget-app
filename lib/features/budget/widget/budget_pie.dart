import 'package:akiba/theme/pallete.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BudgetPie extends StatefulWidget {
  const BudgetPie({super.key});

  @override
  State<BudgetPie> createState() => _BudgetPieState();
}

class _BudgetPieState extends State<BudgetPie> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Pallete.whiteColor,
      margin: const EdgeInsets.all(20.0),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 10, color: Pallete.greenColor),
            PieChartSectionData(value: 12),
            PieChartSectionData(value: 30),
            PieChartSectionData(value: 12),
            PieChartSectionData(value: 13),
            PieChartSectionData(value: 15),
          ],
        ),
      ),
    );
  }
}
