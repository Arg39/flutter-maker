import 'package:flutter/material.dart';
import 'package:maker/routes/routes.dart';
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
        // debugShowCheckedModeBanner: false,
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
        initialRoute: AppRoutes.login,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
