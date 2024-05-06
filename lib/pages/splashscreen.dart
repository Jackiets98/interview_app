import 'dart:convert';

import 'package:interview_test/pages/dashboard.dart';
import 'package:interview_test/pages/signup.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../main.dart';
import '../constants/constant.dart';

String? ownerID;
String? ownerName;
String? project;

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  String? deviceID;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future getID() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    ownerID = sharedPreferences.getString('id');
    ownerName = sharedPreferences.getString('name');
    project = sharedPreferences.getString('androidID');
  }

  Future<void> init() async {
    getID().whenComplete(() async {
      if(ownerID != null){
            Future.delayed(
              Duration(seconds: 2),
                  () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LogisticsDashboard()),
                  );
              },
            );
      }else{
        Future.delayed(
          Duration(seconds: 2),
              () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
          },
        );
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png', // Replace with the path to your logo image asset
            width: 150, // Adjust the width as needed
            height: 150, // Adjust the height as needed
            // You can use other properties like fit, color, etc., as per your requirements
          ),
          // Add more widgets and functionality as needed
        ],
      ),
      ),
    );
  }
}
