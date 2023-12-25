import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'LoginPage.dart';
import 'MainPageDeshboard.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.title});

  final String title;

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  bool _supportState = false;
  late final LocalAuthentication auth;
  Color backgroundColor = Colors.yellow; // Initial bright color

  void createAlbum(String title) async {
    var response = await http.post(
      Uri.parse('https://recovery.brandmetrics.in/api/v2/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'USERID': title,
        'PASSWORD': title,
      }),
    );

    print(response.body);
  }


  // SharedPreferences prefs =  SharedPreferences.getInstance() as SharedPreferences;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);


    auth = LocalAuthentication();
    auth.isDeviceSupported().then((bool isSupported) => setState(() {
      _supportState = isSupported;
    }));

    // _getAvailableBiometrics();
    Timer(
      Duration(seconds: 1),
          () => {authenticate()},
    );
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> available = await auth.getAvailableBiometrics();
    print("Available Devices $available");

    if (!mounted) {
      return;
    } else {}
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

//Authenticate using biometric
  Future<void> authenticate() async {
    // final hasBiometric = await hasBiometrics();
    String? userTOken = await Constans().getData(StaticConstant().userToken);
    print("userToken $userTOken");

    if (userTOken == null || userTOken == "null") {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const LoginPage(
              title: '',
            )),
      );
    }else{
      if (_supportState) {
        final isAuthenticatd = await auth.authenticate(
          localizedReason: "Scan fingerprint to authenticate",
          options: const AuthenticationOptions(
            //Shows error dialog for system-related issues
            useErrorDialogs: true,
            //If true, auth dialog is show when app open from background
            stickyAuth: true,
            //Prevent non-biometric auth like such as pin, passcode.
            biometricOnly: true,
          ),
        );

        if (isAuthenticatd) {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const MainPageDeshboard(
                    title: '',
                  )),
            );

        } else {}
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const MainPageDeshboard(
                title: '',
              )),
        );
      }

    }


  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          authenticate();
        },
        child: Container(
          color: Color(0xFF23303B),
          child: Image.asset(
            'assets/ic_finger.png',
            // Replace with the actual path to your image
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}