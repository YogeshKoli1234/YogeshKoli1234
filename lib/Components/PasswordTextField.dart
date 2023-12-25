import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {

  PasswordTextField(TextEditingController passwordController);

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never, // Keeps label inside the input box

        labelText: 'Password',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Color(0XFFA4A9AE),
          fontWeight: FontWeight.normal,
          fontSize: 14.0,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          child: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
