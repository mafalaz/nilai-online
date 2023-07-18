import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:penilaian_mahasiswa/models/mahasiswa.dart';
import 'package:penilaian_mahasiswa/screens/login_screen.dart';

class MahasiswaScreen extends StatefulWidget {
  @override
  _MahasiswaScreenState createState() => _MahasiswaScreenState();
}

class _MahasiswaScreenState extends State<MahasiswaScreen> {
  List<Mahasiswa> mahasiswaList = [];
  late File dataFile;

  Future<void> initializeDataFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/data.json';
    dataFile = File(path);

    // Jika file data.json belum ada, salin file dari folder assets
    if (!dataFile.existsSync()) {
      final assetData = await rootBundle.loadString('assets/data.json');
      await dataFile.writeAsString(assetData);
    }
  }

  Future<Map<String, dynamic>> readData() async {
    final data = await dataFile.readAsString();
    final jsonData = jsonDecode(data);
    return jsonData;
  }

  Future<void> fetchMahasiswaList() async {
    final data = await readData();
    final mahasiswaData = data['mahasiswa'] ?? [];

    setState(() {
      mahasiswaList = mahasiswaData
          .map<Mahasiswa>((json) => Mahasiswa.fromJson(json))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDataFile().then((_) {
      fetchMahasiswaList();
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data dan Nilai Siswa'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: mahasiswaList.length,
        itemBuilder: (context, index) {
          final mahasiswa = mahasiswaList[index];
          return Card(
            child: ListTile(
              title: Text(mahasiswa.nama),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NIS: ${mahasiswa.nim}'),
                  Divider(), // Tambahkan pemisah antar data mahasiswa
                  Text('Nilai: \n${mahasiswa.nilai}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
