import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'HomeDashBoard.dart';
import 'MyVisitesHomePage.dart';
import 'SearchHomePage.dart';
import 'SettingHomePage.dart';

class MainPageDeshboard extends StatefulWidget {
  const MainPageDeshboard({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainPageDeshboard> createState() => _MainPageDeshboard();
}

class _MainPageDeshboard extends State<MainPageDeshboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeDashBoard(title: ''),
    SearchHomePage(title: ''),
    MyVisitesHomePage(title: ''),
    SettingHomePage(title: ''),
  ];

  Future<void> showToast(String str) async {
    Fluttertoast.showToast(
      msg: str,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        // backgroundColor: const Color(0xFF23303B),
        fixedColor: const Color(0xFF23303B),
        unselectedItemColor: const Color(0xFF607080),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        // Disable the button press animation

        showSelectedLabels: true,
        onTap: (index) {
          setState(() {
            // Only update the index if it's different from the current index
            if (_currentIndex != index) {
              _currentIndex = index;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'My Visits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
