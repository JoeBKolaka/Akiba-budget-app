import 'package:akiba/features/statistics/widget/bar_graph/bar_graph.dart';
import 'package:akiba/features/statistics/widget/bar_graph/statistics_list.dart';
import 'package:flutter/material.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  DateTime selectedDate = DateTime.now();
  String currentViewType = 'weekly';
  Map<String, dynamic> currentOffsets = {
    'weekOffset': 0,
    'monthOffset': 0,
    'yearOffset': 0,
    'viewType': 'weekly',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Statistics',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            BarGraph(
              selectedDate: selectedDate,
              onViewTypeChanged: (viewType) {
                setState(() {
                  currentViewType = viewType;
                });
              },
              onOffsetsChanged: (offsets) {
                setState(() {
                  currentOffsets = offsets;
                });
              },
            ),
            StatisticsList(
              selectedDate: selectedDate,
              viewType: currentViewType,
              offsets: currentOffsets,
            ),
          ],
        ),
      ),
    );
  }
}
