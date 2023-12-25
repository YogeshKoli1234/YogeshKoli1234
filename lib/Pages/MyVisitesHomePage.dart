import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'package:http/http.dart' as http;

import 'AccountTrrnList.dart';

class MyVisitesHomePage extends StatefulWidget {
  const MyVisitesHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyVisitesHomePage> createState() => _MyVisitesHomePage();
}

class _MyVisitesHomePage extends State<MyVisitesHomePage> {
  bool loaderStatus = false;
  List<dynamic> myVisites = [];

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    homeApi();
  }

  void homeApi() async {
    String? userTOken = await Constans().getData(StaticConstant().userToken);
    var url = Uri.parse('https://recovery.brandmetrics.in/api/v2/my-visits');

    setState(() {
      loaderStatus = true;
    });

    var formData = {
      'token': userTOken,
    };

    var response = await http.post(
      url,
      body: formData,
    );

    print(" response 2 ${response.body}");

    setState(() {
      loaderStatus = false;
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      print('Home Api: ${responseData}');
      if (responseData['status'] == "success") {
        setState(() {
          myVisites = responseData['data']['visits'];
        });
      }
    } else {}
  }

  Future<void> _refreshData() async {
    // Add your logic to refresh data here
    homeApi();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('My Visits',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            )),
        ),
        body: Stack(children: [

          Container(
            child: myVisites.isEmpty
                ? const Center(
              child: Text(
                'No Data Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontFamily: "Poppins",
                ),
              ),
            )
                : Padding(
              padding: const EdgeInsets.fromLTRB(10,0,10,10),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(child: _buildAccountTypeList(myVisites)),
                ],
              ),
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
        ]),
      ),
    );
  }


  Widget _buildAccountTypeList(List<dynamic> accounts) {
    return Column(
      children: accounts.map((type) {
        String customer = type['customer'] ?? '';
        String account = type['account'] + "" ?? '';
        String typeStr = type['type'] ?? '';
        String remark = type['remark'] ?? '';
        // String account =
        // (type['type'] != null) ? "₹ " + type['type'].toString() : '0';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AccountTrrnList(
                    title: '',
                      accountNum:account
                  )),
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
                            '$customer',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            "Account : $account",
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          SizedBox(height: 2.0),
                          Text(
                            "Type : $typeStr",
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          SizedBox(height: 2.0),
                          Text(
                            "Remark : ${remark.trim()}",
                            style: TextStyle(
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
