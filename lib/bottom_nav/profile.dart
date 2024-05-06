import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:interview_test/constants/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:interview_test/pages/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/appicons.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  String? obtainedID;
  String? driverFirstName;
  String? driverLastName;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController icController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String? driverIC;
  String? driverPhone;
  String? driverFirst;
  String? driverLast;
  bool isLoading = false;

  int selected = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    setState(() {
      isLoading = true;
    });

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

    fetchDriverDetails();
  }

  void fetchDriverDetails() async {
    final url = Uri.parse(domain + 'api/getDriverDetails/' + obtainedID!);

    final response = await http.get(
      url,
      headers: headers, // Encode the request body to JSON
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        print(responseData);
        driverPhone = responseData['driver']['contact'];
        driverIC = responseData['driver']['ic'];
        driverFirst = responseData['driver']['first_name'];
        driverLast = responseData['driver']['last_name'];

        icController.text = driverIC!;
        phoneController.text = driverPhone!;
        firstNameController.text = driverFirst!;
        lastNameController.text = driverLast!;

        setState(() {
          isLoading = false;
        });
      } else {
        // Handle HTTP request error
        Fluttertoast.showToast(
          msg: "Something Went Wrong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(0.7),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

    Future<void> updateDriver(String phoneNumber, String ic, String firstName,
        String lastName) async {
      var url = Uri.parse(domain + 'api/updateDriver/' + obtainedID!);

      final Map<String, String> requestBody = {
        'phone': phoneNumber,
        // Update to use the provided phoneNumber parameter
        'ic': ic,
        // Update to use the provided ic parameter
        'firstName': firstName,
        // Update to use the provided firstName parameter
        'lastName': lastName,
        // Update to use the provided lastName parameter
      };

      try {
        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            // Add other required headers if necessary
          },
          body: jsonEncode(requestBody), // Encode the request body to JSON
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: "Profile Updated!",
            // Toast configuration options
          );

        } else {
          // Handle other status codes
          print("Response Status Code: ${response.body}");
          Fluttertoast.showToast(
            msg: "Something Went Wrong!",
            // Toast configuration options
          );
        }
      } catch (e) {
        // Handle exceptions
        print("Error: $e");
        Fluttertoast.showToast(
          msg: "An error occurred: $e",
          // Toast configuration options
        );
      }
    }


    @override
    Widget build(BuildContext context) {
      size = MediaQuery
          .of(context)
          .size;
      height = size.height;
      width = size.width;
      return isLoading
          ? Scaffold(
        backgroundColor: scaffoldBackgroundColor.white,
        body: Center(
          child: SpinKitWanderingCubes(
            color: Colors.white,
          ),
        ),
      ): Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leadingWidth: width / 1,
          leading: Padding(
            padding: EdgeInsets.symmetric(horizontal: width / 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Profile",
                  style: TextStyle(
                      fontSize: 22,
                      color: scaffoldBackgroundColor.textblack),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async{
                // Navigate to the cart screen
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx) => SignupPage()), (route) => false);
              },
              icon: Icon(Icons.logout), // Use the shopping_cart icon
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: height / 36, horizontal: width / 36),
            child: Column(
              children: [
                SizedBox(
                  height: height / 96,
                ), Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      TextField(
                        controller: icController,
                        cursorColor: scaffoldBackgroundColor.mainColor,
                        style: TextStyle(
                          fontSize: 20,
                          color: scaffoldBackgroundColor.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'IC Number',
                          labelStyle: TextStyle(
                            fontSize: 15,
                            color: scaffoldBackgroundColor.black,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: scaffoldBackgroundColor.underline,
                            ),
                          ),
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: scaffoldBackgroundColor.grey,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      TextField(
                        controller: firstNameController,
                        cursorColor: scaffoldBackgroundColor.mainColor,
                        style: TextStyle(
                          fontSize: 20,
                          color: scaffoldBackgroundColor.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: TextStyle(
                            fontSize: 15,
                            color: scaffoldBackgroundColor.black,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: scaffoldBackgroundColor.underline,
                            ),
                          ),
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: scaffoldBackgroundColor.grey,
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      TextField(
                        controller: lastNameController,
                        cursorColor: scaffoldBackgroundColor.mainColor,
                        style: TextStyle(
                          fontSize: 20,
                          color: scaffoldBackgroundColor.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: TextStyle(
                            fontSize: 15,
                            color: scaffoldBackgroundColor.black,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: scaffoldBackgroundColor.underline,
                            ),
                          ),
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: scaffoldBackgroundColor.grey,
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      TextField(
                        controller: phoneController,
                        cursorColor: scaffoldBackgroundColor.mainColor,
                        style: TextStyle(
                          fontSize: 20,
                          color: scaffoldBackgroundColor.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(
                            fontSize: 15,
                            color: scaffoldBackgroundColor.black,
                          ),
                          hintText: 'Please Insert Your Phone Number',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: scaffoldBackgroundColor.underline,
                            ),
                          ),
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: scaffoldBackgroundColor.grey,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 300,),
                Container(
                  width: MediaQuery.of(context).size
                  .width,
                  child: ElevatedButton(onPressed: () {
                    final phoneNumber = phoneController.text;
                    final ic = icController.text;
                    final firstName = firstNameController.text;
                    final lastName = lastNameController.text;

                    updateDriver(phoneNumber, ic, firstName, lastName);
                  }, child: Text('Save', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: scaffoldBackgroundColor.mainColor),),
                )
              ],
            ),
          ),
        ),
      );
    }
  }
