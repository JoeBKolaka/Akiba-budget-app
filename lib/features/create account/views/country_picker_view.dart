import 'package:akiba/features/create%20account/widgets/country_list.dart';
import 'package:akiba/features/create%20account/widgets/search_field.dart';
import 'package:akiba/models/currency.dart';
import 'package:flutter/material.dart';

class CountryPickerView extends StatefulWidget {
  final void Function(bool) changeThemeMode;
  final ValueChanged<Currency> onSelect;
  final String? searchHint;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  const CountryPickerView({
    super.key,
    required this.changeThemeMode,
    required this.onSelect,
    this.searchHint,
    this.controller,
    this.physics,
  });

  @override
  State<CountryPickerView> createState() => _CountryPickerViewState();
}

class _CountryPickerViewState extends State<CountryPickerView> {
  TextEditingController? _searchController;

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Currency')),
      body: Column(
        children: [
          const SizedBox(height: 12),
         
          Expanded(
            child: CurrencyWidget(
              changeThemeMode: widget.changeThemeMode,
            ),
          ),
        ],
      ),
    );
  }
}