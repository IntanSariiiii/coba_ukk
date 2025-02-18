import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/homepage.dart';

class PenjualanUpdate extends StatefulWidget {
  final int PelangganID;

  const PenjualanUpdate({super.key, required this.PelangganID});

  @override
  State<PenjualanUpdate> createState() => _PenjualanUpdateState();
}

class _PenjualanUpdateState extends State<PenjualanUpdate> {
  final _tglController = TextEditingController();
  final _hrgController = TextEditingController();
  final _pelangganController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadPenjualanData();
  }

  Future<void> _loadPenjualanData() async {
    try {
      final data = await Supabase.instance.client
          .from('penjualan')
          .select()
          .eq('PelangganID', widget.PelangganID)
          .single();

      setState(() {
        _tglController.text = data['TanggalPenjualan'] ?? '';
        _hrgController.text = data['Harga']?.toString() ?? '';
        _pelangganController.text = data['PelangganID'] ?? '';
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $error')),
      );
    }
  }
 
  Future<void> _updatePenjualan() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Supabase.instance.client.from('penjualan').update({
          'TanggalPenjualan': _tglController.text,
          'Harga': double.tryParse(_hrgController.text) ?? 0,
          'PelangganID': _pelangganController.text,
        }).eq('PelangganID', widget.PelangganID);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating data: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tglController.dispose();
    _hrgController.dispose();
    _pelangganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Penjualan'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _tglController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Penjualan',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal Penjualan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _hrgController,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _pelangganController,
                decoration: InputDecoration(
                  labelText: 'Pelanggan ID',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pelanggan ID tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updatePenjualan,
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
      )
    );
  }
}