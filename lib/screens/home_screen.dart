import 'package:flutter/material.dart';
// import '../services/storage_service.dart'; // sementara dikomen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> dummyNovels = ['Novel A', 'Novel B', 'Novel C'];
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lexicon Novel"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: dummyNovels.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(dummyNovels[i]),
                subtitle: Text("Klik untuk lihat detail"),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Detail ${dummyNovels[i]}")),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Form tambah novel dibuka')),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
