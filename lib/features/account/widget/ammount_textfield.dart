import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AmmountTextfield extends StatefulWidget {
  final TextEditingController? controller;
  const AmmountTextfield({super.key, this.controller});

  @override
  State<AmmountTextfield> createState() => _AmmountTextfieldState();
}

class _AmmountTextfieldState extends State<AmmountTextfield> {
  late TextEditingController _amountController;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_KE',
    symbol: 'Ksh',
    decimalDigits: 2,
  );
  double _amount = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController = widget.controller ?? TextEditingController();
    if (widget.controller == null) {
      _amountController.text = _currencyFormat.format(_amount);
    }
  }

  void _onAmountChanged(String value) {
    String cleanValue = value
        .replaceAll('Ksh', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();

    if (cleanValue.isEmpty) {
      setState(() {
        _amount = 0.0;
        _amountController.text = _currencyFormat.format(_amount);
      });
      return;
    }

    try {
      final parsed = double.tryParse(cleanValue) ?? 0.0;
      setState(() {
        _amount = parsed;
      });

      final cursorPosition = _amountController.selection.baseOffset;
      final formatted = _currencyFormat.format(parsed);

      int newPosition = cursorPosition;
      if (cursorPosition > formatted.length) {
        newPosition = formatted.length;
      }

      _amountController.value = _amountController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: newPosition),
      );
    } catch (e) {
      print('Error parsing amount: $e');
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
    return TextField(
      controller: _amountController,
      onChanged: _onAmountChanged,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
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