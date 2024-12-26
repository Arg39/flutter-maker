import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maker/pages/addAsset.dart';
import 'package:maker/pages/home.dart';
import 'package:maker/pages/notification.dart';
import 'package:maker/pages/profile.dart';
import 'package:maker/pages/userManagement.dart';
import 'package:maker/pages/viewAssets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heroicons/heroicons.dart';

class BottomNavigation extends StatefulWidget {
  final String active;

  BottomNavigation({required this.active});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late String role;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');
    Map<String, dynamic>? userData =
        userDataString != null ? jsonDecode(userDataString) : null;
    setState(() {
      role = userData?['role'] ?? '';
    });
  }

  void _onItemTapped(String route) {
    Widget page;
    switch (route) {
      case 'home':
        page = HomePage();
        break;
      case 'viewAssets':
        page = AssetListPage();
        break;
      case 'userManagement':
        page = UserManagementPage();
        break;
      case 'addAsset':
        page = AddAssetPage();
        break;
      case 'notification':
        page = NotificationPage();
        break;
      case 'profile':
        page = ProfilePage();
        break;
      default:
        page = HomePage();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getNavigationItems() async {
    if (role == 'koordinator' || role == 'inspektor') {
      return [
        {'icon': HeroIcons.home, 'label': 'Home', 'route': 'home'},
        {'icon': HeroIcons.briefcase, 'label': 'Asset', 'route': 'viewAssets'},
        {
          'icon': HeroIcons.userGroup,
          'label': 'User Manage',
          'route': 'userManagement'
        },
        {'icon': HeroIcons.user, 'label': 'Profile', 'route': 'profile'},
      ];
    } else {
      return [
        {'icon': HeroIcons.home, 'label': 'Home', 'route': 'home'},
        {'icon': HeroIcons.briefcase, 'label': 'Asset', 'route': 'viewAssets'},
        {
          'icon': HeroIcons.plusCircle,
          'label': 'Add Asset',
          'route': 'addAsset'
        },
        {
          'icon': HeroIcons.bell,
          'label': 'Notification',
          'route': 'notification'
        },
        {'icon': HeroIcons.user, 'label': 'Profile', 'route': 'profile'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getNavigationItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final items = snapshot.data!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              return _buildNavItem(
                context: context,
                icon: item['icon'],
                label: item['label'],
                route: item['route'],
                isSelected: widget.active == item['route'],
                onTap: _onItemTapped,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required HeroIcons icon,
    required String label,
    required String route,
    required bool isSelected,
    required Function(String) onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeroIcon(
            icon,
            color: isSelected ? Color(0xFF000B58) : Color(0xFF006A67),
            size: 32,
            style: isSelected ? HeroIconStyle.solid : HeroIconStyle.outline,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFF000B58) : Color(0xFF006A67),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
