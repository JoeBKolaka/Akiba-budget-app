// lib/widgets/currency_widget.dart
import 'package:akiba/utils/currencies.dart';
import 'package:flutter/material.dart';

import '../../home/views/home_view.dart' show HomeView;

class CurrencyWidget extends StatefulWidget {
  //final VoidCallback onTap;

  const CurrencyWidget({super.key});

  @override
  State<CurrencyWidget> createState() => _CurrencyWidgetState();
}

class _CurrencyWidgetState extends State<CurrencyWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Text(
                (currencies[index]['flag'].toString()),
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                currencies[index]['name'].toString(),
                style: const TextStyle(fontSize: 20, color: Colors.black),
              ),
              subtitle: Text(
                currencies[index]['symbol'].toString(),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              onTap: () {
                Navigator.push(context, HomeView.route());
              },
            ),
          );
        }, //
      ),
    );
  }
}
