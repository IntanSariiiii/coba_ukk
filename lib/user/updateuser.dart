import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/user/indexuser.dart';

class updateuser extends StatefulWidget {
  final int id;

  const updateuser({super.key, required this.id});

  @override
  State<updateuser> createState() => _updateuserState();
}

class _updateuserState extends State<updateuser> {
  final _user = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override 
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      final response = await Supabase.instance.client
          .from('user')
          .select()
          .eq('id', widget.id)
          .single();
      setState(() {
        _user.text = response['username'] ?? '';
        _password.text = response['password']?.toString() ?? '';
      });
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<void> updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Supabase.instance.client.from('user').update({
          'username': _user.text,
          'password': _password.text,
        }).eq('id', widget.id);


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => userregis()),
        );
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update User'),
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
        padding: EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _user,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true, // Password hidden
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: updateUserData,
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