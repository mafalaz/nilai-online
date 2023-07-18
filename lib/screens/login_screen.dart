import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:penilaian_mahasiswa/models/user.dart';
import 'package:penilaian_mahasiswa/screens/mahasiswa_screen.dart';
import 'package:penilaian_mahasiswa/screens/dosen_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<Map<String, dynamic>> readData() async {
    final String data = await rootBundle.loadString('assets/data.json');
    final jsonData = jsonDecode(data);

    return jsonData;
  }

  Future<User?> _login(String username, String password) async {
    final data = await readData();

    final users = data['users'] ?? [];
    for (var user in users) {
      if (user['username'] == username && user['password'] == password) {
        return User.fromJson(user);
      }
    }
    return null;
  }

  void _onLoginButtonPressed() async {
    final username = usernameController.text;
    final password = passwordController.text;
    final user = await _login(username, password);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            if (user.role == 'dosen') {
              return DosenScreen();
            } else if (user.role == 'mahasiswa') {
              return MahasiswaScreen();
            } else {
              return Container();
            }
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Failed'),
          content: Text('Invalid username or password.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Login'),
    ),
    body: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Selamat datang di aplikasi Nilai Online, silahkan login menggunakan akun sebagai Guru atau Orang tua',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
            ),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _onLoginButtonPressed,
            child: Text('Login'),
          ),
        ],
      ),
    ),
  );
}
}
