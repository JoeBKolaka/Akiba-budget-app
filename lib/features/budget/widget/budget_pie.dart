import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../theme/pallete.dart';

class CategorPie extends StatefulWidget {
  const CategorPie({super.key});

  @override
  State<CategorPie> createState() => _CategorPieState();
}

class _CategorPieState extends State<CategorPie> {
  String _selectedView = 'allTime';
  String dateRange = 'All Time';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Pallete.whiteColor,
      margin: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cashflow'),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _selectedView = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'allTime',
                      child: Text('AllTime'),
                    ),
                    const PopupMenuItem(value: 'weekly', child: Text('Weekly')),
                    const PopupMenuItem(
                      value: 'monthly',
                      child: Text('Monthly'),
                    ),
                    const PopupMenuItem(value: 'yearly', child: Text('Yearly')),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 10,
                        color: Colors.green,
                        radius: 12,
                      ),
                      PieChartSectionData(
                        value: 12,
                        color: Colors.red,
                        radius: 12,
                      ),
                    ],
                    centerSpaceRadius: 100,
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ksh 2,000,000',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      // Handle backward navigation
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(dateRange),
                IconButton(
                  onPressed: () {
                    setState(() {
                      // Handle forward navigation
                    });
                  },
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
