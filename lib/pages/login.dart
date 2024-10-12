import 'package:flutter/material.dart';
import 'package:maker/styleguide/colors.dart';
import 'package:maker/styleguide/text_style.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold( // Pastikan setiap halaman memiliki Scaffold
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 60),
            // Logo
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            // Title
            Text(
              'Login',
              style: poppinsBold.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 10),
            // Subtitle
            Text(
              'Silakan masuk untuk melanjutkan',
              style: poppinsRegular.copyWith(fontSize: 16, color: secondary),
            ),
            const SizedBox(height: 40),
            // Username Input
            const TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            // Password Input
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Logika login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tertiary,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Masuk',
                  style: poppinsBold.copyWith(fontSize: 18, color: accent),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Register Prompt
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Belum punya akun? ',
                  style: poppinsRegular.copyWith(fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    'Daftar',
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
    );
  }
}