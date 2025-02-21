import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/penjualan/keranjang.dart';
import 'package:ukk_2025/penjualan/detailpenjualan.dart';

class penjualan extends StatefulWidget {
  const penjualan({super.key});

  @override
  State<penjualan> createState() => _PenjualanState();
}

class _PenjualanState extends State<penjualan> {
  List<Map<String, dynamic>> penjualan = [];
  bool isLoading = true;

  double taxPercentage = 10.0;

  num getTaxAmount(int totalHarga) {
    return totalHarga * taxPercentage / 100;
  }

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
      await Supabase.instance.client.from('penjualan').delete().eq('PenjualanID', id);
      fetchPenjualan();
    } catch (e) {
      print('Error deleting penjualan: $e');
    }
  }

  void printReceipt(Map<String, dynamic> item) {
    print("Struk Penjualan");
    print("Pelanggan: ${item['pelanggan']['NamaPelanggan']}");
    print("Total Harga: Rp. ${getTotalWithTax(item['TotalHarga']).toStringAsFixed(2)}");
    print("Terima kasih telah berbelanja!");
  }

  @override
  void initState() {
    super.initState();
    fetchPenjualan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Penjualan"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8D3FF), Color(0xFF4B224E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: penjualan.length,
                itemBuilder: (context, index) {
                  final item = penjualan[index];
                  final int totalHarga = item['TotalHarga'] ?? 0;
                  final totalWithTax = getTotalWithTax(totalHarga);

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['pelanggan']['NamaPelanggan'] ?? 'Pelanggan',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text('Total: Rp. ${totalWithTax.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16, color: Colors.black54)),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPenjualanPage(
                                        penjualanId: item['PenjualanID'],
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Detail'),
                              ),
                              // IconButton(
                              //   icon: Icon(Icons.print, color: Colors.blue),
                              //   onPressed: () {
                              //     printReceipt(item);
                              //   },
                              // ),
                              // IconButton(
                              //   icon: Icon(Icons.delete, color: Colors.red),
                              //   onPressed: () {
                              //     showDialog(
                              //       context: context,
                              //       builder: (BuildContext context) {
                              //         return AlertDialog(
                              //           title: const Text('Hapus Penjualan'),
                              //           content: const Text('Apakah Anda yakin ingin menghapus penjualan ini?'),
                              //           actions: [
                              //             TextButton(
                              //               onPressed: () => Navigator.pop(context),
                              //               child: const Text('Batal'),
                              //             ),
                              //             TextButton(
                              //               onPressed: () {
                              //                 deletePenjualan(item['PenjualanID']);
                              //                 Navigator.pop(context);
                              //                 setState(() {
                              //                   penjualan.removeAt(index);
                              //                 });
                              //               },
                              //               child: const Text('Hapus'),
                              //             ),
                              //           ],
                              //         );
                              //       },
                              //     );
                              //   },
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPenjualan = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddTransaksi()),
          );

          if (newPenjualan != null) {
            fetchPenjualan();
          }
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
