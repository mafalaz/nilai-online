import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:penilaian_mahasiswa/models/mahasiswa.dart';
import 'package:penilaian_mahasiswa/screens/login_screen.dart';

class DosenScreen extends StatefulWidget {
  @override
  _DosenScreenState createState() => _DosenScreenState();
}

class _DosenScreenState extends State<DosenScreen> {
  List<Mahasiswa> mahasiswaList = [];
  late File dataFile;
  TextEditingController namaController = TextEditingController();
  TextEditingController nimController = TextEditingController();

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

  Future<void> writeData(Map<String, dynamic> jsonData) async {
    final encodedData = jsonEncode(jsonData);
    await dataFile.writeAsString(encodedData);
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

  void _inputNilai(BuildContext context, Mahasiswa mahasiswa) {
  showDialog(
    context: context,
    builder: (context) {
      final nilaiController = TextEditingController(text: mahasiswa.nilai);

      return AlertDialog(
        title: Text('Input Nilai'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(labelText: 'Nilai'),
                controller: nilaiController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final jsonData = await readData();
              final mahasiswaData = jsonData['mahasiswa'];

              for (var item in mahasiswaData) {
                if (item['nim'] == mahasiswa.nim) {
                  item['nilai'] = nilaiController.text;
                  break;
                }
              }

              await writeData(jsonData);

              fetchMahasiswaList();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}


  void _addMahasiswa(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Siswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Nama'),
              controller: namaController,
              onChanged: (value) {
                setState(() {
                  // Set nama mahasiswa
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'NIS'),
              controller: nimController,
              onChanged: (value) {
                setState(() {
                  // Set NIM mahasiswa
                });
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final jsonData = await readData();
              final mahasiswaData = jsonData['mahasiswa'];

              final newMahasiswa = {
                'nama': namaController.text,
                'nim': nimController.text,
                'nilai': "Mata Pelajaran: 80",
              };

              mahasiswaData.add(newMahasiswa);

              await writeData(jsonData);

              fetchMahasiswaList();

              namaController.clear();
              nimController.clear();

              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteMahasiswa(Mahasiswa mahasiswa) async {
    final jsonData = await readData();
    final mahasiswaData = jsonData['mahasiswa'];

    for (var i = 0; i < mahasiswaData.length; i++) {
      final item = mahasiswaData[i];
      if (item['nim'] == mahasiswa.nim) {
        mahasiswaData.removeAt(i);
        break;
      }
    }

    await writeData(jsonData);

    fetchMahasiswaList();
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
        title: Text('Edit Data dan Nilai Siswa'),
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
              onTap: () => _inputNilai(context, mahasiswa),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteMahasiswa(mahasiswa),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMahasiswa(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
