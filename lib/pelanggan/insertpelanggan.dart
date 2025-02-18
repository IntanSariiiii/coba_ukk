import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/homepage.dart';

class AddPelanggan extends StatefulWidget {
  const AddPelanggan({super.key});

  @override
  State<AddPelanggan> createState() => _AddPelangganState();
}

class _AddPelangganState extends State<AddPelanggan> {
  final _nmplg = TextEditingController();
  final _alamat = TextEditingController();
  final _notlp = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> planggan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String NamaPelanggan = _nmplg.text;
      final String Alamat = _alamat.text;
      final String NomorTelepon = _notlp.text;

      try {
        final response = await Supabase.instance.client.from('pelanggan').insert([
          {
            'NamaPelanggan': NamaPelanggan,
            'Alamat': Alamat,
            'NomorTelepon': NomorTelepon,
          }
        ]);

        setState(() {
          _isLoading = false;
        });

        if (response == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        if (error is PostgrestException && error.code == '23505') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nama pelanggan ini sudah terdaftar'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Pelanggan',
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
                    return 'Nama pelanggan tidak boleh kosong';
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
                    return 'Nomor tidak boleh kosong';
                  } else {
                    if (double.tryParse(value) == null) {
                      return 'Nomor telepon harus berupa angka';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.center,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : ElevatedButton(
                        onPressed: planggan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple, // Warna ungu
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text(
                          'Tambah',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
