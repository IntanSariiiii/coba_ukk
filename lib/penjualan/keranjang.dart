import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/penjualan/indexpenjualan.dart';

class AddTransaksi extends StatefulWidget {
  const AddTransaksi({super.key});

  @override
  State<AddTransaksi> createState() => _AddTransaksiState();
}

class _AddTransaksiState extends State<AddTransaksi> {
  final _tgl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selectedPelanggan;
  String? selectedProduk;
  int jumlahProduk = 1;
  List<Map<String, dynamic>> pelangganList = [];
  List<Map<String, dynamic>> produkList = [];
  List<Map<String, dynamic>> selectedProdukList = [];

  @override
  void initState() {
    super.initState();
    _tgl.text = DateTime.now().toLocal().toString().split(' ')[0]; // Isi otomatis dengan tanggal hari ini
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchPelanggan();
    await fetchProduk();
  }

  Future<void> fetchPelanggan() async {
    final response = await Supabase.instance.client.from('pelanggan').select();
    setState(() {
      pelangganList = List<Map<String, dynamic>>.from(response);
      if (pelangganList.isNotEmpty) {
        selectedPelanggan = pelangganList.first['PelangganID'].toString();
      }
    });
  }

  Future<void> fetchProduk() async {
    final response = await Supabase.instance.client.from('produk').select();
    setState(() {
      produkList = List<Map<String, dynamic>>.from(response);
    });
  }

  void addProduk() {
    if (selectedProduk == null) return;

    final produk = produkList.firstWhere((p) => p['ProdukID'].toString() == selectedProduk);

    // Cek apakah stok cukup
    if (jumlahProduk > produk['Stok']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok ${produk['NamaProduk']} tidak mencukupi!')),
      );
      return;
    }

    setState(() {
      selectedProdukList.add({
        'ProdukID': produk['ProdukID'],
        'NamaProduk': produk['NamaProduk'],
        'JumlahProduk': jumlahProduk,
        'Harga': produk['Harga'],
        'Subtotal': produk['Harga'] * jumlahProduk,
      });
    });
  }

  Future<void> transaksi() async {
    if (_formKey.currentState!.validate() && selectedProdukList.isNotEmpty) {
      final String tanggalPenjualan = _tgl.text.trim();
      final int pelangganID = int.parse(selectedPelanggan!);
      final double totalHarga = selectedProdukList.fold(0, (sum, item) => sum + item['Subtotal']);

      try {
        final response = await Supabase.instance.client.from('penjualan').insert({
          'TanggalPenjualan': tanggalPenjualan,
          'TotalHarga': totalHarga,
          'PelangganID': pelangganID,
        }).select();

        if (response.isNotEmpty) {
          final int penjualanID = response.first['PenjualanID'];

          for (var produk in selectedProdukList) {
            await Supabase.instance.client.from('detailpenjualan').insert({
              'PenjualanID': penjualanID,
              'ProdukID': produk['ProdukID'],
              'JumlahProduk': produk['JumlahProduk'],
              'Subtotal': produk['Subtotal'],
            });

            // Update stok produk
            await Supabase.instance.client.from('produk').update({
              'Stok': produkList.firstWhere((p) => p['ProdukID'] == produk['ProdukID'])['Stok'] - produk['JumlahProduk'],
            }).match({'ProdukID': produk['ProdukID']});
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi berhasil!')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => penjualan()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Penjualan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input Tanggal
              TextFormField(
                controller: _tgl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal Penjualan',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Tanggal tidak boleh kosong' : null,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _tgl.text = pickedDate.toLocal().toString().split(' ')[0];
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Pilih Pelanggan
              DropdownButtonFormField<String>(
                value: selectedPelanggan,
                decoration: InputDecoration(
                  labelText: 'Pilih Pelanggan',
                  border: OutlineInputBorder(),
                ),
                items: pelangganList.map((pelanggan) {
                  return DropdownMenuItem(
                    value: pelanggan['PelangganID'].toString(),
                    child: Text(pelanggan['NamaPelanggan'] ?? 'Tanpa Nama'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedPelanggan = value),
                validator: (value) => value == null ? 'Pilih pelanggan' : null,
              ),
              const SizedBox(height: 16),

              // Dropdown Pilih Produk
              DropdownButtonFormField<String>(
                value: selectedProduk,
                decoration: InputDecoration(
                  labelText: 'Pilih Produk',
                  border: OutlineInputBorder(),
                ),
                items: produkList.map((produk) {
                  return DropdownMenuItem(
                    value: produk['ProdukID'].toString(),
                    child: Text('${produk['NamaProduk']} (Stok: ${produk['Stok']})'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedProduk = value),
                validator: (value) => value == null ? 'Pilih produk' : null,
              ),
              const SizedBox(height: 16),

              // Input Jumlah Produk
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Jumlah Produk',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => jumlahProduk = int.tryParse(value) ?? 1,
              ),
              const SizedBox(height: 16),

              // Tombol Tambah Produk
              ElevatedButton(
                onPressed: addProduk,
                child: const Text('Tambah Produk ke Daftar'),
              ),

              // Daftar Produk yang Dipilih
              Expanded(
                child: ListView.builder(
                  itemCount: selectedProdukList.length,
                  itemBuilder: (context, index) {
                    final produk = selectedProdukList[index];
                    return ListTile(
                      title: Text('${produk['NamaProduk']} (x${produk['JumlahProduk']})'),
                      subtitle: Text('Subtotal: Rp. ${produk['Subtotal'].toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => selectedProdukList.removeAt(index)),
                      ),
                    );
                  },
                ),
              ),

              // Tombol Tambah Transaksi
              ElevatedButton(
                onPressed: transaksi,
                child: const Text('Tambah Transaksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
