import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/penjualan/keranjang.dart';


class penjualan extends StatefulWidget {
  const penjualan({super.key});

  @override
  State<penjualan> createState() => _penjualanState();
}

class _penjualanState extends State<penjualan> {
  List<Map<String, dynamic>> penjualan = [];
  bool isLoading = true;

  double taxPercentage = 10.0; // Persentase pajak

  // Fungsi untuk menghitung pajak dari total harga
  num getTaxAmount(int totalHarga) {
    return totalHarga * taxPercentage / 100;
  }

  // Fungsi untuk menghitung total harga setelah pajak
  num getTotalWithTax(int totalHarga) {
    return totalHarga + getTaxAmount(totalHarga);
  }

  fetchPenjualan() async {
    try {
      final response = await Supabase.instance.client
          .from('penjualan')
          .select('*, pelanggan(*)');
      setState(() {
        penjualan = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching penjualan: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deletePenjualan(int id) async {
    try {
      await Supabase.instance.client
          .from('penjualan')
          .delete()
          .eq('PenjualanID', id);
      fetchPenjualan();
    } catch (e) {
      print('Error deleting penjualan: $e');
    }
  }

  @override
  initState() {
    super.initState();
    fetchPenjualan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: penjualan.length,
                itemBuilder: (context, index) {
                  final item = penjualan[index];
                  final int totalHarga = item['TotalHarga'] ?? 0;
                  final taxAmount = getTaxAmount(totalHarga); 
                  final totalWithTax = getTotalWithTax(totalHarga);

                  return ListTile(
                    title: Text(item['pelanggan']['NamaPelanggan'] ?? 'Pelanggan'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text('Total Harga: Rp. ${totalHarga}'),  // Menampilkan total harga asli (sebelum pajak)
                        // // Menambahkan informasi pajak dan total harga setelah pajak (jika ingin)
                        // Text('Pajak: Rp. ${taxAmount.toStringAsFixed(2)}'), // Menampilkan jumlah pajak
                        Text('Total dengan Pajak: Rp. ${totalWithTax.toStringAsFixed(2)}'), // Menampilkan total setelah pajak
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Hapus Penjualan'),
                              content: const Text('Apakah Anda yakin ingin menghapus penjualan ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deletePenjualan(item['PenjualanID']);
                                    Navigator.pop(context);
                                    setState(() {
                                      penjualan.removeAt(index);
                                    });
                                  },
                                  child: const Text('Hapus'),
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var sales = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => produkdetail()),
          );

          if (sales == true) {
            fetchPenjualan();
          }
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}