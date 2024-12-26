import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maker/components/error_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:io';

class EditAssetPage extends StatefulWidget {
  final int assetId;

  EditAssetPage({required this.assetId});

  @override
  _EditAssetPageState createState() => _EditAssetPageState();
}

class _EditAssetPageState extends State<EditAssetPage> {
  late Future<Asset> asset;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final ImagePicker _picker = ImagePicker();
  XFile? _stnkImage;
  XFile? _kierImage;
  XFile? _pajakImage;
  XFile? _taggingImage;
  XFile? _frontImage;
  XFile? _backImage;
  XFile? _rightImage;
  XFile? _leftImage;

  String? _stnkImageUrl;
  String? _kierImageUrl;
  String? _pajakImageUrl;
  String? _taggingImageUrl;
  String? _frontImageUrl;
  String? _backImageUrl;
  String? _rightImageUrl;
  String? _leftImageUrl;

  bool _showError = false;
  String _errorMessage = '';
  Color _errorColor = Colors.red;

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
        _initializeControllers(asset);
        _initializeImageUrls(asset);
        return asset;
      } catch (e) {
        throw Exception('Failed to parse asset data: $e');
      }
    } else {
      throw Exception('Failed to load asset');
    }
  }

  void _initializeControllers(Asset asset) {
    _controllers['jenisKendaraan'] =
        TextEditingController(text: asset.jenisKendaraan);
    _controllers['platNomor'] = TextEditingController(text: asset.platNomor);
    _controllers['driverName'] = TextEditingController(text: asset.driverName);
    _controllers['expiredStnk'] =
        TextEditingController(text: asset.expiredStnk);
    _controllers['expiredKier'] =
        TextEditingController(text: asset.expiredKier);
    _controllers['expiredPajak'] =
        TextEditingController(text: asset.expiredPajak);
    _controllers['expiredTagging'] =
        TextEditingController(text: asset.expiredTagging);
  }

  void _initializeImageUrls(Asset asset) {
    _stnkImageUrl = asset.imageStnk;
    _kierImageUrl = asset.imageKier;
    _pajakImageUrl = asset.imagePajak;
    _taggingImageUrl = asset.imageTagging;
    _frontImageUrl = asset.imageFront;
    _backImageUrl = asset.imageBack;
    _rightImageUrl = asset.imageRight;
    _leftImageUrl = asset.imageLeft;
  }

  Future<void> _pickImage(
      ImageSource source, Function(XFile?) onImagePicked) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      setState(() {
        onImagePicked(pickedFile);
      });
    } catch (e) {
      print("Error picking image: $e");
    }
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
                imageProvider: imageUrl.startsWith('http')
                    ? NetworkImage(imageUrl)
                    : FileImage(File(imageUrl)),
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

  Future<void> _saveAsset() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        setState(() {
          _showError = true;
          _errorMessage = 'Token not found';
        });
        return;
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            'https://salmon-magpie-708343.hostingersite.com/api/assets/${widget.assetId}'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['jenis_kendaraan'] = _controllers['jenisKendaraan']!.text;
      request.fields['plat_nomor'] = _controllers['platNomor']!.text;
      request.fields['expired_stnk'] = _controllers['expiredStnk']!.text;
      request.fields['expired_kier'] = _controllers['expiredKier']!.text;
      request.fields['expired_pajak'] = _controllers['expiredPajak']!.text;
      request.fields['expired_tagging'] = _controllers['expiredTagging']!.text;

      if (_stnkImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image_stnk',
          _stnkImage!.path,
        ));
      }
      if (_kierImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image_kier',
          _kierImage!.path,
        ));
      }
      if (_pajakImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image_pajak',
          _pajakImage!.path,
        ));
      }
      if (_taggingImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image_tagging',
          _taggingImage!.path,
        ));
      }
      if (_frontImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image_vehicle_side_front',
          _frontImage!.path,
        ));
      }
      if (_backImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image_vehicle_side_back',
          _backImage!.path,
        ));
      }
      if (_leftImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image_vehicle_side_left',
          _leftImage!.path,
        ));
      }
      if (_rightImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image_vehicle_side_right',
          _rightImage!.path,
        ));
      }

      try {
        var response = await request.send();
        var responseData = await http.Response.fromStream(response);
        var responseBody = jsonDecode(responseData.body);

        if (response.statusCode == 200) {
          setState(() {
            _showError = true;
            _errorMessage =
                responseBody['message'] ?? 'Asset Updated Successfully';
            _errorColor = Colors.green;
          });
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
        } else {
          setState(() {
            _showError = true;
            _errorMessage = responseBody['message'] ?? 'Failed to update data';
            _errorColor = Colors.red;
          });
        }
      } catch (e) {
        setState(() {
          _showError = true;
          _errorMessage = 'An error occurred: $e';
          _errorColor = Colors.red;
        });
      }
    }
  }

  void _removeImage(Function(XFile?) onImagePicked) {
    setState(() {
      onImagePicked(null);
    });
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
          "Edit Aset",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000B58),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<Asset>(
              future: asset,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No asset data available'));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                        _buildEditableField(
                            'Jenis Kendaraan', 'jenisKendaraan'),
                        SizedBox(height: 16),
                        _buildEditableField('Plat Nomor', 'platNomor'),
                        SizedBox(height: 16),
                        _buildEditableField('Nama Driver', 'driverName',
                            enabled: false),
                        SizedBox(height: 16),
                        _buildEditableField('Expired STNK', 'expiredStnk'),
                        SizedBox(height: 16),
                        _buildImageField('Foto STNK', _stnkImage, _stnkImageUrl,
                            (image) => _stnkImage = image),
                        SizedBox(height: 16),
                        _buildEditableField('Expired KIR', 'expiredKier'),
                        SizedBox(height: 16),
                        _buildImageField('Foto KIR', _kierImage, _kierImageUrl,
                            (image) => _kierImage = image),
                        SizedBox(height: 16),
                        _buildEditableField('Expired Pajak', 'expiredPajak'),
                        SizedBox(height: 16),
                        _buildImageField('Foto Pajak', _pajakImage,
                            _pajakImageUrl, (image) => _pajakImage = image),
                        SizedBox(height: 16),
                        _buildEditableField(
                            'Expired Tagging', 'expiredTagging'),
                        SizedBox(height: 16),
                        _buildImageField('Foto Tagging', _taggingImage,
                            _taggingImageUrl, (image) => _taggingImage = image),
                        SizedBox(height: 16),
                        _buildImageField('Gambar Depan', _frontImage,
                            _frontImageUrl, (image) => _frontImage = image),
                        SizedBox(height: 16),
                        _buildImageField('Gambar Belakang', _backImage,
                            _backImageUrl, (image) => _backImage = image),
                        SizedBox(height: 16),
                        _buildImageField('Gambar Kanan', _rightImage,
                            _rightImageUrl, (image) => _rightImage = image),
                        SizedBox(height: 16),
                        _buildImageField('Gambar Kiri', _leftImage,
                            _leftImageUrl, (image) => _leftImage = image),
                        SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _saveAsset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF000B58),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text(
                            'Perbarui Aset',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_showError)
              ErrorMessage(
                message: _errorMessage,
                onClose: () {
                  setState(() {
                    _showError = false;
                  });
                },
                color: _errorColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String key, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF006A67))),
        SizedBox(height: 8),
        TextFormField(
          controller: _controllers[key],
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? Colors.white
                : const Color.fromARGB(255, 241, 241, 241),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF006A67), width: 1),
            ),
          ),
          style: TextStyle(
            color:
                enabled ? Colors.black : const Color.fromARGB(255, 31, 31, 31),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildImageField(String label, XFile? image, String? imageUrl,
      Function(XFile?) onImagePicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF006A67))),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (image != null) {
              _showImageDialog(image.path);
            } else if (imageUrl != null) {
              _showImageDialog(imageUrl);
            }
          },
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF006A67), width: 1),
            ),
            child: image == null
                ? imageUrl == null
                    ? Center(child: Text('Tap to select image'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(image.path),
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        if (image != null)
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
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _pickImage(ImageSource.gallery, onImagePicked),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF006A67),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: Size(double.infinity, 50), // Make button full width
          ),
          child: Text('Pilih foto', style: TextStyle(color: Colors.white)),
        ),
        if (image != null)
          Container(
            margin: const EdgeInsets.only(top: 8.0), // Add top margin
            child: ElevatedButton(
              onPressed: () => _removeImage(onImagePicked),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12), // Add const
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 50), // Add const
              ),
              child: const Text('Hapus foto',
                  style: TextStyle(color: Colors.white)), // Add const
            ),
          ),
      ],
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
