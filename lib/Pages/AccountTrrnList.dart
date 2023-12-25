import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

// import 'package:mrecovery/Pages/AddVisit.dart';
// import 'package:mrecovery/Pages/LoadDetails.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'package:http/http.dart' as http;

import 'AddVisit.dart';
import 'LoadDetails.dart';

class AccountTrrnList extends StatefulWidget {
  const AccountTrrnList(
      {super.key, required this.title, required this.accountNum});

  final String title;

  final String accountNum;

  @override
  State<AccountTrrnList> createState() =>
      _AccountTrrnList(accountNum: accountNum);
}

class _AccountTrrnList extends State<AccountTrrnList> {
  bool loaderStatus = false;
  List<dynamic> visitsList = [];

  _AccountTrrnList({required this.accountNum});

  String accountNum = "";

  String customerName = "";
  String loanType = "";
  String loanAmount = "";
  String sanctionDate = "";
  String npaDate = "";
  String pendingAmount = "";
  Map<String, dynamic> accountInfo = {};

  void refreshData(String newData) {
    visits(accountNum);
    setState(() {
      // data = newData;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    visits(accountNum);

    print(accountNum);
    // _determinePosition();
  }

  void visits(String accountNum) async {
    String? userTOken = await Constans().getData(StaticConstant().userToken);
    var url = Uri.parse('https://recovery.brandmetrics.in/api/v2/list-visits');

    setState(() {
      loaderStatus = true;
    });
    var formData = {'token': userTOken, 'account': accountNum};

    // Make the POST request
    var response = await http.post(
      url,
      body: formData,
    );

    print(" formData 1 $formData");

    setState(() {
      loaderStatus = false;
    });

    if (response.statusCode == 200) {
      // Successful login
      // Parse the response if needed
      Map<String, dynamic> responseData = json.decode(response.body);
      // Do something with responseData
      print('Visites List Api: ${responseData}');
      if (responseData['status'] == "success") {
        accountInfo = responseData['data']['account'];

        print("visits Details " + responseData['data']['account'].toString());

        setState(() {
          visitsList = responseData['data']['visits'] ?? [];
          customerName = accountInfo['customername'];
          // loanType = accountInfo['type'];
          // loanAmount = "₹ " + accountInfo['amount'];
          // sanctionDate = accountInfo['sanctiondate'];
          // npaDate = accountInfo['npadate'];
          // pendingAmount = "₹ " + accountInfo['pendingamount'].toString();
          print("pendingAmount $pendingAmount");
        });
      }
    } else {}
  }

  Future<void> showLocationServiceAlertDialog(
      String title, String message) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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

  String capitalizeWords(String input) {
    if (input == null || input.isEmpty) {
      return input;
    }

    List<String> words = input.split(' ');
    List<String> capitalizedWords = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      } else {
        return '';
      }
    }).toList();

    return capitalizedWords.join(' ');
  }

  Widget _cardItem(Map<String, dynamic> accounts) {
    return Column(
      children: accounts.entries.map((type) {
        // print("Account type" +type.key);
        if (type.key != "customername") {
          return Row(
            children: [
              Text(
                capitalizeWords(type.key),
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              const Spacer(),
              Text(
                type.value.toString(),
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFFFFFFFF),
                ),
              )
            ],
          );
        } else {
          return Text("");
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Stack(
        children: [
          Scaffold(
              body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar

                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/ic_back.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        "Account Details",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Color(0xFF3C4B72),
                            fontFamily: "Poppins"),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),

                if (!loaderStatus)
                  Card(
                    color: Color(0xFF607080),
                    child: Container(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              customerName,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFFFFFFF),
                                  fontFamily: 'Poppins'),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Ac : $accountNum",
                              style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFFFFFFF),
                                  fontFamily: 'Poppins'),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Container(child: _cardItem(accountInfo)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddVisit(
                                        title: '',
                                        accountNum: accountNum,
                                        refreshFunction: refreshData)));
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Color(0xFF456EFE),
                              // Set the background color to #456EFE
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Set the desired border radius
                              ) // Set width and height
                              ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline_sharp,
                                color: Color(0xFFFFFFFF),
                                size: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text('New Visit',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                    fontFamily: "Poppins",
                                  )),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddVisit(
                                        title: '',
                                        accountNum: accountNum,
                                        refreshFunction: refreshData)));
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Color(0xFF456EFE),
                              // Set the background color to #456EFE
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Set the desired border radius
                              ) // Set width and height
                              ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline_sharp,
                                color: Color(0xFFFFFFFF),
                                size: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text('New Commit',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                    fontFamily: "Poppins",
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                const TabBar(
                  indicatorColor: Colors.grey,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Text(
                      'Visits',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      'Commits',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      'Documents',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Content for Tab 1
                      Container(
                        child: visitsList.isEmpty && !loaderStatus
                            ? Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: const Center(
                                  child: Text(
                                    'No Visits',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ),
                              )
                            : ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  Container(
                                    child: _buildAccountTypeList(visitsList),
                                  ),
                                ],
                              ),
                      ),
                      // Content for Tab 2
                      Container(
                          // Add content for Tab 2
                          ),
                      // Content for Tab 3
                      Container(
                          // Add content for Tab 3
                          ),
                    ],
                  ),
                )
              ],
            ),
          )),
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
    );
  }

  Widget _buildAccountTypeList(List<dynamic> accounts) {
    return Column(
      children: accounts.map((type) {
        String label = type['remark'] ?? '';
        String agent = type['agent'] ?? '';
        String timestamp = type['timestamp'] ?? '';
        List<dynamic> images = type['images'] ?? [];
        String id = type['id'] ?? '';
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      LoadDetails(title: '', id: id, images: images)),
            );
          },
          child: Card(
            color: Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey),
              borderRadius:
                  BorderRadius.circular(8.0), // Set the desired border radius
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/ic_visitor.png',
                      width: 40,
                      height: 40,
                      color: Color(0xFF607080),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${label}',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              Spacer(),
                              Text(
                                "Agent Name : $agent",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                  // textAlign: TextAlign.right
                                ),
                              ),
                            ],
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
