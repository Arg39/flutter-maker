import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maker/components/button_navigation.dart';
import 'package:heroicons/heroicons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Asset {
  final int id;
  final int idDriver;
  final String jenisKendaraan;
  final String driverName;
  final DateTime expiredStnk;
  final String status;

  Asset({
    required this.id,
    required this.idDriver,
    required this.jenisKendaraan,
    required this.driverName,
    required this.expiredStnk,
    required this.status,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] ?? 0,
      idDriver: json['id_driver'] ?? 0,
      jenisKendaraan: json['jenis_kendaraan'] ?? '',
      driverName: json['nama_driver'] ?? '',
      expiredStnk: DateTime.parse(json['expired_stnk'] ?? ''),
      status: json['status'] ?? '',
    );
  }
}

class ApiService {
  final String baseUrl = 'https://salmon-magpie-708343.hostingersite.com';

  Future<List<Asset>> fetchAssetsRejectedOrAccepted(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/assets-rejected-or-accepted'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['data'] != null) {
        final assetsData = responseBody['data'] as List;
        return assetsData.map((asset) => Asset.fromJson(asset)).toList();
      } else {
        print('Response body: ${response.body}');
        throw Exception('No data found');
      }
    } else {
      print('Response body: ${response.body}');
      throw Exception('Failed to load assets');
    }
  }
}

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _active = 'notification';
  late ApiService apiService;
  String? token;
  List<Asset> assets = [];

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token != null) {
      try {
        final fetchedAssets =
            await apiService.fetchAssetsRejectedOrAccepted(token!);
        setState(() {
          assets = fetchedAssets;
        });
      } catch (e) {
        print('Failed to load assets: $e');
      }
    } else {
      print('Token not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          final now = DateTime.now();
          final difference = asset.expiredStnk.difference(now).inDays;

          bool isExpiringSoon = difference == 1;
          bool isExpired = difference < 0;
          bool isAccepted = asset.status == 'accepted';
          bool isRejected = asset.status == 'rejected';

          return Card(
            color: isAccepted
                ? Colors.green[100]
                : (isRejected ? Colors.red[100] : Colors.white),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.jenisKendaraan,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000B58),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          asset.driverName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF000B58),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        if (isRejected)
                          Text(
                            'Pengajuan ditolak!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (isAccepted)
                          Text(
                            'Pengajuan diterima!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isRejected)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF000B58),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: HeroIcon(HeroIcons.pencil,
                              color: Colors.white, size: 26),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/editAsset',
                              arguments: asset.id,
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigation(
        active: _active,
      ),
    );
  }
}
