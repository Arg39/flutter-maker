import 'package:flutter/material.dart';
import 'package:maker/pages/addAsset.dart';
import 'package:maker/pages/assetDetail.dart';
import 'package:maker/pages/editAsset.dart';
import 'package:maker/pages/home.dart';
import 'package:maker/pages/login.dart';
import 'package:maker/pages/notification.dart';
import 'package:maker/pages/profile.dart';
import 'package:maker/pages/register.dart';
import 'package:maker/pages/userManagement.dart';
import 'package:maker/pages/viewAssets.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addAsset = '/addAsset';
  static const String profile = '/profile';
  static const String userManagement = '/userManagement';
  static const String viewAssets = '/viewAssets';
  static const String assetDetail = '/assetDetail';
  static const String editAsset = '/editAsset';
  static const String notification = '/notification';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginPage(),
      register: (context) => RegisterPage(),
      home: (context) => HomePage(),
      addAsset: (context) => AddAssetPage(),
      profile: (context) => ProfilePage(),
      viewAssets: (context) => AssetListPage(),
      userManagement: (context) => UserManagementPage(),
      assetDetail: (context) => AssetDetailPage(
          assetId: ModalRoute.of(context)!.settings.arguments as int),
      editAsset: (context) => EditAssetPage(
          assetId: ModalRoute.of(context)!.settings.arguments as int),
      notification: (context) => NotificationPage(),
    };
  }
}
