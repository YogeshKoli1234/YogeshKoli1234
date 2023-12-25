import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';

// import 'package:mrecovery/Constants/Functions.dart';
// import 'package:mrecovery/Constants/StaticConstant.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'HomeDashBoard.dart';
import 'MainPageDeshboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _isPasswordVisible = false;

  TextEditingController _userIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _supportState = false;
  late final LocalAuthentication auth;

  bool loaderStatus = false;

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

  @override
  void initState() {
    super.initState();

    auth = LocalAuthentication();
    auth.isDeviceSupported().then((bool isSupported) => setState(() {
          _supportState = isSupported;
        }));

    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    // After the animation completes, navigate to the login screen
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Timer(
        //   Duration(seconds: 1),
        //       () => Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => LoginScreen()),
        //   ),
        // );
      }
    });
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

//Authenticate using biometric
  Future<bool> authenticate() async {
    // final hasBiometric = await hasBiometrics();

    if (_supportState) {
      return await auth.authenticate(
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
    } else {
      return false;
    }
  }

  void _login() async {
    final String userId = _userIdController.text;
    final String password = _passwordController.text;

    if (userId.isEmpty) {
      showToast("Please enter userId");
    } else if (password.isEmpty) {
      showToast("Please enter Password");
    } else {
      try {
        setState(() {
          loaderStatus = true;
        });
        // https://recovery.brandmetrics.in/api/v2/login
        var url = Uri.parse('https://recovery.brandmetrics.in/api/v2/login');

        // Create a Map for your form data
        var formData = {
          'USERID': userId,
          'PASSWORD': password,
        };

        // Make the POST request
        var response = await http.post(
          url,
          body: formData,
        );

        print(" response $response");

        setState(() {
          loaderStatus = false;
        });

        if (response.statusCode == 200) {
          // Successful login
          // Parse the response if needed
          Map<String, dynamic> responseData = json.decode(response.body);
          // Do something with responseData
          // print('Login successful: ${responseData['status']}');
          if (responseData['status'] == "success") {
            Constans().setData(StaticConstant().userToken.toString(),
                responseData['data']['token'].toString());
            Constans().setData(StaticConstant().userId.toString(),
                responseData['data']['userid'].toString());
            Constans().setData(StaticConstant().userDesignation.toString(),
                responseData['data']['designation'].toString());
            Constans().setData(StaticConstant().userAgentname.toString(),
                responseData['data']['agentname'].toString());
            Constans().setData(StaticConstant().userBranch.toString(),
                responseData['data']['branch'].toString());
            Constans().setData(StaticConstant().userUserimage.toString(),
                responseData['data']['userimage'].toString());

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const MainPageDeshboard(
                        title: '',
                      )),
            );
          } else {
            showToast(responseData['message']);
          }
        } else {
          showToast('Login failed. Status code: ${response.statusCode}');
        }
      } catch (e) {
        // Handle network errors or other exceptions
        print('Error during login: $e');
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            color: Color(0xFFFFFFFF),
            // color: const Color(0xFF23303B),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  // Adjust the radius as needed
                  child: Image.asset(
                    'assets/m_logo.jpg',
                    width: 80,
                    height: 80,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign In',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF000000),
                            fontFamily: "Poppins"),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0,9,10,12),
                        child: Text(
                          'Welcome to Metrics Recovery',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFFC7C7C7),
                              fontFamily: "Poppins"),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Text(
                        'User Id',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF000000),
                            fontFamily: "Poppins"),
                      ),
                      Theme(
                        data: ThemeData(
                          inputDecorationTheme: const InputDecorationTheme(
                            contentPadding: EdgeInsets.zero,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(
                                      0xFF000000)), // Set the border color
                            ),
                          ),
                        ),
                        child: TextField(
                          controller: _userIdController,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText: 'USER ID',
                            filled: true,
                            fillColor: Color(0xFFFFFFFF),
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Color(0XFFA4A9AE),
                              fontWeight: FontWeight.normal,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Password',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF000000),
                            fontFamily: "Poppins"),
                      ),
                      Theme(
                        data: ThemeData(
                          inputDecorationTheme: InputDecorationTheme(
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        child: TextField(
                          obscureText: !_isPasswordVisible,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            // Keeps label inside the input box

                            labelText: 'PASSWORD',
                            filled: true,
                            fillColor: Color(0xFFFFFFFF),
                            labelStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Color(0XFFA4A9AE),
                              fontWeight: FontWeight.normal,
                              fontSize: 12.0,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              child: Icon(
                                !_isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _login();
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
                        child: const Text('Sign in',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFFFFFFFF),
                            )),
                      ),
                    ],
                  ),
                ),
                // Text("Don’t have an account?")
              ],
            ),
          ),
          if (loaderStatus)
            // Loader overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                // Change the color and opacity as needed
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
