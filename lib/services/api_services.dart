// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stock_opname/config.dart';

class ApiService {
  // Fungsi untuk mendapatkan stok
  static Future<Map<String, dynamic>> getStock(
      String idBarang, String satuan) async {
    String url =
        "${Config.baseUrl}/stock/get_stock?barang=$idBarang&satuan=$satuan"; // Sesuaikan dengan API-mu

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.containsKey('response') && data['response'] != null) {
          return data['response']; // Kembalikan data stok
        } else {
          return {}; // Kembalikan data kosong jika tidak ada stok
        }
      } else {
        print("Gagal mengambil stock barang.");
        return {};
      }
    } catch (e) {
      print("Error saat mengambil stock: $e");
      return {};
    }
  }

  // Fungsi untuk menambah stok
  static Future<void> addStock(
      String idBarang, int quantity, String satuan) async {
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
      } else {
        print("Gagal menambah stok");
      }
    } catch (e) {
      print("Error saat menambah stok: $e");
    }
  }

  static Future<List<dynamic>> getBarang() async {
    String url = "${Config.baseUrl}/barang"; // Sesuaikan dengan API-mu

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data.containsKey('response') && data['response'] is List) {
          return data['response']; // Kembalikan daftar barang
        } else {
          print("Format data API tidak sesuai.");
          return []; // Jika format tidak sesuai, kembalikan list kosong
        }
      } else {
        print("Barang tidak ditemukan !!!");
        return []; // Kembalikan list kosong jika request gagal
      }
    } catch (e) {
      print("Error saat get barang: $e");
      return []; // Pastikan selalu ada nilai yang dikembalikan
    }
  }
}
