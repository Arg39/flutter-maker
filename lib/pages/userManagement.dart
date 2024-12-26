import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maker/components/button_navigation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heroicons/heroicons.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String _active = 'userManagement';
  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _errorMessage;
  Color _errorColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _fetchUnverifiedUsers();
  }

  Future<void> _fetchUnverifiedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(
          'https://salmon-magpie-708343.hostingersite.com/api/user-unverified'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _users = data['data']['users'];
        _isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyUser(int userId, bool isVerified) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.put(
      Uri.parse(
          'https://salmon-magpie-708343.hostingersite.com/api/user-verify/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'is_verified': isVerified}),
    );

    try {
      final responseData = json.decode(response.body);

      if (responseData['status'] == 'success') {
        setState(() {
          _errorMessage = responseData['message'];
          _errorColor = Colors.green;
        });
        _fetchUnverifiedUsers();
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            _errorMessage = null;
          });
          Navigator.pushReplacementNamed(context, '/userManagement');
        });
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Failed to verify user';
          _errorColor = Colors.red;
        });
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            _errorMessage = null;
          });
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error occurred';
        _errorColor = Colors.red;
      });
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _errorMessage = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Pengguna'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _users.isEmpty
                  ? Center(
                      child:
                          Text('Maaf belum ada pengguna yang mendaftar lagi'))
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user!["profile_picture"] ==
                                      "default-profile-blank"
                                  ? AssetImage(
                                      'assets/images/${user!["profile_picture"]}.jpg')
                                  : NetworkImage(
                                          'https://salmon-magpie-708343.hostingersite.com/storage/images/${user!["profile_picture"]}.jpg')
                                      as ImageProvider,
                            ),
                            title: Text(user['name']),
                            subtitle: Text(user['email']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check_circle,
                                      color: Colors.green),
                                  onPressed: () =>
                                      _verifyUser(user['id'], true),
                                ),
                                IconButton(
                                  icon: Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () =>
                                      _verifyUser(user['id'], false),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          if (_errorMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ErrorMessage(
                message: _errorMessage!,
                onClose: () {
                  setState(() {
                    _errorMessage = null;
                  });
                },
                color: _errorColor,
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        active: _active,
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  final Color color;

  ErrorMessage({
    required this.message,
    required this.onClose,
    this.color = Colors.red, // Default to red if not specified
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color, // Use the provided color
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              HeroIcon(
                HeroIcons.exclamationCircle,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          IconButton(
            icon: HeroIcon(
              HeroIcons.xCircle,
              color: Colors.white,
              size: 24,
            ),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
