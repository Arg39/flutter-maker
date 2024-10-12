import 'package:flutter/material.dart';
import 'package:maker/styleguide/colors.dart';
import 'package:maker/styleguide/text_style.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers untuk mengelola input
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Dispose controllers saat tidak diperlukan
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi untuk menangani registrasi
  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      // Logika registrasi di sini
      // Misalnya, mengirim data ke backend atau Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi Berhasil')),
      );
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menambahkan Scaffold
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Menambahkan Form
          child: Column(
            children: [
              SizedBox(height: 60),
              // Logo
              Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
              SizedBox(height: 20),
              // Title
              Text(
                'Daftar',
                style: poppinsBold.copyWith(fontSize: 32),
              ),
              SizedBox(height: 10),
              // Subtitle
              Text(
                'Buat akun baru Anda',
                style: poppinsRegular.copyWith(fontSize: 16, color: secondary),
              ),
              SizedBox(height: 40),
              // Username Input
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Email Input
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  // Simple email validation
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Password Input
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.trim().length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tertiary,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Daftar',
                    style: poppinsBold.copyWith(fontSize: 18, color: accent),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Login Prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: poppinsRegular.copyWith(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      'Masuk',
                      style: poppinsMedium.copyWith(
                        fontSize: 16,
                        color: tertiary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}