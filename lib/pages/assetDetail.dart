import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maker/components/button_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';

class AssetDetailPage extends StatefulWidget {
  final int assetId;

  AssetDetailPage({required this.assetId});

  @override
  _AssetDetailPageState createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  late Future<Asset> asset;
  final String _active = 'viewAssets';

  @override
  void initState() {
    super.initState();
    asset = fetchAssetDetail(widget.assetId);
  }

  Future<Asset> fetchAssetDetail(int assetId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse(
          'https://salmon-magpie-708343.hostingersite.com/api/assets/$assetId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);
        final asset = Asset.fromJson(jsonResponse['data']);
        return asset;
      } catch (e) {
        throw Exception('Failed to parse asset data: $e');
      }
    } else {
      throw Exception('Failed to load asset');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF000B58),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 16),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        title: Text(
          "Detail Aset",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000B58),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<Asset>(
          future: asset,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No asset data available'));
            }

            final asset = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  _buildDetailField('Jenis Kendaraan', asset.jenisKendaraan),
                  SizedBox(height: 16),
                  _buildDetailField('Plat Nomor', asset.platNomor),
                  SizedBox(height: 16),
                  _buildDetailField('Nama Driver', asset.driverName),
                  SizedBox(height: 16),
                  _buildDetailField(
                      'Expired STNK',
                      DateFormat('d MMMM yyyy')
                          .format(DateTime.parse(asset.expiredStnk))),
                  SizedBox(height: 16),
                  _buildImageField('STNK', asset.imageStnk),
                  SizedBox(height: 16),
                  _buildDetailField(
                      'Expired KIR',
                      DateFormat('d MMMM yyyy')
                          .format(DateTime.parse(asset.expiredKier))),
                  SizedBox(height: 16),
                  _buildImageField('KIR', asset.imageKier),
                  SizedBox(height: 16),
                  _buildDetailField(
                      'Expired Pajak',
                      DateFormat('d MMMM yyyy')
                          .format(DateTime.parse(asset.expiredPajak))),
                  SizedBox(height: 16),
                  _buildImageField('Pajak', asset.imagePajak),
                  SizedBox(height: 16),
                  _buildDetailField(
                      'Expired Tagging',
                      DateFormat('d MMMM yyyy')
                          .format(DateTime.parse(asset.expiredTagging))),
                  SizedBox(height: 16),
                  _buildImageField('Tagging', asset.imageTagging),
                  SizedBox(height: 16),
                  _buildImageField('Gambar Depan', asset.imageFront),
                  SizedBox(height: 16),
                  _buildImageField('Gambar Belakang', asset.imageBack),
                  SizedBox(height: 16),
                  _buildImageField('Gambar Kanan', asset.imageRight),
                  SizedBox(height: 16),
                  _buildImageField('Gambar Kiri', asset.imageLeft),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        active: _active,
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF006A67))),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(0xFF006A67),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildImageField(String label, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF006A67))),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showImageDialog(imageUrl),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF006A67), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "Klik gambar untuk melihat lebih detail",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: PhotoViewGallery.builder(
            itemCount: 1,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(color: Colors.black),
            pageController: PageController(),
          ),
        ),
      ),
    );
  }
}

class Asset {
  final int id;
  final int idDriver;
  final String jenisKendaraan;
  final String platNomor;
  final String expiredStnk;
  final String expiredKier;
  final String expiredPajak;
  final String expiredTagging;
  final String imageStnk;
  final String imageKier;
  final String imagePajak;
  final String imageTagging;
  final String imageFront;
  final String imageBack;
  final String imageLeft;
  final String imageRight;
  final String driverName;
  final String createdAt;
  final String updatedAt;
  final bool isVerifiedByKoordinator;
  final bool isVerifiedByInspektor;

  Asset({
    required this.id,
    required this.idDriver,
    required this.jenisKendaraan,
    required this.platNomor,
    required this.expiredStnk,
    required this.expiredKier,
    required this.expiredPajak,
    required this.expiredTagging,
    required this.imageStnk,
    required this.imageKier,
    required this.imagePajak,
    required this.imageTagging,
    required this.imageFront,
    required this.imageBack,
    required this.imageLeft,
    required this.imageRight,
    required this.driverName,
    required this.createdAt,
    required this.updatedAt,
    required this.isVerifiedByKoordinator,
    required this.isVerifiedByInspektor,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] ?? 0,
      idDriver: json['id_driver'] ?? 0,
      jenisKendaraan: json['jenis_kendaraan'] ?? '',
      platNomor: json['plat_nomor'] ?? '',
      expiredStnk: json['expired_stnk'] ?? '',
      expiredKier: json['expired_kier'] ?? '',
      expiredPajak: json['expired_pajak'] ?? '',
      expiredTagging: json['expired_tagging'] ?? '',
      imageStnk: json['image_stnk'] ?? '',
      imageKier: json['image_kier'] ?? '',
      imagePajak: json['image_pajak'] ?? '',
      imageTagging: json['image_tagging'] ?? '',
      imageFront: json['image_vehicle_side_front'] ?? '',
      imageBack: json['image_vehicle_side_back'] ?? '',
      imageLeft: json['image_vehicle_side_left'] ?? '',
      imageRight: json['image_vehicle_side_right'] ?? '',
      driverName: json['nama_driver'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isVerifiedByKoordinator: json['is_verified_by_koordinator'] == 1,
      isVerifiedByInspektor: json['is_verified_by_inspector'] == 1,
    );
  }
}
