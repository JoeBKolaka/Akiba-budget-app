import 'package:akiba/features/account/cubit/account_cubit.dart';
import 'package:akiba/features/budget/cubit/budget_cubit.dart';
import 'package:akiba/features/category/cubit/add_new_category_cubit.dart';
import 'package:akiba/features/create%20account/cubit/currency_cubit.dart';
import 'package:akiba/features/create%20account/views/country_picker_view.dart';
import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:akiba/features/home/views/home_view.dart';
import 'package:akiba/models/currency.dart';
import 'package:akiba/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CurrencyCubit()),
        BlocProvider(create: (_) => CategoryCubit()),
        BlocProvider(create: (_) => AccountCubit()),
        BlocProvider(create: (_) => TransactionCubit()),
        BlocProvider(create: (_) => BudgetCubit()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;

  void changeTheme(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

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
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: BlocBuilder<CurrencyCubit, CurrencyState>(
        builder: (context, state) {
          if (state is CurrencyPicked) {
            return HomeView(changeTheme: changeTheme);
          }
          return CountryPickerView(
            onSelect: (Currency value) {},
            changeThemeMode: changeTheme,
          );
        },
      ),
    );
  }
}