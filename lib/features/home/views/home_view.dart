import 'package:akiba/constants/ui_constants.dart';
import 'package:akiba/features/category/view/category_view.dart';
import 'package:akiba/theme/pallete.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const HomeView());

  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _page = 0;

  void onPageChange(int index) {
    setState(() {
      _page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _page == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(context, CategoryView.route());
                  },
                  icon: Icon(Icons.category_rounded),
                ),
              ],
            )
          : null,
      body: IndexedStack(index: _page, children: UiConstants.bottomTabBarPages),
      floatingActionButton: _page == 0
          ? FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add, color: Pallete.whiteColor, size: 28),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        onTap: onPageChange,
        backgroundColor: Pallete.whiteColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_rounded,
              color: _page == 0 ? Pallete.greenColor : Pallete.greyColor,
              size: 28,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bar_chart_rounded,
              color: _page == 1 ? Pallete.greenColor : Pallete.greyColor,
              size: 28,
            ),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.credit_card_rounded,
              color: _page == 2 ? Pallete.greenColor : Pallete.greyColor,
              size: 28,
            ),
            label: 'Budget',
          ),
        ],
      ),
    );
  }
}
