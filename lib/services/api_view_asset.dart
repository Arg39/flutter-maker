import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final String? status;

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
    this.status,
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
      status: json['status'],
    );
  }
}

class ApiService {
  final String baseUrl = 'https://salmon-magpie-708343.hostingersite.com';

  Future<List<Asset>> fetchAssetsByEndpoint(
      String token, String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final assetsData = jsonDecode(response.body)['data'] as List;
      List<Asset> assets = [];
      for (var asset in assetsData) {
        String driverName = await fetchUserNameById(asset['id_driver'], token);
        assets.add(Asset.fromJson({...asset, 'driver_name': driverName}));
      }
      return assets;
    } else {
      throw Exception('Failed to load assets');
    }
  }

  Future<List<Asset>> fetchNotVerifiedAssets(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/assets-not-verified'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final assetsData = jsonDecode(response.body)['data'] as List;
      List<Asset> assets = [];
      for (var asset in assetsData) {
        String driverName = await fetchUserNameById(asset['id_driver'], token);
        assets.add(Asset.fromJson({...asset, 'driver_name': driverName}));
      }
      return assets;
    } else {
      throw Exception('Failed to load assets');
    }
  }

  Future<List<Asset>> fetchAssetsVerifiedByKoordinator(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/assets-verified-koordinator'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final assetsData = jsonDecode(response.body)['data'] as List;
      List<Asset> assets = [];
      for (var asset in assetsData) {
        String driverName = await fetchUserNameById(asset['id_driver'], token);
        assets.add(Asset.fromJson({...asset, 'driver_name': driverName}));
      }
      return assets;
    } else {
      throw Exception('Failed to load assets');
    }
  }

  Future<List<Asset>> fetchAssetsByDriver(String token, int driverId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/get-asset-by-driver/$driverId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final assetsData = jsonDecode(response.body)['data'] as List;
      List<Asset> assets = [];
      for (var asset in assetsData) {
        String driverName = await fetchUserNameById(asset['id_driver'], token);
        assets.add(Asset.fromJson({...asset, 'driver_name': driverName}));
      }
      return assets;
    } else {
      throw Exception('Failed to load assets');
    }
  }

  Future<String> fetchUserNameById(int id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data']['user']['name'];
    } else {
      throw Exception('Failed to load user');
    }
  }
}
