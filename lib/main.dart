import 'package:akiba/features/create%20account/views/country_picker_view.dart';
import 'package:akiba/models/currency.dart';
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.theme,
      home: CountryPickerView(onSelect: (Currency value) {}),
    );
  }
}
