import 'package:akiba/features/category/cubit/add_new_category_cubit.dart';
import 'package:akiba/features/create%20account/cubit/currency_cubit.dart';
import 'package:akiba/features/create%20account/views/country_picker_view.dart';
import 'package:akiba/features/home/views/home_view.dart';
import 'package:akiba/models/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CurrencyCubit()),
        BlocProvider(create: (_) => CategoryCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<CurrencyCubit>().getUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.theme,
      home: BlocBuilder<CurrencyCubit, CurrencyState>(
        builder: (context, state) {
          //return CountryPickerView(onSelect: (Currency value) {});
          if (state is CurrencyPicked) {
            return const HomeView();
          }
          return CountryPickerView(onSelect: (Currency value) {});
        },
      ),
    );
  }
}
