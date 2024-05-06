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

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key, required this.id, required this.customer_id}) : super(key: key);
  final String id;
  final String customer_id;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  String? obtainedID;
  String? driverFirstName;
  String? driverLastName;
  bool isLoading = false;
  List<dynamic> productList = [];
  Map<String, int> selectedQuantities = {};


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void addToCart(List<Map<String, dynamic>> itemsToAdd) async {
    final url = domain + 'api/addOns/' + this.widget.id + '/' + this.widget.customer_id;

    // Convert the list of items to JSON format
    final jsonData = jsonEncode({'itemsToAdd': itemsToAdd});

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonData,
    );

    if (response.statusCode == 200) {
      print('Items added to cart successfully');

      Fluttertoast.showToast(
        msg: "Items added to cart successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: scaffoldBackgroundColor.card,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      print('Failed to add items to cart. Error: ${response.body}');
    }
  }


  void init() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      obtainedID = sharedPreferences.getString('id');
      driverFirstName = sharedPreferences.getString('first_name');
      driverLastName = sharedPreferences.getString('last_name');

      print(obtainedID);

      fetchProductList();
    });
  }

  Future<void> fetchProductList() async {
    final response = await http.get(
        Uri.parse(domain + 'api/productList/' + this.widget.customer_id));

    if (response.statusCode == 200) {
      setState(() {
        productList = json.decode(response.body)['priceList'];

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
        title: Text('Add Ons', style: TextStyle(color: scaffoldBackgroundColor.mainColor),),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to the cart screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen(id: this.widget.id, customer: this.widget.customer_id,)), // Replace CartScreen() with your actual cart screen widget
              );
            },
            icon: Icon(Icons.shopping_cart), // Use the shopping_cart icon
          ),
        ],// Title text
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: height / 36, horizontal: width / 36),
                child: Column(
                  children: [
                    SizedBox(
                      height: height / 56,
                    ),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(productList.length, (index) {
                        var product = productList[index];
                        String productId = product['id']; // Assuming each product has a unique ID
                        int quantity = selectedQuantities[productId] ?? 0; // Default quantity is 0 if not selected

                        return InkWell(
                          onTap: () {},
                          child: Card(
                            elevation: 2.0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Image.asset(
                                      'assets/images/item.png',
                                      width: 10,
                                      height: 10,
                                    ),
                                  ),
                                  SizedBox(height: 8,),
                                  Center(
                                    child: Text(
                                      product['name'],
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Center(
                                    child: Text('Price: RM ${product['final_price'].toStringAsFixed(2)}', style: TextStyle(fontSize: 15)),
                                  ),
                                  SizedBox(height: 4.0),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: scaffoldBackgroundColor.card, // Set the background color of the pill badge
                                      borderRadius: BorderRadius.circular(20.0), // Set the border radius to make it pill-shaped
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), // Adjust the padding as needed
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove),
                                          onPressed: () {
                                            setState(() {
                                              if (quantity > 0) {
                                                quantity--;
                                                selectedQuantities[productId] = quantity;
                                              }
                                            });
                                          },
                                        ),
                                        Text(quantity.toString()), // Display the current quantity
                                        IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              if (quantity < product['quantity']) {
                                                quantity++;
                                                selectedQuantities[productId] = quantity;
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  Center(child: Text('Remaining: ${product['quantity']}')),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
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
                  // Add functionality to add products to the cart
                  List<Map<String, dynamic>> itemsToAdd = [];
                  selectedQuantities.forEach((productId, quantity) {
                    if (quantity > 0) {
                      itemsToAdd.add({'productId': productId, 'quantity': quantity});
                      // Optionally, you can also add the price here if needed:
                      // itemsToAdd.add({'productId': productId, 'quantity': quantity, 'price': productPrice});
                    }
                  });

                  // Call addToCart only if there are items to add
                  if (itemsToAdd.isNotEmpty) {
                    // Call addToCart function with the populated itemsToAdd list
                    addToCart(itemsToAdd);
                    print(itemsToAdd);
                  } else {
                    // No items selected, provide feedback to the user
                    print('No items selected to add to the cart.');
                  }
                },

                child: Text('Add to Cart', style: TextStyle(fontSize: 20, color: Colors.white),),
                style: ElevatedButton.styleFrom(backgroundColor: scaffoldBackgroundColor.mainColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

