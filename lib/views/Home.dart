import 'package:flutter/material.dart';
import 'package:stock_opname/views/Login.dart';
import 'package:stock_opname/views/StockIn.dart';
import 'package:stock_opname/views/StockOut.dart';
import 'package:stock_opname/widget/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isPressed = false;

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken"); // Hapus token
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 400,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, // Mulai dari atas
                end: Alignment.bottomCenter, // Berakhir di bawah
                colors: [
                  Color(0xFF6D91F3), // Warna utama di atas
                  Color(0xFF6D91F3).withOpacity(0.0), // Transparan di bawah
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Back,",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "Aldhi Tanca Muriantono",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.clip,
                                ),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTapUp: (details) {
                            showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                details.globalPosition.dx, // Posisi X
                                details.globalPosition.dy +
                                    10, // Posisi Y (biar sedikit di bawah tombol)
                                details.globalPosition.dx + 10,
                                details.globalPosition.dy + 10,
                              ),
                              items: [
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: Icon(Icons.logout,
                                        color: Color(0xFF6D91F3)),
                                    title: Text("Logout"),
                                    onTap: () {
                                      Navigator.pop(context); // Tutup menu
                                      logout(context); // Panggil fungsi logout
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(45),
                              ),
                              child: Image.asset('assets/user.png'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StockIn()));
                          },
                          child: MenuWidget(
                            imagePath: 'assets/stockin.png',
                            title: 'Stock In',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StockOut()));
                          },
                          child: MenuWidget(
                            imagePath: 'assets/stockout.jpg',
                            title: 'Stock Out',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 20),
          //   child: GestureDetector(
          //     onTap: () {
          //       logout(context);
          //     },
          //     onTapDown: (_) =>
          //         setState(() => isPressed = true), // Saat ditekan
          //     onTapUp: (_) => setState(() => isPressed = false), // Saat dilepas
          //     onTapCancel: () =>
          //         setState(() => isPressed = false), // Saat dibatalkan
          //     child: AnimatedContainer(
          //       duration: Duration(milliseconds: 200),
          //       width: MediaQuery.of(context).size.width * 0.5,
          //       height: 50,
          //       decoration: BoxDecoration(
          //         color: isPressed
          //             ? Colors.blueGrey
          //             : Color(0xFF6D91F3), // Warna berubah saat ditekan
          //         borderRadius: BorderRadius.circular(10),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black
          //                 .withOpacity(0.34), // Warna shadow transparan
          //             blurRadius: 5, // Efek blur shadow
          //             spreadRadius: 1, // Seberapa luas shadow menyebar
          //             offset: Offset(0, 2), // Posisi shadow (x, y)
          //           ),
          //         ],
          //       ),
          //       child: Center(
          //           child: Text(
          //         "Logout",
          //         style: TextStyle(
          //             color: Colors.white,
          //             fontWeight: FontWeight.w600,
          //             fontSize: 16),
          //       )),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
