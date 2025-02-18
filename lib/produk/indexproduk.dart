import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/produk/insertproduk.dart';
import 'package:ukk_2025/produk/updateproduk.dart';

class produk extends StatefulWidget {
  const produk({super.key});

  @override
  State<produk> createState() => _produkState();
}

class _produkState extends State<produk> {
  List<Map<String, dynamic>> produk = [];
  List<Map<String, dynamic>> filteredProduk = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchproduk();
    searchController.addListener(() {
      filterProduk();
    });
  }

  Future<void> fetchproduk() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await Supabase.instance.client.from('produk').select();
      setState(() {
        produk = List<Map<String, dynamic>>.from(response);
        filteredProduk = produk; // Initial filter is all data
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching produk: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterProduk() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredProduk = produk.where((prod) {
        String namaProduk = (prod['NamaProduk'] ?? '').toLowerCase();
        return namaProduk.contains(query);
      }).toList();
    });
  }

  Future<void> deleteproduk(int id) async {
    try {
      await Supabase.instance.client
          .from('produk')
          .delete()
          .eq('ProdukID', id);
      fetchproduk();
    } catch (e) {
      print('Error deleting produk: $e');
    }
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
            ? Center(
                child: LoadingAnimationWidget.twoRotatingArc(
                    color: Colors.grey, size: 30),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Cari Produk',
                        labelStyle: TextStyle(color: Colors.black),  // Mengubah warna label menjadi hitam
                        prefixIcon: Icon(Icons.search, color: Colors.black),  // Mengubah warna ikon kaca pembesar menjadi hitam
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: filteredProduk.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada produk',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(10),
                            itemCount: filteredProduk.length,
                            itemBuilder: (context, index) {
                              final prd = filteredProduk[index];
                              return Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prd['NamaProduk'] ??
                                            'Nama Tidak Tersedia',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Harga: Rp${prd['Harga']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '${prd['Stok']} pcs',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              final ProdukID =
                                                  prd['ProdukID'] ?? 0;
                                              if (ProdukID != 0) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Editproduk(
                                                                ProdukID:
                                                                    ProdukID)));
                                              } else {
                                                print('ID produk tidak valid');
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Hapus Produk'),
                                                      content: const Text(
                                                          'Apakah Anda yakin ingin menghapus produk ini?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: const Text(
                                                              'Batal'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            deleteproduk(
                                                                prd['ProdukID']);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Text(
                                                              'Hapus'),
                                                        )
                                                      ],
                                                    );
                                                  });
                                            },
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => insertproduk()),
              );
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
