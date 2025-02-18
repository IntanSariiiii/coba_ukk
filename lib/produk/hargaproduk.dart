import 'package:flutter/material.dart';
import 'package:ukk_2025/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdukDetatailPage extends StatefulWidget {
  final Map<String, dynamic> produk;
  const ProdukDetatailPage({Key? key, required this.produk}) : super(key: key);

  @override
  _ProdukDetailPageState createState() => _ProdukDetailPageState();

}

class ProdukDetailPage extends StatefulWidget {
  final Map<String, dynamic> produk;
  const ProdukDetailPage({Key? key, required this.produk}) : super(key: key);

  @override
  _ProdukDetailPageState createState() => _ProdukDetailPageState();
}

class _ProdukDetailPageState extends State<ProdukDetailPage> {
  int jumlahPesanan = 0;
  int totalHarga = 0;
  int stokakhir = 0;
  int stokawal = 0;

  // Fungsi untuk memperbarui jumlah pesanan
  void updateJumlahPesanan(int harga, int delta) {
    setState(() {
      stokakhir = stokawal - delta;
      if (stokakhir < 0) stokakhir = 0; 
      jumlahPesanan += delta;
      if (jumlahPesanan < 0) jumlahPesanan = 0; // Tidak boleh negatif
      totalHarga = jumlahPesanan * harga;
      if (totalHarga < 0) totalHarga = 0; // Tidak boleh negatif
    });
  }

  // Fungsi untuk menyimpan data ke tabel detailpenjualan
  Future<void> insertDetailPenjualan(int produkid, int penjualanid, int jumlahPesanan, int totalHarga) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('detailpenjualan').insert({
        'produkid': produkid,
        'penjualanid': penjualanid,
        'JumlahProduk': jumlahPesanan,
        'Subtotal': totalHarga,
      });

      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil disimpan!')),
        );
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    } catch (e) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final produk = widget.produk;
    final harga = produk['harga'] ?? 0;
    final produkid = produk['produkid'] ?? 0;
    final penjualanid = 1; // Contoh ID Penjualan (harus diganti sesuai logika Anda)

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: Colors.pink.shade300,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama Produk: ${produk['namaproduk'] ?? 'Tidak Tersedia'}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  Text('harga: $harga', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  Text('stok: ${produk['Stok'] ?? 'Tidak Tersedia'}', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          updateJumlahPesanan(harga, -1);
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        '$jumlahPesanan',
                        style: const TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        onPressed: () {
                          updateJumlahPesanan(harga, 1);
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup', style: TextStyle(fontSize: 20)),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          if (jumlahPesanan > 0) {
                            await insertDetailPenjualan(
                              produkid,
                              penjualanid,
                              jumlahPesanan,
                              totalHarga,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Jumlah pesanan harus lebih dari 0')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade300,
                        ),
                        child: Text('Pesan ($totalHarga)', style: const TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
