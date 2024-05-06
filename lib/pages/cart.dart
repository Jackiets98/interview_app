import 'dart:async';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:interview_test/constants/constant.dart';
import 'package:interview_test/pages/dashboard.dart';
import 'package:interview_test/pages/delivery_details.dart';
import 'package:interview_test/pages/receipt.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../constants/appicons.dart';
import 'cart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key, required this.id, required this.customer}) : super(key: key);
  final String id;
  final String customer;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  String? obtainedID;
  String? driverFirstName;
  String? driverLastName;
  bool isLoading = false;
  List<dynamic> addOnList = [];
  List<dynamic> deliveryList = [];
  double finalDeliveryPrice = 0.0;


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

      fetchAddOnList();
    });
  }

  Future<void> fetchAddOnList() async {
    final response = await http.get(
        Uri.parse(domain + 'api/getAddOns/' + this.widget.id + '/' +
            this.widget.customer));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        addOnList = responseData['addOnList'];
        deliveryList = responseData['deliveryDetails'];
        finalDeliveryPrice = responseData['finalDeliveryPrice'].toDouble();
        isLoading = false;
      });
    } else {
      // Handle error response
      print('Failed to fetch delivery list: ${response.statusCode}');
    }

    print(response.statusCode);
  }

  Future<void> cancelAddOns(String id) async {
    final url = Uri.parse(domain + 'api/cancelAddOn/$id');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        // Handle successful response
        print('Add-ons cancelled successfully');
        fetchAddOnList();
      } else {
        // Handle error response
        print('Failed to cancel add-ons: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions
      print('Error cancelling add-ons: $error');
    }
  }

  Future<void> confirmPayment() async {
    final url = Uri.parse(domain + 'api/confirmPayment/${this.widget.id}');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        // Handle successful response
        print('Add-ons cancelled successfully');
        fetchAddOnList();
      } else {
        // Handle error response
        print('Failed to cancel add-ons: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions
      print('Error cancelling add-ons: $error');
    }
  }

  double calculateTotalPrice() {
    double totalPrice = 0.0;

    // Calculate total price of add-ons
    for (var addOn in addOnList) {
      totalPrice += addOn['final_price'].toDouble();
    }

    // Add finalDeliveryPrice
    totalPrice += finalDeliveryPrice ?? 0.0;

    return totalPrice;
  }


  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, dd MMM').format(now);
    size = MediaQuery
        .of(context)
        .size;
    height = size.height;
    width = size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(
                context); // Navigate back when the back button is pressed
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'Cart',
          style: TextStyle(color: scaffoldBackgroundColor.mainColor),
        ), // Title text
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(
                child: CircularProgressIndicator()) // Show loading indicator
                : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: height / 36, horizontal: width / 36),
                child: Column(
                  children: [
                    SizedBox(height: height / 56),
                    ListView.builder(
                      shrinkWrap: true, // Added shrinkWrap to ListView
                      itemCount: deliveryList.length,
                      itemBuilder: (context, index) {
                        final delivery = deliveryList[index];
                        return ListTile(
                          title: Text(delivery['name']),
                          subtitle:
                          Text('Item Code: ${delivery['item_code']} x ${delivery['quantity']}'),
                          trailing:
                          Text('Price: RM ${finalDeliveryPrice.toStringAsFixed(2)}'),
                        );
                      },
                    ),
                    SizedBox(height: height / 56),
                    Text('Add Ons', style: TextStyle(fontSize: 16),),
                    SizedBox(height: 8),
                    Divider(
                      height: 2,
                      color: scaffoldBackgroundColor.mainColor,
                    ),
                    ListView.builder(
                      shrinkWrap: true, // Added shrinkWrap to ListView
                      itemCount: addOnList.length,
                      itemBuilder: (context, index) {
                        final addOn = addOnList[index];
                        return ListTile(
                          title: Text(addOn['name']),
                          subtitle:
                          Text('Item Code: ${addOn['item_code']} x ${addOn['a_quantity']}'),
                          trailing:
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  cancelAddOns(addOn['id']);
                                },
                                icon: Icon(Icons.remove),
                                color: Colors.red,
                              ),
                              Text('Price: RM ${addOn['final_price'].toStringAsFixed(2)}'),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: height / 36), // Add some space
                    // Display the total final price of all items
                    Text(
                      'Total Price: RM ${calculateTotalPrice().toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the cart screen
                  confirmPayment();

                  Fluttertoast.showToast(
                    msg: "Payment Done!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: scaffoldBackgroundColor.card,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );

                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LogisticsDashboard()), // Replace SpecificScreen() with your actual screen widget
                          (route) => false, // Clear the entire navigation stack
                    );
                  });

                },
                child: Text('Confirm And Make Payment',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: scaffoldBackgroundColor.mainColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


