import 'package:flutter/material.dart';
import 'package:stock_opname/config.dart';
import 'package:stock_opname/views/Login.dart';
import 'package:stock_opname/widget/textfield.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isPressed = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController confPassController = TextEditingController();
  bool isLoading = false;

  Future<bool> checkEmailExists(String email) async {
    String url =
        "${Config.baseUrl}/search?check_email=$email"; // Ganti dengan API-mu
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Jika data NULL atau kosong, anggap email tidak ada
        if (data == null || data.isEmpty || data["response"] == null) {
          print("Email tidak ditemukan!");
          return false;
        }

        print("Email ditemukan!");
        return true;
      } else {
        print("Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error saat cek email: $e");
    }

    return false; // Default: anggap email belum ada jika terjadi error
  }

  Future<void> register() async {
    setState(() {
      isLoading = true;
    });

    // 🔍 Validasi Field Kosong
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Harap isi semua kolom sebelum mendaftar."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    // 🔍 Validasi Format Email
    if (!isValidEmail(emailController.text)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Format Email Salah"),
          content: Text("Silakan masukkan email yang valid."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    // 🔍 Validasi Panjang Password (Minimal 6 Karakter)
    if (passwordController.text.length < 6) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Password Terlalu Pendek"),
          content: Text("Password harus memiliki minimal 6 karakter."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    // 🔍 Cek apakah email sudah ada di database
    bool emailExists = await checkEmailExists(emailController.text);
    if (emailExists) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Peringatan"),
          content: Text("Email sudah terdaftar. Gunakan email lain."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            )
          ],
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    String url = "${Config.baseUrl}/users";
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, String> body = {
      "name": nameController.text,
      "email": emailController.text,
      "password": passwordController.text,
      "confPassword": confPassController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Register Berhasil");
        Future.microtask(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        });
      } else {
        var data = jsonDecode(response.body);
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

  String passwordError = ""; // ⬅️ Simpan error di sini
  String confPassError = ""; // ⬅️ Simpan error di sini
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
                    "Register to your Account",
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
              title: "Name",
              hintText: "Name",
              controller: nameController,
              icon: Icons.person,
            ),
            SizedBox(
              height: 10,
            ),
            TextFieldCustom(
              title: "Email",
              controller: emailController,
              hintText: "Email",
              icon: Icons.email,
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
              height: 10,
            ),
            TextFieldCustom(
              title: "Password",
              hintText: "Password",
              controller: passwordController,
              icon: Icons.password,
              isPassword: true,
              onChanged: (value) {
                setState(() {
                  if (value.length < 6) {
                    passwordError = "Password harus lebih dari 6 karakter";
                  } else {
                    passwordError = ""; // Jika valid, hapus pesan error
                  }
                });
              },
            ),
            if (passwordError.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 20, top: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    passwordError,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
            SizedBox(
              height: 10,
            ),
            TextFieldCustom(
              title: "Confirm Password",
              controller: confPassController,
              hintText: "Confirm Password",
              icon: Icons.password,
              isPassword: true,
              onChanged: (value) {
                setState(() {
                  if (passwordController.text != confPassController.text) {
                    confPassError = "Konfirmasi password tidak cocok";
                  } else {
                    confPassError = ""; // Jika valid, hapus pesan error
                  }
                });
              },
            ),
            if (confPassError.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 20, top: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Konfirmasi Password tidak cocok",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 10),
              child: GestureDetector(
                onTap: () {
                  register();
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
                      "Register",
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
                Text("Already Have an Account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                  child: Text(
                    "Sign In",
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
