import 'dart:async';
import 'dart:convert';

import 'package:interview_test/constants/constant.dart';
import 'package:interview_test/pages/delivery_details.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants/appicons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  String? obtainedID;
  String? driverFirstName;
  String? driverLastName;
  bool isLoading = false;
  List<dynamic> deliveryList = [];
  late Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) => fetchDeliveryList());
  }

  void init() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      obtainedID = sharedPreferences.getString('id');
      driverFirstName = sharedPreferences.getString('first_name');
      driverLastName = sharedPreferences.getString('last_name');

      print(obtainedID);
      fetchDeliveryList();
    });
  }

  Future<void> fetchDeliveryList() async {
    final response = await http.get(
        Uri.parse(domain + 'api/deliveryList/' + obtainedID!));

    if (response.statusCode == 200) {
      setState(() {
        deliveryList = json.decode(response.body)['deliveryList'];

        isLoading = false;
      });
    } else {
      // Handle error response
      print('Failed to fetch delivery list: ${response.statusCode}');
    }

      // throw Exception('Failed to load admin reports');
      print(response.statusCode);
    }

    @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
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
        leadingWidth: width / 1,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Welcome,",
                    style: TextStyle(
                        fontSize: 22,
                        color: scaffoldBackgroundColor.mainColor),
                  ),
                  Text(
                    " ${driverFirstName}!",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: scaffoldBackgroundColor.mainColor),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(11),
                child: SvgPicture.asset(
                  FreeBankingAppSvgicons.notificationwhite,
                  height: height / 36,

                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: height / 36, horizontal: width / 36),
          child: Column(
            children: [
              SizedBox(
                height: height / 56,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(width: 10), // Add some spacing between the text and the GIF
                ],
              ),
              Image.network(
                'https://i.pinimg.com/originals/c8/26/41/c8264172074eb50241381061719391fa.gif', // Replace this with the URL of your GIF
                width: 100, // Adjust the width of the GIF as needed
                height: 100, // Adjust the height of the GIF as needed
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                  itemCount: deliveryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final delivery = deliveryList[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        color: scaffoldBackgroundColor.card,
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: Text(
                            '${delivery['first_name']} ${delivery['last_name']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Item: ${delivery['item_code']} - ${delivery['name']} (${delivery['quantity']})',
                                  ),
                                  Text(
                                    'Location: ${delivery['location']}',
                                  ),
                                ],
                              ),
                              InkWell(child: Icon(Icons.menu, size: 30,),onTap: (){
                                // Navigate to the next page here
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => DeliveryDetails(delivery: delivery)),
                                );

                              },)
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}