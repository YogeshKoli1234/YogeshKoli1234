import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'AccountTrrnList.dart';
import 'package:http/http.dart' as http;

class SearchHomePage extends StatefulWidget {
  const SearchHomePage({super.key, required this.title});

  final String title;

  @override
  State<SearchHomePage> createState() => _SearchHomePage();
}

class _SearchHomePage extends State<SearchHomePage> {
  TextEditingController _searchText = TextEditingController();

  bool loaderStatus = false;

  int thisWeek = 0;

  int thisMonths = 0;

  int thisYear = 0;

  List<dynamic> accounts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // homeApi(_searchText.text);
  }

  Future<void> showToast(String str) async {
    Fluttertoast.showToast(
      msg: str,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  Future<void> _refreshData() async {
    // Add your logic to refresh data here
    homeApi(_searchText.text);
  }

  void homeApi(String search) async {
    String? userTOken = await Constans().getData(StaticConstant().userToken);
    var url = Uri.parse('https://recovery.brandmetrics.in/api/v2/search');

    setState(() {
      loaderStatus = true;
    });
    // Create a Map for your form data

    // showToast(userTOken.toString());
    var formData = {
      'token': userTOken,
      'search': search,
    };

    // Make the POST request
    var response = await http.post(
      url,
      body: formData,
    );

    print(" response 1 $response");

    setState(() {
      loaderStatus = false;
    });

    accounts.clear();

    if (response.statusCode == 200) {
      // Successful login
      // Parse the response if needed
      Map<String, dynamic> responseData = json.decode(response.body);
      // Do something with responseData
      print('Home Api: ${responseData}');
      if (responseData['status'] == "success") {
        setState(() {
          accounts = responseData['data'];
        });
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10, 50, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Section
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              "Account Number/Customer Name",
                              style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Color(0xFF3C4B72),
                                  fontFamily: "Poppins"),
                            ),
                          ),
                          Theme(
                            data: ThemeData(
                              inputDecorationTheme: const InputDecorationTheme(
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  // padding: EdgeInsets.symmetric(vertical: 20),
                                  child: TextField(
                                      controller: _searchText,
                                      // textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        labelText:
                                            'Enter Customer A/c /Customer Name',
                                        filled: true,
                                        fillColor: Color(0xFFFFFFFF),
                                        labelStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0,
                                        ),
                                      )),
                                ),
                                Divider(),
                                ElevatedButton(
                                  onPressed: () {
                                    // _login();
                                    if (_searchText.text.isNotEmpty) {
                                      homeApi(_searchText.text);
                                    }
                                    else{
                                      setState(() {
                                        accounts = [];
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: Color(0xFF456EFE),
                                      // Set the background color to #456EFE
                                      minimumSize: Size(double.infinity, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Set the desired border radius
                                      ) // Set width and height
                                      ),
                                  child: const Text('Search',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xFFFFFFFF),
                                      )),
                                )
                              ],
                            ),
                          ),
                        ],
                      )), // Add some space
                  // ,

                  // Bottom Section with Scrolling List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshData,
                      child: Container(
                        child: accounts.isEmpty &&
                                _searchText.text != "" &&
                                !loaderStatus
                            ? Center(
                                child: const Text(
                                  'No Data Found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  children: [
                                    Container(
                                        child: _buildAccountTypeList(accounts)),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (loaderStatus)
              // Loader overlay
              Container(
                color: Colors.black.withOpacity(0.5),
                // Change the color and opacity as needed
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeList(List<dynamic> accounts) {
    return Column(
      children: accounts.map((type) {
        String customername = type['customername'] ?? '';
        String accountNum = type['account'] ?? '';
        String typeStr = type['type'] ?? '';
        String account = type['account'] ?? '';
        String pendingamount = type['pendingamount'] ?? '';
        String accountCount = 'A/C';
        // String account = '0';

        return GestureDetector(
          onTap: () {
            // Handle the click event for the item (e.g., navigate to a new screen)
            // print('Item clicked: $type');
            // Navigator.push(context, '/AccountTrrnList');

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AccountTrrnList(title: '', accountNum: accountNum)),
            );
          },
          child: Card(
            color: Color(0xFF23303B),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$customername',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          SizedBox(height: 5.0),

                          Text(
                            'Type : $typeStr',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          SizedBox(height: 2.0),

                          Text(
                            'Account : $account ',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          SizedBox(height: 2.0),
                          Text(
                            'Pending Amount : ₹ $pendingamount ',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFFFFFFFF),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
