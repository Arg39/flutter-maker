import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maker/components/button_navigation.dart';
import 'package:maker/pages/assetDetail.dart';
import 'package:maker/services/api_view_asset.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maker/components/asset_card.dart';
import 'package:maker/components/error_message.dart';

class VerifyAssetPage extends StatefulWidget {
  @override
  _VerifyAssetPageState createState() => _VerifyAssetPageState();
}

class _VerifyAssetPageState extends State<VerifyAssetPage> {
  String _active = 'verifyAssets';
  late ApiService apiService;
  String? token;
  String? username;
  int? userId;
  String? role;
  String? _errorMessage;
  Color _errorColor = Colors.red;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenString = prefs.getString('token') ?? '';
    final userDataString = prefs.getString('userData');

    if (userDataString != null && tokenString.isNotEmpty) {
      final userData = jsonDecode(userDataString);
      setState(() {
        token = tokenString;
        username = userData['username'] ?? '';
        userId = userData['id'] ?? 0;
        role = userData['role'] ?? '';
      });
    }
  }

  Future<List> fetchAssets() async {
    if (token == null || username == null || userId == null || role == null) {
      throw Exception('User data not found');
    }

    if (role == 'koordinator') {
      return await apiService.fetchNotVerifiedAssets(token!);
    } else if (role == 'inspektor') {
      return await apiService.fetchAssetsVerifiedByKoordinator(token!);
    } else {
      throw Exception('Invalid role');
    }
  }

  void _showError(String message, Color color) {
    setState(() {
      _errorMessage = message;
      _errorColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
              title: Center(
                child: Text(
                  'Daftar Aset',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            if (_errorMessage != null)
              ErrorMessage(
                message: _errorMessage!,
                onClose: () {
                  setState(() {
                    _errorMessage = null;
                  });
                },
                color: _errorColor,
              ),
            Expanded(
              child: FutureBuilder<List>(
                future: fetchAssets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No assets available'));
                  }

                  final assets = snapshot.data!;
                  return GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Menentukan jumlah kolom dalam grid
                      childAspectRatio:
                          1.1, // Menurunkan nilai untuk membuat kartu lebih tinggi
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: assets.length,
                    itemBuilder: (context, index) {
                      final asset = assets[index];
                      return AssetCard(
                        asset: asset,
                        onError: _showError,
                      ); // Menggunakan kartu asset yang telah dimodifikasi
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        active: _active,
      ),
    );
  }
}
