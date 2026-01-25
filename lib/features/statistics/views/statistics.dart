import 'package:akiba/theme/pallete.dart';
import 'package:flutter/material.dart';

class Statistics extends StatelessWidget {
  const Statistics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Statistics'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 2.0,
          child: Container(
            margin: const EdgeInsets.all(26),
            color: Pallete.whiteColor,
            //child: BarChart(),
          ),
        ),
      ),
    );
  }
}
