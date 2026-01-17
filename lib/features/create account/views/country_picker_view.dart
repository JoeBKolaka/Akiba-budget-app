import 'package:akiba/features/services/currency_service.dart';
import 'package:akiba/models/currency.dart';
import 'package:flutter/material.dart';

class CountryPickerView extends StatefulWidget {
  final ValueChanged<Currency> onSelect;
  final bool showFlag;
  final bool showCurrencyName;
  final bool showCurrencyCode;
  final bool showSearchField;
  final String? searchHint;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  const CountryPickerView({
    super.key,
    required this.onSelect,
    this.showFlag = true,
    this.showCurrencyName = true,
    this.showCurrencyCode = true,
    this.showSearchField = true,
    this.searchHint,
    this.controller,
    this.physics,
  });

  @override
  State<CountryPickerView> createState() => _CountryPickerViewState();
}

class _CountryPickerViewState extends State<CountryPickerView> {
  final CurrencyService _currencyService = CurrencyService();

  late List<Currency> _currencyList;
  TextEditingController? _searchController;

  @override
  void initState() {
    _searchController = TextEditingController();
    _currencyList = _currencyService.getAll();

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
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: widget.showSearchField
                ? TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: widget.searchHint ?? "Search",
                      hintText: widget.searchHint ?? "Search",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color(0xFF8C98A8).withOpacity(0.2),
                        ),
                      ),
                    ),
                    onChanged: _filterSearchResults,
                  )
                : Container(),
          ),
          Expanded(
            child: ListView(
              physics: ScrollPhysics(),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Divider(thickness: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  void _filterSearchResults(String query) {
    List<Currency> searchResult = <Currency>[];

    if (query.isEmpty) {
      searchResult.addAll(_currencyList);
    } else {
      searchResult = _currencyList
          .where(
            (c) =>
                c.name.toLowerCase().contains(query.toLowerCase().trim()) ||
                c.code.toLowerCase().contains(query.toLowerCase().trim()),
          )
          .toList();
    }

  }
}
