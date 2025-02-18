
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class coba extends StatefulWidget {
  const coba({super.key});

  @override
  State<coba> createState() => _cobaState();
}

class _cobaState extends State<coba> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: Text('coba'),),
    );
  }
}