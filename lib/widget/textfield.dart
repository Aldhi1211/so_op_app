import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldCustom extends StatefulWidget {
  final String hintText;
  final String title;
  final TextEditingController controller;
  final bool enable;
  final TextInputType keyboardType;
  final IconData icon;
  final Function(String)? onChanged; // ⬅️ Tambahkan ini
  final bool isPassword;
  final bool isNumber;

  const TextFieldCustom({
    Key? key,
    required this.title,
    required this.hintText,
    required this.controller,
    this.enable = true,
    this.keyboardType = TextInputType.text,
    this.icon = Icons.text_fields,
    this.onChanged, // ⬅️ Tambahkan ini
    this.isPassword = false, // ⬅️ Tambahkan ini
    this.isNumber = false, // ⬅️ Tambahkan ini
  }) : super(key: key);

  @override
  State<TextFieldCustom> createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  bool _obscureText = true; // ⬅️ Default: Password tersembunyi

  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
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
              enabled: widget.enable,
              obscureText: widget.isPassword ? _obscureText : false,
              keyboardType:
                  widget.isNumber ? TextInputType.number : widget.keyboardType,
              inputFormatters: widget.isNumber
                  ? [FilteringTextInputFormatter.digitsOnly] // Hanya angka
                  : [], // Kosongkan agar semua karakter diperbolehkan
              controller: widget.controller,
              style: TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon:
                    Icon(widget.icon, color: Color(0xFF6D91F3)), // Ikon di kiri
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none, // Hilangkan border bawaan
                errorText: errorMessage, // ⬅️ Tampilkan pesan error
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF6D91F3),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText =
                                !_obscureText; // ⬅️ Toggle visibility
                          });
                        },
                      )
                    : null,
              ),
              onChanged:
                  widget.onChanged, // ⬅️ Jalankan fungsi jika ada perubahan
            ),
          ),
        ],
      ),
    );
  }
}
