// lib/widgets/currency_widget.dart
import 'package:akiba/utils/currencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/views/home_view.dart' show HomeView;
import '../cubit/currency_cubit.dart';

class CurrencyWidget extends StatefulWidget {
  final void Function(bool) changeThemeMode;

  const CurrencyWidget({super.key, required this.changeThemeMode});

  @override
  State<CurrencyWidget> createState() => _CurrencyWidgetState();
}

class _CurrencyWidgetState extends State<CurrencyWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<CurrencyCubit, CurrencyState>(
      listener: (context, state) {
        if (state is CurrencyPicked) {
          // Navigate to home after saving currency
          Navigator.pushAndRemoveUntil(
            context,
            HomeView.route(widget.changeThemeMode),
            (route) => false,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView.builder(
          itemCount: currencies.length,
          itemBuilder: (context, index) {
            final currency = currencies[index];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Text(
                  currency['flag'].toString(),
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  currency['name'].toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                subtitle: Text(
                  currency['symbol'].toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
                onTap: () {
                  // Save the selected currency using Cubit
                  context.read<CurrencyCubit>().insertUser(
                    name: currency['name'].toString(),
                    symbol: currency['symbol'].toString(),
                    flag: currency['flag'].toString(),
                    decimalDigits: int.parse(
                      currency['decimal_digits'].toString(),
                    ), // Convert to int
                    thousandsSeparator: currency['thousands_separator']
                        .toString(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
