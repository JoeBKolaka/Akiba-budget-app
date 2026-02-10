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
    final sortedCurrencies = List.from(currencies)
      ..sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));

    return BlocListener<CurrencyCubit, CurrencyState>(
      listener: (context, state) {
        if (state is CurrencyPicked) {
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
          itemCount: sortedCurrencies.length,
          itemBuilder: (context, index) {
            final currency = sortedCurrencies[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Text(
                  currency['flag'].toString(),
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  currency['name'].toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                subtitle: Text(
                  currency['symbol'].toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  context.read<CurrencyCubit>().insertUser(
                    name: currency['name'].toString(),
                    symbol: currency['symbol'].toString(),
                    flag: currency['flag'].toString(),
                    decimalDigits: int.parse(
                      currency['decimal_digits'].toString(),
                    ),
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
