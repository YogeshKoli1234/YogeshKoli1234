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
        Map<String, dynamic> accountInfo = responseData['data']['account'];

        print("visits Details " + responseData['data']['account'].toString());

        setState(() {
          visitsList = responseData['data']['visits'] ?? [];
          customerName = accountInfo['customername'];
          loanType = accountInfo['type'];
          loanAmount = "₹ " + accountInfo['amount'];
          sanctionDate = accountInfo['sanctiondate'];
          npaDate = accountInfo['npadate'];
          pendingAmount = "₹ " + accountInfo['pendingamount'].toString();
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


  @override
  Widget build(BuildContext context) {
    return Stack(
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
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Account Details",
                      style: const TextStyle(
                          fontSize: 20.0,
                          color: Color(0xFF3C4B72),
                          fontFamily: "Poppins"),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Card(
                color: Color(0xFF607080),
                child: SizedBox(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        const Text(
                          "Customer Name",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFFFFFFF),
                              fontFamily: 'Poppins'),
                        ),
                        Text(
                          customerName,
                          style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFFFFFFF),
                              fontFamily: 'Poppins'),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Loan Amount",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  loanAmount,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Loan Type",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  loanType,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Sanction Date : ",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  sanctionDate,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Npa Date ",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  npaDate,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Pending Amount",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  pendingAmount.toString(),
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  AddVisit( title: '',
                                accountNum: accountNum,refreshFunction : refreshData)));

                    // MaterialPageRoute(builder: (context) =>);

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_sharp,
                        color: Color(0xFFFFFFFF),
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      const Text('Add New Visit',
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
                height: 20,
              ),

              const Text(
                ' Previous Visits',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.normal,
                ),
              ),

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
                    : Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Container(child: _buildAccountTypeList(visitsList))
                          ],
                        ),
                      ),
              )
              // List of Items (Replace with your actual list)
              ,
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
              borderRadius: BorderRadius.circular(8.0), // Set the desired border radius
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
                    ),
                    SizedBox(width: 20,),
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
                                  color:  Colors.black,
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
