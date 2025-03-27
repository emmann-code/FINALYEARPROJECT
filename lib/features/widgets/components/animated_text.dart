import 'package:flutter/material.dart';
class CustomTextField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
     required this.hintText,
     
     required this.obscureText, required this.controller});
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
            fontSize: 13
          ),
        filled: true,
        fillColor: Colors.black12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}