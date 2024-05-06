import 'dart:convert';

import 'package:interview_test/constants/constant.dart';
import 'package:interview_test/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:o3d/o3d.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignupPage> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;
  O3DController o3dController = O3DController();

  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<bool> _onWillPop() async {
    SystemNavigator.pop(); // This will exit the app
    return true;
  }

  Future<void> loginUser(String phone, String password) async {
    final url = Uri.parse(domain + 'api/driverLogin');
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();


    final Map<String, String> requestBody = {
      'phone': phone,
      'password': password,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody), // Encode the request body to JSON
    );

      final body = json.decode(response.body);
      if (body['success'] == true) {
        var driverData = body['driver'];

        // Extract specific fields from the 'driver' object
        var id = driverData['id'];
        var firstName = driverData['first_name'];
        var lastName = driverData['last_name'];

        // Store data in SharedPreferences
        sharedPreferences.setString('id', id);
        sharedPreferences.setString('first_name', firstName);
        sharedPreferences.setString('last_name', lastName);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LogisticsDashboard()),
        );

      } else {
        // Unsuccessful authentication
          Fluttertoast.showToast(
            msg: body['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black.withOpacity(0.7),
            textColor: Colors.white,
            fontSize: 16.0,
          );
      }
  }


  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding:
            EdgeInsets.symmetric(vertical: height / 36, horizontal: width / 12),
            child: Column(
              children: [
                SizedBox(
                  height: height / 10,
                ),
                const Center(
                  child: Text(
                    "Welcome Back!",
                    style: TextStyle(
                        fontSize: 30,
                        color: scaffoldBackgroundColor.textblack),
                  ),
                ),
                SizedBox(
                  height: height / 96,
                ),
                const Center(
                  child: Text(
                    "Logistics System",
                    style: TextStyle(
                        fontSize: 15,
                        color: scaffoldBackgroundColor.textblack),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: height / 50,
                ),
                 Container(
                   height: 250,
                   width: 200,
                   child: const ModelViewer(
                   src: 'assets/cardboard_box_set.glb',
                   ar: false,
                   autoRotate: true,
                   disableZoom: true,
                   autoPlay: true,
                   disablePan: true,),
                 ),
                SizedBox(
                  height: height / 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: scaffoldBackgroundColor.profilebackgroung,
                        child: Icon(Icons.phone_android),
                      ),
                    ),
                    SizedBox(
                      width: width / 1.5,
                      child: TextField(
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
                    ),
                  ],
                ),
                SizedBox(
                  height: height / 26,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: scaffoldBackgroundColor.lockbackgroung,
                        child: Icon(Icons.password_outlined, color: Colors.orange,),
                      ),
                    ),
                    SizedBox(
                      width: width / 1.5,
                      child: TextField(
                        controller: passwordController,
                        cursorColor: scaffoldBackgroundColor.mainColor,
                        style: const TextStyle(
                          fontSize: 20,
                          color: scaffoldBackgroundColor.black,
                        ),
                        obscuringCharacter: "*",
                        obscureText: _obscureText,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              fontSize: 15,
                              color: scaffoldBackgroundColor.black,
                            ),
                            hintText: 'Please Insert Your Password',
                            focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: scaffoldBackgroundColor.underline)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: height / 36,
                              ),
                              onPressed: _togglePasswordStatus,
                              color: scaffoldBackgroundColor.textfield,
                            ),
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: scaffoldBackgroundColor.grey,
                            )),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height / 6,
                ),
                InkWell(
                  splashColor: scaffoldBackgroundColor.transparent,
                  highlightColor: scaffoldBackgroundColor.transparent,
                  onTap: () {
                    final phone = phoneController.text;
                    final password = passwordController.text;

                    loginUser(phone, password);
                  },
                  child: Container(
                    height: height / 15,
                    width: width / 1,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: scaffoldBackgroundColor.mainColor),
                    child: const Center(
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                            fontSize: 16, color: scaffoldBackgroundColor.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 76,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

