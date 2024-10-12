import 'package:flutter/material.dart';
import 'package:maker/pages/login.dart';
import 'package:maker/pages/register.dart';
import 'package:maker/styleguide/colors.dart';
import 'package:maker/styleguide/text_style.dart';
import 'package:maker/template.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Template(
      child: MaterialApp(
        title: 'Flutter Auth',
        theme: ThemeData(
          primaryColor: primary,
          scaffoldBackgroundColor: accent,
          textTheme: TextTheme(
            bodyLarge: poppinsRegular,
            bodyMedium: poppinsRegular,
            titleLarge: poppinsBold,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
        },
      ),
    );
  }
}