import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/homepage.dart';

class EditPelanggan extends StatefulWidget {
  final int PelangganID;

  const EditPelanggan({super.key, required this.PelangganID});

  @override
  State<EditPelanggan> createState() => _EditPelangganState();
}

class _EditPelangganState extends State<EditPelanggan> {
  final _nmplg = TextEditingController();
  final _alamat = TextEditingController();
  final _notlp = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadPelangganData();
  }

  Future<void> _loadPelangganData() async {
    final data = await Supabase.instance.client
        .from('pelanggan')
        .select()
        .eq('PelangganID', widget.PelangganID)
        .single();

    setState(() {
      _nmplg.text = data['NamaPelanggan'] ?? '';
      _alamat.text = data['Alamat'] ?? '';
      _notlp.text = data['NomorTelepon'] ?? '';
    });
  }

  Future<void> updatePelanggan() async {
    if (_formKey.currentState!.validate()) {
      await Supabase.instance.client.from('pelanggan').update({
        'NamaPelanggan': _nmplg.text,
        'Alamat': _alamat.text,
        'NomorTelepon': _notlp.text,
      }).eq('PelangganID', widget.PelangganID);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Pelanggan',
          style: TextStyle(color: Colors.purple), // Warna ungu
        ),
        iconTheme: const IconThemeData(color: Colors.purple), // Ikon warna ungu
        backgroundColor: Colors.white, // Latar belakang putih
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Menjaga form tetap di atas
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nmplg,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pelanggan',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alamat,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notlp,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32), // Jarak sebelum tombol Update
                Align( // Menempatkan tombol Update di tengah
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: updatePelanggan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, // Warna ungu
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
