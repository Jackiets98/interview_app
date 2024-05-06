import 'dart:convert';

import 'package:interview_test/constants/constant.dart';
import 'package:interview_test/pages/product.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../constants/appicons.dart';

class DeliveryDetails extends StatefulWidget {
  const DeliveryDetails({required this.delivery});
  final Map<String, dynamic> delivery;

  @override
  State<DeliveryDetails> createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<DeliveryDetails> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  String? obtainedID;
  String? driverFirstName;
  String? driverLastName;
  bool isLoading = false;
  bool isDeliveryStarted = false;
  bool isDeliveryStopped = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();

  }

  void init() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      obtainedID = sharedPreferences.getString('id');
      driverFirstName = sharedPreferences.getString('first_name');
      driverLastName = sharedPreferences.getString('last_name');

      print(obtainedID);
    });
  }

  void startDelivery() async {
    // Get the current time
    DateTime currentTime = DateTime.now();

    // Format the current time
    String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTime);

    // Send HTTP POST request to your Laravel backend with formatted time
    var response = await http.post(
      Uri.parse( domain + 'api/startDelivery/' + obtainedID! + '/' + this.widget.delivery['id']),
      body: {
        'currentTime': formattedTime, // Pass the formatted time
      },
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Update the delivery status flag
      setState(() {
        isDeliveryStarted = true;
        this.widget.delivery['status'] = '1';
      });
      // Handle successful response
      print('Current time saved successfully');
    } else {
      // Handle error response
      print(response.statusCode);
      print('Failed to save current time');
    }
  }

  void stopDelivery() async{
    // Get the current time
    DateTime currentTime = DateTime.now();

    // Format the current time
    String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTime);

    // Send HTTP POST request to your Laravel backend with formatted time
    var response = await http.post(
      Uri.parse( domain + 'api/stopDelivery/' + obtainedID! + '/' + this.widget.delivery['id']),
      body: {
        'currentTime': formattedTime, // Pass the formatted time
      },
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Update the delivery status flag
      setState(() {
        isDeliveryStarted = false;
        this.widget.delivery['status'] = '2';
      });
      // Handle successful response
      print('Current time saved successfully');
    } else {
      // Handle error response
      print(response.statusCode);
      print('Failed to save current time');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, dd MMM').format(now);
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    String statusText = '';
    Color statusColor = Colors.black;
    print('Delivery Status: ${this.widget.delivery['status']}');
    if (this.widget.delivery['status'] == "0") {
      statusText = 'To Be Delivered';
      statusColor = Colors.blue; // Set color for "To Be Delivered"
    } else if (this.widget.delivery['status'] == "1") {
      statusText = 'Delivering';
      statusColor = Colors.yellow; // Set color for "To Be Delivered"
    } else if (this.widget.delivery['status'] == "2") {
      statusText = 'Delivered';
      statusColor = Colors.green; // Set color for "To Be Delivered"
    } else if (this.widget.delivery['status'] == "3") {
      statusText = 'Cancelled';
      statusColor = Colors.red; // Set color for "To Be Delivered"
    } else {
      print('Unknown status value: ${this.widget.delivery['status']}');
    }
    print('Status Text: $statusText');
    print('Status Text: $statusText');
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
        title: Text('Delivery Details', style: TextStyle(color: scaffoldBackgroundColor.mainColor),), // Title text
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/images/user.png")
              ),
            ),
            Text("${this.widget.delivery['first_name']} ${this.widget.delivery['last_name']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  color: scaffoldBackgroundColor.white,
                  elevation: 2.0, // Add elevation for a shadow effect
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 35,),
                              SizedBox(width: 20),
                              Text('${this.widget.delivery['location']}', style: TextStyle(fontSize: 20),),
                            ],
                          ),
                        ),
                        SizedBox(height: 8), // Add spacing between details
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.phone, size: 35,),
                              SizedBox(width: 20),
                              Text('0${this.widget.delivery['contact']}', style: TextStyle(fontSize: 20),),
                            ],
                          ),
                        )
                        ,SizedBox(height: 8),Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.wallet_travel, size: 35,),
                              SizedBox(width: 20),
                              Text('${this.widget.delivery['item_code']} - ${this.widget.delivery['name']}', style: TextStyle(fontSize: 20),),
                            ],
                          ),
                        )
                        ,SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.fire_truck, size: 35,),
                              SizedBox(width: 20),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0), // Adjust the value to control the pill shape
                                  border: Border.all(color: statusColor), // Apply border color
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(fontSize: 20, color: statusColor), // Set text color same as border color
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 50,),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(onPressed: (this.widget.delivery['status'] == "2" || this.widget.delivery['status'] == "3") ? null : (this.widget.delivery['status'] == "1" ? stopDelivery : startDelivery)
                            , child: Text(this.widget.delivery['status'] == "3" ? 'Delivery Cancelled':(this.widget.delivery['status'] == "2" ? 'Delivery Ended':(this.widget.delivery['status'] == "1" ? 'Stop Delivery' : 'Start Delivery')), style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: this.widget.delivery['status'] == "1" ? Colors.red : scaffoldBackgroundColor.mainColor,
                            ),),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 80,),
            this.widget.delivery['payment_done'] == '1'?
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      Uri url = Uri.parse(domain + 'printReceipt/' + this.widget.delivery['id'] + '/' +
                          this.widget.delivery['customer_id']);  // Replace 'https://example.com' with your desired URL
                      launchUrl(url);
                      print(url);
                    },
                    child: Text(
                      'Print Receipt',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scaffoldBackgroundColor.mainColor,
                    ),
                  ),
                ),
              ),
            ) :Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      if(this.widget.delivery['status'] == "3") {
                        null;
                      }else {
                        print(this.widget.delivery['id']);
                        print(this.widget.delivery['customer_id']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              ProductScreen(id: widget.delivery['id'],
                                  customer_id: widget.delivery['customer_id'])),
                        );
                      }
                    },
                    child: Text(
                      'Add Item',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scaffoldBackgroundColor.mainColor,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}