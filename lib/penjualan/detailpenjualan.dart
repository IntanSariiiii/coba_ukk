import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DetailPenjualanPage extends StatefulWidget {
  final int penjualanId;

  const DetailPenjualanPage({super.key, required this.penjualanId});

  @override
  _DetailPenjualanPageState createState() => _DetailPenjualanPageState();
}

class _DetailPenjualanPageState extends State<DetailPenjualanPage> {
  List<Map<String, dynamic>> detailPenjualan = [];
  bool isLoading = true;
  String namaPelanggan = "";
  String tanggalPenjualan = "";

  @override
  void initState() {
    super.initState();
    fetchDetailPenjualan();
  }

  Future<void> fetchDetailPenjualan() async {
    try {
      final response = await Supabase.instance.client
          .from('detailpenjualan')
          .select('''
            *, 
            penjualan(TanggalPenjualan, pelanggan(NamaPelanggan)), 
            produk(NamaProduk)
          ''')
          .eq('PenjualanID', widget.penjualanId);

      if (response.isNotEmpty) {
        setState(() {
          detailPenjualan = List<Map<String, dynamic>>.from(response);
          namaPelanggan = response[0]['penjualan']['pelanggan']['NamaPelanggan'] ?? "Tidak Diketahui";
          tanggalPenjualan = response[0]['penjualan']['TanggalPenjualan'] ?? "Tidak Diketahui";
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching detail penjualan: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> cetakStruk() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Struk Penjualan", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Nama Pelanggan: $namaPelanggan"),
              pw.Text("Tanggal: $tanggalPenjualan"),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ["Nama Produk", "Jumlah", "Subtotal"],
                data: detailPenjualan.map((detail) {
                  return [
                    detail['produk']['NamaProduk'] ?? "Produk Tidak Diketahui",
                    detail['JumlahProduk'].toString(),
                    "Rp ${detail['Subtotal'].toStringAsFixed(2)}"
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Terima kasih telah berbelanja!", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

    // Menampilkan Snackbar saat cetak berhasil
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Struk berhasil dicetak")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Penjualan #${widget.penjualanId}"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: cetakStruk,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : detailPenjualan.isEmpty
              ? Center(child: Text("Tidak ada data detail penjualan."))
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Nama Pelanggan: $namaPelanggan",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                              Text("Tanggal: $tanggalPenjualan", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: detailPenjualan.length,
                        itemBuilder: (context, index) {
                          final detail = detailPenjualan[index];

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: Icon(Icons.shopping_bag, color: Colors.deepPurple),
                              title: Text(detail['produk']['NamaProduk'] ?? "Produk Tidak Diketahui",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Jumlah: ${detail['JumlahProduk']}"),
                                  Text("Subtotal: Rp ${detail['Subtotal'].toStringAsFixed(2)}",
                                      style: TextStyle(color: Colors.deepPurple)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
