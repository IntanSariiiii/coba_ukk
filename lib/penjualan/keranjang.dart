import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class produkdetail extends StatefulWidget {
  const produkdetail({super.key});

  @override  
  State<produkdetail> createState() => produkdetailState();
}

class produkdetailState extends State<produkdetail> {
  final SingleValueDropDownController nameController =
      SingleValueDropDownController();
  final SingleValueDropDownController produkController =
      SingleValueDropDownController();
  final TextEditingController quantityController = 
      TextEditingController();
  List myproduct = [];
  List user = [];
  List<Map<String, dynamic>> cart = [];

  // Persentase pajak (misalnya 10%)
  double taxPercentage = 0.10;

  @override  
  void initState() {
    super.initState();
    takeProduct();
    takePelanggan();
  }

  @override  
  void dispose() {
    nameController.dispose();
    produkController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> takeProduct() async {
    try {
      var product = await Supabase.instance.client
        .from('produk')
        .select();
      setState(() {
        myproduct = product;
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> takePelanggan() async {
    try {
      var pelanggan = await Supabase.instance.client
        .from('pelanggan')
        .select();
      setState(() {
        user = pelanggan;
      });
    } catch (e) {
      print('Error fetching customers: $e');
    }
  }

  void tambahproduk() {
    final selectedProduct = produkController.dropDownValue?.value;
    final int quantity = int.tryParse(quantityController.text) ?? 0;

    if (selectedProduct != null && quantity > 0) {
      setState(() {
        cart.add({
          "ProdukID": selectedProduct["ProdukID"],
          "NamaProduk": selectedProduct["NamaProduk"],
          "Harga": selectedProduct["Harga"],
          "jumlah": quantity,
          "Subtotal": (selectedProduct["Harga"] * quantity)
        });
      });
    }
  }

  void showtambahprodukdialog() {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropDownTextField(
                dropDownList: myproduct
                .map((p) => DropDownValueModel(name: p['NamaProduk'], value: p))
                .toList(),
              controller: produkController,
              textFieldDecoration: InputDecoration(labelText: "Pilih Produk"),
              ),
              TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Kembali'),
            ),
            ElevatedButton(
              onPressed: () {
                tambahproduk();
                Navigator.pop(context);
              },
              child: Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  Future<void> executiveSalses() async {
    if (cart.isEmpty || nameController.dropDownValue == null) return;

    var pelangganID = nameController.dropDownValue!.value["PelangganID"];
    num totalHarga = cart.fold(0, (sum, item) => sum + item["Subtotal"]);

    try {
      var penjualan = await Supabase.instance.client
        .from('penjualan')
        .insert([{"PelangganID": pelangganID, "TotalHarga": totalHarga}])
        .select()
        .single();

      if (penjualan.isNotEmpty) {
        for (var item in cart) {
          var response = await Supabase.instance.client
          .from('detailpenjualan')
          .insert([{
            "PenjualanID": penjualan["PenjualanID"],
            "ProdukID": item["ProdukID"],
            "JumlahProduk": item["jumlah"],
            "Subtotal": item["Subtotal"]
          }]);

          await Supabase.instance.client
          .from('produk')
          .update({
            'Stok': item["Stok"] - item["jumlah"]
          })
          .eq('ProdukID', item["ProdukID"]);
        }

        setState(() {
          cart.clear();
        });

        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error executing sales: $e');
    }
  }
  num getTotalHarga() {
    return cart.fold(0, (sum, item) => sum + item["Subtotal"]);
  }

  num getTaxAmount() {
    return getTotalHarga() * taxPercentage;
  }
  num getTotalWithTax() {
    return getTotalHarga() + getTaxAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: Text("Detail Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropDownTextField(
              dropDownList: user
                .map((p) => DropDownValueModel(name: p['NamaPelanggan'], value: p))
                .toList(),
              controller: nameController,
              textFieldDecoration: InputDecoration(labelText: "Pilih Pelanggan"),
            ),
            SizedBox(height: 10),
 
            ElevatedButton(
              onPressed: showtambahprodukdialog,
              child: Text("Tambah Produk"),
            ),
            SizedBox(height: 10),
   
            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return ListTile(
                    title: Text(item["NamaProduk"]),
                    subtitle: Text("Jumlah: ${item["jumlah"]} - Rp${item["Subtotal"]}"),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: executiveSalses,
              child: Text('Transaksi'),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: Rp${getTotalHarga()}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Pajak (10%): Rp${getTaxAmount()}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Total + Pajak: Rp${getTotalWithTax()}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}