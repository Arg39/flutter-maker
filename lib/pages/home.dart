import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maker/components/button_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? userData;
  String _active = 'home';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');

    if (userDataString != null) {
      setState(() {
        userData = jsonDecode(userDataString);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFEFE),
      body: SafeArea(
        child: userData != null
            ? SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/illustration-for-home.png',
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Hi, ${userData!['name']}!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Selamat datang di aplikasi Maker! Tingkatkan efisiensi dan kemudahan dalam manajemen aset kendaraan Anda. Nikmati pengalaman terbaik bersama kami!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 32),
                    // Konten lain di halaman home
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: BottomNavigation(
        active: _active,
      ),
    );
  }
}
