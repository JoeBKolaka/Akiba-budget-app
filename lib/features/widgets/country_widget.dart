// lib/widgets/currency_widget.dart
import 'package:akiba/models/currency.dart';
import 'package:flutter/material.dart';


class CurrencyWidget extends StatefulWidget {
  final Currency currency;
  final bool isSelected;
  final VoidCallback onTap;

  const CurrencyWidget({
    super.key,
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CurrencyWidget> createState() => _CurrencyWidgetState();
}

class _CurrencyWidgetState extends State<CurrencyWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Center(
          child: Text(
            widget.currency.symbol,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      title: Text(widget.currency.name),
      subtitle: Text('${widget.currency.code} • ${widget.currency.namePlural}'),
      trailing: widget.isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: widget.onTap,
    );
  }
}
