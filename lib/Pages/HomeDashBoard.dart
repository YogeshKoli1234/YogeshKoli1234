import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'AccountTrrnList.dart';
import 'LoginPage.dart';
import 'MainPageDeshboard.dart';
import 'package:http/http.dart' as http;

class HomeDashBoard extends StatefulWidget {
  const HomeDashBoard({super.key, required this.title});

  final String title;

  @override
  State<HomeDashBoard> createState() => _HomeDashBoard();
}

class _HomeDashBoard extends State<HomeDashBoard> {
  bool loaderStatus = false;

  int thisWeek = 0;

  int thisMonths = 0;

  int thisYear = 0;

  List<dynamic> accounts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    homeApi();
  }

  Future<void> showToast(String str) async {
    Fluttertoast.showToast(
      msg: str,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.red,
      fontSize: 16.0,
    );
  }

  void homeApi() async {
    String? userTOken = await Constans().getData(StaticConstant().userToken);
    var url = Uri.parse('https://recovery.brandmetrics.in/api/v2/dashboard');

    setState(() {
      loaderStatus = true;
    });
    // Create a Map for your form data

    var formData = {
      'token': userTOken,
    };

    var response = await http.post(
      url,
      body: formData,
    );

    // Map<String, dynamic> responseData = json.decode(response.body);

    print(" response 1 ${response.statusCode}");

    setState(() {
      loaderStatus = false;
    });

    if (response.statusCode == 200) {
      // Successful login
      // Parse the response if needed
      Map<String, dynamic> responseData = json.decode(response.body);
      // Do something with responseData
      print('Home Api Status: ${responseData['status'] == "success"}');
      if (responseData['status'] == "success") {
        List<dynamic> visits = responseData['data']['visits'];

        print("responseData['data'] ${responseData['data']['accounts']}");

        setState(() {
          thisWeek = visits[0]["count"];
          thisMonths = visits[1]["count"];
          thisYear = visits[2]["count"];
          accounts = responseData['data']['accounts'];
        });
      } else {}

      // Navigate to the home screen or perform other actions here
      // Navigator.pushNamed(context, '/home');
    } else if (response.statusCode == 401) {
      print("Log out");
      Constans().deleteAll();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const LoginPage(
                  title: '',
                )),
      );
    }
  }

  Future<void> _refreshData() async {
    // Add your logic to refresh data here
    // homeApi();
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(

          children: [
            Container(
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(10, 40, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text('Dashboard',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Visits Completed',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  // Top Section
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBox('This Week', thisWeek.toString(), Colors.green),
                          _buildBox(
                              'This Month', thisMonths.toString(), Colors.red),
                          _buildBox(
                              'This Quarter', thisYear.toString(), Colors.blue),
                        ],
                      )), // Add some space

                  // List of Account Types
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 20, 0, 5),
                    child: const Text(
                      'Branch Analytics',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshData,
                      child: Container(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Container(child: _buildAccountTypeList(accounts))
                          ],
                        ),
                      ),
                    ),
                  )
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


  Widget _buildBox(String title, String amount, Color textColor) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            child: Column(
              children: [
                Center(
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.normal,
                      color: Color(
                          0xFF000000), // Default color if textColor is not provided
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeList(List<dynamic> accounts) {
    return Column(
      children: accounts.map((type) {
        String label = type['label'] ?? '';
        // String accountNum = type['accountNum'] ?? '';
        String accountCount = type['count'] + " A/c" ?? 'A/c';
        String account =
            (type['amount'] != null) ? "₹ " + type['amount'].toString() : '0';

        return GestureDetector(
          // onTap: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) =>
          //             const AccountTrrnList(title: '', accountNum: "")),
          //   );
          // },
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
                          Row(
                            children: [
                              Text(
                                '$accountCount',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              Spacer(),

                              Text(
                                account,
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFFFFF),
                                ),
                              )

                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFFFFFFFF),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 5.0),
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
