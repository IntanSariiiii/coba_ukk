import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/user/indexuser.dart';

class userinsert extends StatefulWidget {
  const userinsert({super.key});

  @override
  State<userinsert> createState() => _UserInsertState();
}

class _UserInsertState extends State<userinsert> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final TextEditingController _roleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> insertUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final username = _usernameController.text.trim();
        final password = _passwordController.text.trim();
        // final role = _roleController.text.trim();

        final response = await Supabase.instance.client.from('user').insert({
          'username': username,
          'password': password,
          // 'role': role,
        });

        if (response == null) {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => userregis()),
          );
        } else {
          Navigator.pushReplacement(context, 
          MaterialPageRoute(builder: (context) => userregis())
          );
        }
      } catch (e) {
        Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (context) => userregis())
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), 
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              // const SizedBox(height: 16),
              // TextFormField(
              //   controller: _roleController,
              //   decoration: const InputDecoration(
              //     labelText: 'Role',
              //     border: OutlineInputBorder(),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Role tidak boleh kosong';
              //     }
              //     return null;
              //   },
              // ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: insertUser,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}