import 'package:flutter/material.dart';
import 'package:stock_opname/config.dart';
import 'package:stock_opname/views/Home.dart';
import 'package:stock_opname/widget/textfield.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockIn extends StatefulWidget {
  const StockIn({super.key});

  @override
  State<StockIn> createState() => _StockInState();
}

class _StockInState extends State<StockIn> {
  String? selectedValue;
  String? selectedValueSatuan;
  bool isPressed = false;
  TextEditingController stockNow = TextEditingController();
  TextEditingController stockIn = TextEditingController();

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

  // Fungsi untuk menambah stok
  Future<void> addStock(String idBarang, int quantity, String satuan) async {
    String url = "${Config.baseUrl}/stock"; // Ganti dengan URL API-mu

    // Data yang akan dikirimkan ke API
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

      if (response.statusCode == 200) {
        // Jika request berhasil
        var responseData = jsonDecode(response.body);
        print("Stok berhasil ditambahkan: $responseData");
        // Lakukan sesuatu setelah sukses, misalnya reset field atau beri notifikasi
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text("Stock telah ditambahkan"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Home())),
                child: Text("OK"),
              )
            ],
          ),
        );
      } else {
        // Jika response gagal
        print("Gagal menambah stok");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Gagal"),
            content: Text("Stock telah ditambahkan"),
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
      print("Error saat menambah stok: $e");
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
          "Stock In",
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
              controller: stockIn,
              title: "Stock Masuk",
              hintText: "0",
              keyboardType: TextInputType.number,
              enable: true,
              icon: Icons.input,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: GestureDetector(
                onTap: () {
                  if (selectedValue != null &&
                      selectedValueSatuan != null &&
                      stockIn.text != "") {
                    addStock(selectedValue!, int.parse(stockIn.text),
                        selectedValueSatuan!);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Home()));
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
