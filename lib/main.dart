import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_opname/views/Home.dart';
import 'package:stock_opname/views/Login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan plugin diinisialisasi
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _screen; // Untuk menyimpan halaman awal

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");

    setState(() {
      if (token != null && token.isNotEmpty) {
        print("Token di Main: ${token}");
        _screen = Home(); // Jika token ada, langsung ke Home
      } else {
        print("Token di Main: ${token}");
        _screen = Login(); // Jika tidak ada token, ke Login
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Opname',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _screen ??
          Scaffold(
              body: Center(
                  child: CircularProgressIndicator())), // Loading sementara
    );
  }
}
