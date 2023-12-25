import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constans{

 late SharedPreferences prefs ;

  void setData(String key , String data) async{

    prefs = await SharedPreferences.getInstance();

    prefs.setString(key, data);
  }

  Future<String?> getData(String key) async{
    prefs = await SharedPreferences.getInstance();

    return prefs.getString(key);
  }
  
  void deleteAll() async{
    prefs = await SharedPreferences.getInstance();

    prefs.clear();
  }


  void showToast(String message){
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

}