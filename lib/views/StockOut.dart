import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stock_opname/config.dart';
import 'package:stock_opname/views/Home.dart';
import 'package:stock_opname/widget/textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockOut extends StatefulWidget {
  const StockOut({super.key});

  @override
  State<StockOut> createState() => _StockOutState();
}

class _StockOutState extends State<StockOut> {
  String? selectedValue;
  String? selectedValueSatuan;
  bool isPressed = false;
  TextEditingController stockNow = TextEditingController();
  TextEditingController stockOut = TextEditingController();

  List<dynamic> items = []; // Ubah menjadi list kosong
  List<String> satuans = ["kg", "pcs", "box"];

  Future<void> getStock(String idBarang, String satuan) async {
    String url =
        "${Config.baseUrl}/stock/get_stock?barang=$idBarang&satuan=$satuan"; // Sesuaikan dengan API-mu

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.containsKey('response') && data['response'] != null) {
          setState(() {
            print(data);
            stockNow.text = data['response']['quantity'].toString();
          });
        } else {
          stockNow.text = "0";
          print("Stock data tidak ditemukan.");
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Gagal"),
            content: Text("Periksa Koneksi Internet Anda dan coba kembali"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
        print("Gagal mengambil stock barang.");
      }
    } catch (e) {
      print("Error saat mengambil stock: $e");
    }
  }

  Future<bool> getBarang() async {
    String url = "${Config.baseUrl}/barang"; // Ganti dengan API-mu

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['response'] is List) {
          setState(() {
            items = data['response']; // Simpan list barang
          });
        } else {
          print("Format data API tidak sesuai.");
        }
        print(data);
      } else {
        print("Barang not Exist !!!");
        return false;
      }
    } catch (e) {
      print("Error saat get barang: $e");
    }

    return false; // Default: anggap email belum ada jika terjadi error
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail'); // Mengambil email yang disimpan
  }

  // Fungsi untuk menambah stok
  Future<void> issuedStock(String idBarang, int quantity, String satuan) async {
    String url =
        "${Config.baseUrl}/issuedstock"; // URL API pertama (issuedstock)

    // Data yang akan dikirimkan ke API pertama
    Map<String, dynamic> data = {
      'id_barang': idBarang,
      'quantity': quantity,
      'satuan': satuan,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data), // Mengirim data dalam format JSON
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Jika request pertama berhasil
        var responseData = jsonDecode(response.body);
        print("Stok berhasil dikeluarkan: $responseData");

        // Ambil email pengguna yang sedang login
        String? submittedBy =
            await getUserEmail(); // Mendapatkan email pengguna
        if (submittedBy == null) {
          print("Email pengguna tidak ditemukan.");
          return;
        }

        // Kirim data ke API kedua /stockout
        await issuedStockOut(idBarang, quantity, satuan, submittedBy);
      } else {
        // Jika request pertama gagal
        print("Gagal mengeluarkan stok");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Gagal"),
            content: Text("Stok gagal dikeluarkan"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Home())),
                child: Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      print("Error saat mengeluarkan stok: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Gagal"),
          content:
              Text("Terjadi kesalahan saat memproses respons dari server."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

// Fungsi untuk memanggil API /stockout
  Future<void> issuedStockOut(
      String idBarang, int quantity, String satuan, String submittedBy) async {
    String url = "${Config.baseUrl}/stockout"; // URL API kedua (stockout)

    // Data yang akan dikirimkan ke API kedua
    Map<String, dynamic> data = {
      "id_barang": idBarang,
      "tanggal_keluar": DateTime.now()
          .toIso8601String()
          .split('T')[0], // Format tanggal: yyyy-mm-dd
      "quantity": quantity.toString(),
      "satuan": satuan,
      "submitted_by":
          submittedBy, // Menggunakan email yang didapat dari getUserEmail
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data), // Mengirim data dalam format JSON
      );

      if (response.statusCode == 201) {
        // Jika request kedua berhasil
        print("StockOut berhasil dikurangi.");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content:
                Text("Stock berhasil dikeluarkan dan tercatat di StockOut."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      } else {
        // Jika request kedua gagal
        var errorData = jsonDecode(response.body);
        print(errorData);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Gagal"),
            content: Text("StockOut gagal diproses: ${errorData['message']}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("Error saat mengurangi StockOut: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Gagal"),
          content:
              Text("Terjadi kesalahan saat memproses respons dari server."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getBarang(); // Ambil data barang dari API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6D91F3),
        title: Text(
          "Stock Out",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Barang",
                    style: TextStyle(fontSize: 16),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedValue,
                        hint: Text("Pilih Barang"),
                        isExpanded:
                            true, // Agar dropdown mengikuti lebar container
                        icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue;
                          });

                          // Panggil API jika barang sudah dipilih
                          if (selectedValue != null &&
                              selectedValueSatuan != null) {
                            getStock(selectedValue!, selectedValueSatuan!);
                          }
                        },
                        items: items.map((barang) {
                          return DropdownMenuItem<String>(
                            value: barang['id'].toString(), // Simpan ID barang
                            child:
                                Text(barang['name']), // Tampilkan nama barang
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Satuan",
                    style: TextStyle(fontSize: 16),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedValueSatuan,
                        hint: Text("Pilih Satuan"),
                        isExpanded:
                            true, // Agar dropdown mengikuti lebar container
                        icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValueSatuan = newValue;
                          });
                          // Panggil API jika barang sudah dipilih
                          if (selectedValue != null &&
                              selectedValueSatuan != null) {
                            getStock(selectedValue!, selectedValueSatuan!);
                          }
                        },
                        items: satuans.map((String satuan) {
                          return DropdownMenuItem<String>(
                            value: satuan,
                            child: Text(satuan),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextFieldCustom(
              title: "Stock Saat Ini",
              hintText: "0",
              enable: false,
              controller: stockNow,
              icon: Icons.storage,
            ),
            TextFieldCustom(
              controller: stockOut,
              title: "Stock Keluar",
              hintText: "0",
              keyboardType: TextInputType.number,
              enable: true,
              icon: Icons.output,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: GestureDetector(
                onTap: () {
                  if (selectedValue != null &&
                      selectedValueSatuan != null &&
                      stockNow.text != "" &&
                      stockOut.text != "") {
                    if (int.parse(stockNow.text) < int.parse(stockOut.text)) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Gagal"),
                          content: Text("Stock saat ini tidak mencukupi"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("OK"),
                            )
                          ],
                        ),
                      );
                    } else {
                      issuedStock(selectedValue!, int.parse(stockOut.text),
                          selectedValueSatuan!);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Home()));
                    }
                    // print(
                    //     "${selectedValue}, ${selectedValueSatuan}, ${stockOut.text}, ${stockNow.text}");
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Peringatan"),
                        content: Text("Pastikan Semua Field Terisi !"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("OK"),
                          )
                        ],
                      ),
                    );
                  }
                },
                onTapDown: (_) =>
                    setState(() => isPressed = true), // Saat ditekan
                onTapUp: (_) =>
                    setState(() => isPressed = false), // Saat dilepas
                onTapCancel: () =>
                    setState(() => isPressed = false), // Saat dibatalkan
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: MediaQuery.of(context).size.width * 0.5,
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
                    "SUBMIT",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
