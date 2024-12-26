import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maker/components/button_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maker/components/error_message.dart';
import 'package:maker/components/not_fill_able_field.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:heroicons/heroicons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:maker/components/empty_text_field.dart'; // Import the EmptyTextField component
import 'package:maker/components/dropdown_field.dart'; // Import the DropdownField component
import 'package:maker/components/datepicker_field.dart'; // Import the DatePickerField component
import 'package:maker/components/imagepicker_field.dart'; // Import the ImagePickerField component

class AddAssetPage extends StatefulWidget {
  @override
  _AddAssetPageState createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  String _active = 'addAsset';
  String? _userName;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _selectedVehicleType;
  DateTime? _selectedStnkDate;
  DateTime? _selectedKierDate;
  DateTime? _selectedPajakDate;
  DateTime? _selectedTaggingDate;
  TextEditingController _platNomorController = TextEditingController();
  XFile? _stnkImage;
  XFile? _kierImage;
  XFile? _pajakImage;
  XFile? _taggingImage;
  XFile? _frontImage;
  XFile? _backImage;
  XFile? _rightImage;
  XFile? _leftImage;
  bool _showError = false;
  String _errorMessage = '';
  Color _errorColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _loadUserName();
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

  void _showImageDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: PhotoViewGallery.builder(
            itemCount: 1,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(imageFile),
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

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedVehicleType = null;
      _selectedStnkDate = null;
      _selectedKierDate = null;
      _selectedPajakDate = null;
      _selectedTaggingDate = null;
      _stnkImage = null;
      _kierImage = null;
      _pajakImage = null;
      _taggingImage = null;
      _frontImage = null;
      _backImage = null;
      _rightImage = null;
      _leftImage = null;
      _platNomorController.clear();
    });
  }

  Future<void> _selectDate(
      BuildContext context, Function(DateTime?) onDatePicked) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        onDatePicked(picked);
      });
    }
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');
    if (userDataString != null) {
      Map<String, dynamic> userData = jsonDecode(userDataString);
      setState(() {
        _userName = userData['name'];
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');
      String? token = prefs.getString('token');
      if (userDataString == null || token == null) {
        setState(() {
          _showError = true;
          _errorMessage = 'User data or token not found';
        });
        return;
      }
      Map<String, dynamic> userData = jsonDecode(userDataString);
      int idDriver = userData['id'];

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://salmon-magpie-708343.hostingersite.com/api/assets'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['id_driver'] = idDriver.toString();
      request.fields['jenis_kendaraan'] = _selectedVehicleType ?? '';
      request.fields['plat_nomor'] = _platNomorController.text;
      request.fields['expired_stnk'] =
          _selectedStnkDate?.toIso8601String() ?? '';
      request.fields['expired_kier'] =
          _selectedKierDate?.toIso8601String() ?? '';
      request.fields['expired_pajak'] =
          _selectedPajakDate?.toIso8601String() ?? '';
      request.fields['expired_tagging'] =
          _selectedTaggingDate?.toIso8601String() ?? '';

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

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      var responseBody = jsonDecode(responseData.body);

      if (responseBody['status'] == 'success') {
        setState(() {
          _showError = true;
          _errorMessage =
              responseBody['message'] ?? 'Asset Created Successfully';
          _errorColor = Colors.green;
        });
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pushReplacementNamed('/home');
        });
      } else {
        setState(() {
          _showError = true;
          _errorMessage = responseBody['message'] ?? 'Failed to submit data';
          _errorColor = Colors.red;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tambah Aset",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000B58),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF000B58),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: HeroIcon(
                                    HeroIcons.arrowPath,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: _clearForm,
                                ),
                              ),
                              SizedBox(width: 16),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      EmptyTextField(
                          label: 'Plat Nomor',
                          controller: _platNomorController),
                      SizedBox(height: 16),
                      NotFillAbleField(
                          label: 'Nama Driver',
                          value: _userName ?? 'Loading...'),
                      SizedBox(height: 16),
                      DropdownField(
                        label: 'Jenis Kendaraan',
                        items: [
                          'LV',
                          'Innova',
                          'Hyundai H1',
                          'Single Cabin',
                          'Double Cabin',
                          'Hiace',
                          'Elf',
                          'BU'
                        ],
                        selectedValue: _selectedVehicleType,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedVehicleType = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          Column(
                            children: [
                              DatePickerField(
                                label: 'Exp STNK',
                                selectedDate: _selectedStnkDate,
                                onDatePicked: (date) =>
                                    _selectedStnkDate = date,
                                selectDate: _selectDate,
                              ),
                              SizedBox(height: 8),
                              ImagePickerField(
                                label: 'Foto STNK',
                                image: _stnkImage,
                                onImagePicked: (image) => _stnkImage = image,
                                showImageDialog: _showImageDialog,
                                pickImage: _pickImage,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              DatePickerField(
                                label: 'Exp KIR',
                                selectedDate: _selectedKierDate,
                                onDatePicked: (date) =>
                                    _selectedKierDate = date,
                                selectDate: _selectDate,
                              ),
                              SizedBox(height: 8),
                              ImagePickerField(
                                label: 'Foto KIR',
                                image: _kierImage,
                                onImagePicked: (image) => _kierImage = image,
                                showImageDialog: _showImageDialog,
                                pickImage: _pickImage,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              DatePickerField(
                                label: 'Exp Pajak',
                                selectedDate: _selectedPajakDate,
                                onDatePicked: (date) =>
                                    _selectedPajakDate = date,
                                selectDate: _selectDate,
                              ),
                              SizedBox(height: 8),
                              ImagePickerField(
                                label: 'Foto Pajak',
                                image: _pajakImage,
                                onImagePicked: (image) => _pajakImage = image,
                                showImageDialog: _showImageDialog,
                                pickImage: _pickImage,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              DatePickerField(
                                label: 'Exp Tagging',
                                selectedDate: _selectedTaggingDate,
                                onDatePicked: (date) =>
                                    _selectedTaggingDate = date,
                                selectDate: _selectDate,
                              ),
                              SizedBox(height: 8),
                              ImagePickerField(
                                label: 'Foto Tagging',
                                image: _taggingImage,
                                onImagePicked: (image) => _taggingImage = image,
                                showImageDialog: _showImageDialog,
                                pickImage: _pickImage,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ImagePickerField(
                        label: 'Gambar Depan',
                        image: _frontImage,
                        onImagePicked: (image) => _frontImage = image,
                        showImageDialog: _showImageDialog,
                        pickImage: _pickImage,
                      ),
                      SizedBox(height: 16),
                      ImagePickerField(
                        label: 'Gambar Belakang',
                        image: _backImage,
                        onImagePicked: (image) => _backImage = image,
                        showImageDialog: _showImageDialog,
                        pickImage: _pickImage,
                      ),
                      SizedBox(height: 16),
                      ImagePickerField(
                        label: 'Gambar Kanan',
                        image: _rightImage,
                        onImagePicked: (image) => _rightImage = image,
                        showImageDialog: _showImageDialog,
                        pickImage: _pickImage,
                      ),
                      SizedBox(height: 16),
                      ImagePickerField(
                        label: 'Gambar Kiri',
                        image: _leftImage,
                        onImagePicked: (image) => _leftImage = image,
                        showImageDialog: _showImageDialog,
                        pickImage: _pickImage,
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF000B58),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Simpan',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
      bottomNavigationBar: BottomNavigation(
        active: _active,
      ),
    );
  }
}
