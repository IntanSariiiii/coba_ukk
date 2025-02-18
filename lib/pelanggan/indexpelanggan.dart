import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/pelanggan/insertpelanggan.dart';
import 'package:ukk_2025/pelanggan/updatepelanggan.dart';

class pelanggan extends StatefulWidget {
  @override
  _pelangganState createState() => _pelangganState();
}

class _pelangganState extends State<pelanggan> {
  List<Map<String, dynamic>> pelangganList = [];
  List<Map<String, dynamic>> filteredPelangganList = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchpelanggan();
    searchController.addListener(() {
      filterPelanggan();
    });
  }

  Future<void> fetchpelanggan() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await Supabase.instance.client.from('pelanggan').select();
      setState(() {
        pelangganList = List<Map<String, dynamic>>.from(response);
        filteredPelangganList =
            List.from(pelangganList); // Initial filter is all data
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching pelanggan: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterPelanggan() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredPelangganList = pelangganList.where((pelanggan) {
        String nama = (pelanggan['NamaPelanggan'] ?? '').toLowerCase();
        return nama.contains(query);
      }).toList();
    });
  }

  Future<void> deletepelanggan(int id) async {
    try {
      await Supabase.instance.client
          .from('pelanggan')
          .delete()
          .eq('PelangganID', id);
      fetchpelanggan();
    } catch (e) {
      print('Error deleting pelanggan: $e');
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
                          labelText: 'Cari Pelanggan',
                          labelStyle: TextStyle(color: Colors.black),  // Mengubah warna label menjadi hitam
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredPelangganList.isEmpty
                          ? Center(
                              child: Text(
                                'Tidak ada pelanggan',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(10),
                              itemCount: filteredPelangganList.length,
                              itemBuilder: (context, index) {
                                final langgan = filteredPelangganList[index];
                                return Card(
                                  elevation: 4,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          langgan['NamaPelanggan'] ??
                                              'Pelanggan Tidak Tersedia',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          langgan['Alamat'] ??
                                              'Alamat Tidak Tersedia',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          langgan['NomorTelepon'] ??
                                              'Nomor Telepon Tidak Tersedia',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.justify,
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
                                                final PelangganID =
                                                    langgan['PelangganID'] ?? 0;
                                                if (PelangganID != 0) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditPelanggan(
                                                                  PelangganID:
                                                                      PelangganID)));
                                                } else {
                                                  print(
                                                      'ID Pelanggan Tidak Valid');
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
                                                            'Hapus Pelanggan'),
                                                        content: const Text(
                                                            'Apakah Anda yakin ingin menghapus pelanggan ini?'),
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
                                                              deletepelanggan(
                                                                  langgan[
                                                                      'PelangganID']);
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
                      MaterialPageRoute(builder: (context) => AddPelanggan()),
                    );
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.white,
                )
              )
            )
          );
  }
}