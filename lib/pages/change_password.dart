import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:interview_test/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/appicons.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  String? ownerID;
  String? hashedPassword;

  dynamic size;
  double height = 0.00;
  double width = 0.00;
  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    ownerID = sharedPreferences.getString('id');

    final url = Uri.parse(domain + 'api/ownerPassword/' + ownerID!);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      hashedPassword = data['password'];

      // Now you have the hashed password in 'hashedPassword'
      print('Hashed Password: $hashedPassword');
    } else {
      // Handle HTTP error
      print('HTTP Error Code: ${response.statusCode}');
    }
  }

  Future<void> submit() async {
    final bool passwordMatches = await BCrypt.checkpw(oldPassController.text.trim(), hashedPassword!);
    if (passwordMatches) {
      print('same');
      var url = Uri.parse(domain + 'api/updateOwnerPassword/' + ownerID!);

      final response = await http.post(
        url,
        body: {'password': newPassController.text.trim()},
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Password Updated!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(0.7),
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.pop(context);
      } else {
        // Handle registration error
        Fluttertoast.showToast(
          msg: "There is an error occurred.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(0.7),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Invalid Old Password.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  bool _obscureText = true;
  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _obscureText1 = true;
  void _togglePasswordStatus1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  bool _obscureText2 = true;
  void _togglePasswordStatus2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor.black,
        leading: InkWell(
          splashColor: scaffoldBackgroundColor.transparent,
          highlightColor: scaffoldBackgroundColor.transparent,
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_sharp,
            size: height / 36,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Change Password",
          style: TextStyle(
            fontSize: 22,
            color: scaffoldBackgroundColor.mainColor,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: height / 16, horizontal: width / 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FormField(
                labelText: 'Old Password',
                controller: oldPassController,
                obscureText: _obscureText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password.';
                  }
                  return null;
                },
                togglePasswordStatus: _togglePasswordStatus,
              ),
              SizedBox(
                height: height / 26,
              ),
              FormField(
                labelText: 'New Password',
                controller: newPassController,
                obscureText: _obscureText1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password.';
                  }
                  return null;
                },
                togglePasswordStatus: _togglePasswordStatus1,
              ),
              SizedBox(
                height: height / 26,
              ),
              FormField(
                labelText: 'Confirm Password',
                controller: confirmPassController,
                obscureText: _obscureText2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password.';
                  } else if (value != newPassController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
                togglePasswordStatus: _togglePasswordStatus2,
              ),
              SizedBox(
                height: height / 10,
              ),
              InkWell(
                splashColor: scaffoldBackgroundColor.transparent,
                highlightColor: scaffoldBackgroundColor.transparent,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    // All fields are valid, proceed with password change
                    submit();
                  }
                },
                child: Container(
                  height: height / 15,
                  width: width / 1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: scaffoldBackgroundColor.mainColor,
                  ),
                  child: Center(
                    child: Text(
                      "Save",
                      style: TextStyle(fontSize: 16, color: scaffoldBackgroundColor.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?) validator;
  final VoidCallback togglePasswordStatus;

  const FormField({
    Key? key,
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    required this.validator,
    required this.togglePasswordStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Center(
          child: CircleAvatar(
            radius: 18,
            backgroundColor: scaffoldBackgroundColor.lockbackgroung,
            child: SvgPicture.asset(
              FreeBankingAppSvgicons.lock,
              height: MediaQuery.of(context).size.height / 56,
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          child: TextFormField(
            controller: controller,
            cursorColor: scaffoldBackgroundColor.blue,
            style: TextStyle(
              fontSize: 20,
              color: scaffoldBackgroundColor.blue,
            ),
            obscureText: obscureText,
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(
                fontSize: 15,
                color: scaffoldBackgroundColor.textfield,
              ),
              hintText: 'Please insert $labelText',
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: scaffoldBackgroundColor.underline,
                ),
              ),
              hintStyle: TextStyle(
                fontSize: 13,
                color: scaffoldBackgroundColor.grey,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: MediaQuery.of(context).size.height / 36,
                ),
                onPressed: togglePasswordStatus,
                color: scaffoldBackgroundColor.textfield,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
