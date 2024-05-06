import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:interview_test/constants/constant.dart';
import 'package:interview_test/pages/delivery_details.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/appicons.dart';
import 'cart.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({Key? key, required this.id, required this.customer}) : super(key: key);
  final String id;
  final String customer;

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  String? obtainedID;
  String? driverFirstName;
  String? driverLastName;
  bool isLoading = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }


  void init() async {
    final SharedPreferences sharedPreferences = await SharedPreferences
        .getInstance();
    setState(() {
      obtainedID = sharedPreferences.getString('id');
      driverFirstName = sharedPreferences.getString('first_name');
      driverLastName = sharedPreferences.getString('last_name');

      print(obtainedID);

    });
  }


  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, dd MMM').format(now);
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Navigate back when the back button is pressed
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'Receipt',
          style: TextStyle(color: scaffoldBackgroundColor.mainColor),
        ), // Title text
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receipt',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Date: $formattedDate',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Items:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              itemCount: 2,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('name'),
                  subtitle: Text('Price: 2.00'),
                );
              },
            ),
            SizedBox(height: 16),
            Divider(height: 1, color: Colors.black),
            SizedBox(height: 16),
            Text(
              'Total Price: 5.00',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

}


