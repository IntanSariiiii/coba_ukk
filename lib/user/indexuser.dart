import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/user/insertuser.dart';
import 'package:ukk_2025/user/updateuser.dart';

class userregis extends StatefulWidget {
  const userregis({super.key});

  @override
  State<userregis> createState() => _userregisState();
}

class _userregisState extends State<userregis> {
  List<Map<String, dynamic>> user = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchuser();
  }

  Future<void> deleteuser(int id) async {
    try {
      await Supabase.instance.client.from('user').delete().eq('id', id);
      fetchuser();
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> fetchuser() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Supabase.instance.client.from('user').select();
      setState(() {
        user = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('List User'),
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: isLoading
          ? Center(
              child: LoadingAnimationWidget.twoRotatingArc(
                  color: Colors.grey, size: 30),
            )
          : user.isEmpty
              ? Center(
                  child: const Text(
                    'User belum ditambahkan',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(10),
                      color: Colors.blue[35],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: const [
                            Expanded(
                                flex: 2,
                                child: Text('Username',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Password',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 1,
                                child: Text('Aksi',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: user.length,
                            itemBuilder: (context, index) {
                              final userdata = user[index];
                              return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                                userdata['username'] ?? '')),
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                                userdata['password'] ?? '')),
                                        Spacer(),
                                        IconButton(
                                            onPressed: () {
                                              final id = userdata['id'] ?? 0;
                                              if (id != 0) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            updateuser(
                                                                id: id)));
                                              }
                                            },
                                            icon: const Icon(Icons.edit,
                                                color: Colors.grey)),
                                        IconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Hapus user'),
                                                      content: const Text(
                                                          'Apakah anda yakin menghapus user?'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                'Batal')),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              deleteuser(
                                                                  userdata[
                                                                      'id']);
                                                            },
                                                            child: const Text(
                                                                'Hapus'))
                                                      ],
                                                    );
                                                  });
                                            },
                                            icon: const Icon(Icons.delete,
                                                color: Colors.blue)),
                                      ],
                                    ),
                                  ));
                            }))
                  ],
                ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => userinsert()));
      },
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add),
    ),
  );
}
}