import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType>(
      selected: {selectedType},
      segments: const <ButtonSegment<TransactionType>>[
        ButtonSegment<TransactionType>(
          value: TransactionType.income,
          label: Text('Income'),
          icon: Icon(Icons.arrow_upward),
        ),
        ButtonSegment<TransactionType>(
          value: TransactionType.expense,
          label: Text('Expense'),
          icon: Icon(Icons.arrow_downward),
        ),
      ],
      onSelectionChanged: (Set<TransactionType> newSelection) {
        onTypeChanged(newSelection.first);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((
          Set<MaterialState> states,
        ) {
          return Colors.transparent;
        }),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((
          Set<MaterialState> states,
        ) {
          return states.contains(MaterialState.selected)
              ? Theme.of(context).colorScheme.primary
              : Colors.grey;
        }),
        side: MaterialStateProperty.all<BorderSide>(
          const BorderSide(color: Colors.transparent),
        ),
        elevation: MaterialStateProperty.all<double>(0),
        shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
        overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
        surfaceTintColor: MaterialStateProperty.all<Color>(Colors.transparent),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
      ),
    );
  }
}
