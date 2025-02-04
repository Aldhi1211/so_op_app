import 'package:flutter/material.dart';
import 'package:stock_opname/config.dart';
import 'package:stock_opname/views/Home.dart';
import 'package:stock_opname/views/Register.dart';
import 'package:stock_opname/widget/textfield.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import package

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isPressed = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    String url = "${Config.baseUrl}/login"; // Ganti dengan URL API-mu
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, String> body = {
      "email": emailController.text,
      "password": passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Login Berhasil: ${data["accessToken"]}");
        String accessToken = data["accessToken"]; // Ambil token

        // Decode token untuk mendapatkan role
        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
        String role = decodedToken["role"] ?? ""; // Ambil role
        String email = decodedToken["email"] ?? ""; // Ambil role

        print("Role dari token: $role");

        if (role == "Petugas" || role == "Admin") {
          print("Login Berhasil sebagai Petugas");
          await saveToken(accessToken); // Simpan token
          await saveUserEmail(email); // Simpan token
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          });
        } else {
          // Jika bukan petugas, tampilkan pesan error
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Akses Ditolak"),
              content: Text(
                  "Hanya petugas yang bisa login! \n\nSilahkan hubungi admin untuk memberikan role"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                )
              ],
            ),
          );
        }
      } else {
        var data = jsonDecode(response.body);
        print("Email: ${emailController.text}");
        print("Password: ${passwordController.text}");
        print("Login Gagal: ${response.body}");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Gagal"),
            content: Text(data['msg']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", token);
  }

  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
  }

  String errorMessage = "";

  // Fungsi untuk validasi email
  bool isValidEmail(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 230,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bgbintang.jpg'),
                    fit: BoxFit.cover,
                  ),
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "PANGAN TERBAIK INDONESIA",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Login to your Account",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 17),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFieldCustom(
              title: "Email",
              hintText: "Email",
              controller: emailController,
              icon: Icons.person,
              onChanged: (value) {
                setState(() {
                  errorMessage = isValidEmail(value) ? "" : "Email tidak valid";
                });
              },
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 20, top: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
            SizedBox(
              height: 20,
            ),
            TextFieldCustom(
              title: "Password",
              hintText: "Password",
              controller: passwordController,
              icon: Icons.password,
              isPassword: true,
            ),
            isLoading
                ? CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        login();
                      },
                      onTapDown: (_) =>
                          setState(() => isPressed = true), // Saat ditekan
                      onTapUp: (_) =>
                          setState(() => isPressed = false), // Saat dilepas
                      onTapCancel: () =>
                          setState(() => isPressed = false), // Saat dibatalkan
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isPressed
                              ? Colors.blueGrey
                              : Color(0xFF6D91F3), // Warna berubah saat ditekan
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.34), // Warna shadow transparan
                              blurRadius: 5, // Efek blur shadow
                              spreadRadius: 1, // Seberapa luas shadow menyebar
                              offset: Offset(0, 2), // Posisi shadow (x, y)
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't Have an Account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Register()));
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                        color: Color(0xFF6D91F3), fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
