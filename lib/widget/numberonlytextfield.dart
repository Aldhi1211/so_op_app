import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberOnlyTextField extends StatelessWidget {
  final String hintText;
  final String title;
  // final TextEditingController controller;
  final bool enable;
  final bool obscureText;
  final IconData icon;

  NumberOnlyTextField({
    Key? key,
    required this.title,
    required this.hintText,
    // required this.controller,
    this.enable = true,
    this.obscureText = false,
    this.icon = Icons.text_fields,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              enabled: enable,
              obscureText: obscureText,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Hanya angka
              ],
              style: TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon:
                    Icon(icon, color: Color(0xFF6D91F3)), // Ikon di kiri
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none, // Hilangkan border bawaan
              ),
            ),
          ),
        ],
      ),
    );
  }
}
