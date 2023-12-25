import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';

class SettingHomePage extends StatefulWidget {
  const SettingHomePage({super.key, required this.title});

  final String title;

  @override
  State<SettingHomePage> createState() => _SettingHomePage();
}

class _SettingHomePage extends State<SettingHomePage> {
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   // setProfile();
  // }

  String userAgentname = "";
  String userDesignation = "";
  String userUserimage =
      "https://recovery.brandmetrics.in///assets//profile_photos//branch//c451904011091286327f931996c0a826.png";
  String userBranch = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userAgentname = prefs.getString(StaticConstant().userAgentname) ??
          ""; // Replace "yourKey" with your actual key
      userDesignation = prefs.getString(StaticConstant().userDesignation) ??
          ""; // Replace "yourKey" with your actual key
      userUserimage = prefs.getString(StaticConstant().userUserimage) ??
          "https://recovery.brandmetrics.in///assets//profile_photos//branch//c451904011091286327f931996c0a826.png"; // Replace "yourKey" with your actual key
      userBranch = prefs.getString(StaticConstant().userBranch) ??
          ""; // Replace "yourKey" with your actual key
    });

    // showToast(prefs.getString(StaticConstant().userUserimage).toString());
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () {
                print("Log out");
                Constans().deleteAll();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPage(
                        title: '',
                      )),
                );

                },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Section
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  userUserimage,
                  width: 100,
                  height: 100,
                  fit: BoxFit
                      .cover, // Adjust the BoxFit property based on your layout requirements.
                ),
              ),
              Text(
                userAgentname,
                style: const TextStyle(
                  fontSize: 22.0,
                  // fontWeight: ,
                  color: Color(0xFF000000),
                ),
              ),
              Text(
                userDesignation,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF23303B),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                userBranch,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF23303B),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
            ],
          ),
        ),

        // Bottom Section with Scrolling List
        Expanded(
          child: ListView(
            children: [
              Container(
                child: const Column(
                  children: [
                    Text(
                      "Privacy Policy and Terms of Use",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF000000),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "As soon as the agent records the collection transaction at the borrower’s location, the receipt for the payment is generated and sent digitally to the borrower on specified communication channels.",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF23303B),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // _login();
                    _showAlertDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xFF456EFE),
                      // Set the background color to #456EFE
                      minimumSize: Size(300, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8.0), // Set the desired border radius
                      ) // Set width and height
                      ),
                  child: const Text('Log-out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFFFFFFFF),
                      )),
                ),
              )
              // Add more ListTiles as needed
            ],
          ),
        ),
      ],
    );
  }
}
