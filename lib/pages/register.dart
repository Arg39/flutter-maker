import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heroicons/heroicons.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  bool _showError = false;
  String _errorMessage = '';
  String? _selectedDepartment;

  final List<String> _departments = [
    'Steel Structure',
    'HSE',
    'Instrumental',
    'Electrical',
    'Time Keeper',
    'Material',
    'Warehouse',
    'GA',
    'Kariangau',
    'Piping'
  ];

  Future<void> _register() async {
    final String name = _nameController.text;
    final String username = _usernameController.text;
    final String phoneNumber = _phoneNumberController.text;
    final String email = _emailController.text;
    final String department = _selectedDepartment ?? '';
    final String password = _passwordController.text;
    final String passwordConfirmation = _passwordConfirmationController.text;

    final String url =
        'https://salmon-magpie-708343.hostingersite.com/api/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'username': username,
          'phone_number': phoneNumber,
          'email': email,
          'department': department,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': 'driver', // Set role to driver
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final Map<String, dynamic> userData = responseData['data']['user'];
        final String token = responseData['data']['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(userData));
        await prefs.setString('token', token);

        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        setState(() {
          _showError = true;
          _errorMessage = responseData['message'] ?? 'Registration failed';
        });
      }
    } catch (error) {
      setState(() {
        _showError = true;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _showError = true;
      _errorMessage = message;
    });

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _showError = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFEFE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "RDMP BALIKPAPAN JO",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000B58),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'assets/images/illustration-for-register.png',
                    height: 400,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  "Daftar",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003161)),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Nama Lengkap",
                    prefixIcon:
                        HeroIcon(HeroIcons.user, style: HeroIconStyle.solid),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: HeroIcon(HeroIcons.userCircle,
                        style: HeroIconStyle.solid),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: "Nomor Telepon",
                    prefixIcon:
                        HeroIcon(HeroIcons.phone, style: HeroIconStyle.solid),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: HeroIcon(HeroIcons.envelope,
                        style: HeroIconStyle.solid),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  items: _departments.map((String department) {
                    return DropdownMenuItem<String>(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDepartment = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Departmen",
                    prefixIcon: HeroIcon(HeroIcons.briefcase,
                        style: HeroIconStyle.solid),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: HeroIcon(HeroIcons.lockClosed,
                        style: HeroIconStyle.solid),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordConfirmationController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Konfirmasi Password",
                    prefixIcon: HeroIcon(HeroIcons.lockClosed,
                        style: HeroIconStyle.solid),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_showError)
                  AnimatedOpacity(
                    opacity: _showError ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 60),
                Center(
                  child: Text(
                    "Buat akun baru untuk melanjutkan",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3A953C), Color(0xFF1E6F2E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: Size(double.infinity, 65),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Daftar",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Sudah punya akun?",
                      style: TextStyle(color: const Color(0xFF006A67)),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
