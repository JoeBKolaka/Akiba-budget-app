import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_currency_text_input_formatter/flutter_currency_text_input_formatter.dart';
import 'package:flutter/services.dart';

import '../../create account/cubit/currency_cubit.dart';

class AmmountTextfield extends StatefulWidget {
  final TextEditingController? controller;
  const AmmountTextfield({super.key, this.controller});

  @override
  State<AmmountTextfield> createState() => _AmmountTextfieldState();
}

class _AmmountTextfieldState extends State<AmmountTextfield> {
  late TextEditingController _amountController;
  late FlutterCurrencyTextInputFormatter _formatter;

  @override
  void initState() {
    super.initState();
    CurrencyPicked user =
          context.read<CurrencyCubit>().state as CurrencyPicked;
    _amountController = widget.controller ?? TextEditingController();
    
    _formatter = FlutterCurrencyTextInputFormatter(
      maxDecimalDigits: 2,
      decimalSeparator: '.', 
      thousandSeparator: ',', 
      leadingSymbol: user.user.symbol, 
    );
    
    // Set initial value to 0.00
    if (_amountController.text.isEmpty) {
      _amountController.text = _formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '0.00'),
      ).text;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _amountController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _amountController,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [_formatter],
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
      ),
      decoration: const InputDecoration(
        hintText: '0.00',
        hintStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    );
  }
}