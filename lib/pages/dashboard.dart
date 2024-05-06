import 'package:interview_test/bottom_nav/home.dart';
import 'package:interview_test/constants/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bottom_nav/profile.dart';
import '../constants/appicons.dart';

class LogisticsDashboard extends StatefulWidget {
  const LogisticsDashboard({Key? key}) : super(key: key);

  @override
  State<LogisticsDashboard> createState() => _LogisticsDashboardState();
}

class _LogisticsDashboardState extends State<LogisticsDashboard> {
  String? obtainedID;
  String? driverFirstName;
  String? driverLastName;
  dynamic size;
  double height = 0.00;
  double width = 0.00;

  final List<Widget> _pages = const [
    HomeScreen(),
    Profile(),
  ];

  int _selectedItemIndex = 0;

  Widget _bottomTabBar() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedItemIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: scaffoldBackgroundColor.transparent,
        elevation: 0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                FreeBankingAppSvgicons.transport,
                // ignore: deprecated_member_use
                color: scaffoldBackgroundColor.black,
              ),
            ),
            activeIcon: Container(
              height: height / 16,
              width: height / 16,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: scaffoldBackgroundColor.dashboard),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  FreeBankingAppSvgicons.transport,
                  // ignore: deprecated_member_use
                  color: scaffoldBackgroundColor.mainColor,
                ),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                FreeBankingAppSvgicons.profile,
                // ignore: deprecated_member_use
                color: scaffoldBackgroundColor.black,
              ),
            ),
            activeIcon: Container(
              height: height / 16,
              width: height / 16,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: scaffoldBackgroundColor.dashboard),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  FreeBankingAppSvgicons.profile,
                  // ignore: deprecated_member_use
                  color: scaffoldBackgroundColor.mainColor,
                ),
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    setState(() {
      _selectedItemIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      obtainedID = sharedPreferences.getString('id');
      driverFirstName = sharedPreferences.getString('first_name');
      driverLastName = sharedPreferences.getString('last_name');
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App'),
        content: Text('Are you sure you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text('Yes'),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        bottomNavigationBar: _bottomTabBar(),
        body: _pages[_selectedItemIndex],
      ),
    );
  }
}
