import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maker/components/button_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan ini

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _active = 'profile';
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID'); // Tambahkan ini
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');
    if (userDataString != null) {
      userData = jsonDecode(userDataString);
      final int userId = userData!['id'];
      final String token = prefs.getString('token') ?? '';
      await _fetchUserData(userId, token);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData(int userId, String token) async {
    final String url =
        'https://salmon-magpie-708343.hostingersite.com/api/user/$userId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            userData = responseData['data']['user'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData != null
              ? SafeArea(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 26),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: const Text(
                                        "Profile",
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF000B58),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Row(
                                  //   children: [
                                  //     Container(
                                  //       decoration: const BoxDecoration(
                                  //         color: Color(0xFF000B58),
                                  //         shape: BoxShape.circle,
                                  //       ),
                                  //       child: IconButton(
                                  //         icon: const Icon(
                                  //           Icons.edit,
                                  //           color: Colors.white,
                                  //           size: 24,
                                  //         ),
                                  //         onPressed: _edit,
                                  //       ),
                                  //     ),
                                  //     const SizedBox(width: 16),
                                  //   ],
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 80,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: userData![
                                                "profile_picture"] ==
                                            "default-profile-blank"
                                        ? AssetImage(
                                            'assets/images/${userData!["profile_picture"]}.jpg')
                                        : NetworkImage(
                                                'https://salmon-magpie-708343.hostingersite.com/storage/images/${userData!["profile_picture"]}.jpg')
                                            as ImageProvider,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      userData!["name"],
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo[900],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "@${userData!["username"]}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.indigo[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildProfileInfoCard(
                                    title: "Phone Number",
                                    value: userData!["phone_number"],
                                  ),
                                  _buildProfileInfoCard(
                                    title: "Email",
                                    value: userData!["email"],
                                  ),
                                  _buildProfileInfoCard(
                                    title: "Departmen",
                                    value: userData!["department"]
                                        .toString()
                                        .toUpperCase(),
                                  ),
                                  _buildProfileInfoCard(
                                    title: "Sudah di verifikasi admin?",
                                    value: userData!["is_admin_verified"] == 1
                                        ? "Ya"
                                        : "Belum",
                                  ),
                                  _buildProfileInfoCard(
                                    title: "Bergabung sejak",
                                    value: _formatDate(userData!["created_at"]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _logout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF000B58),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: Size(double.infinity, 50),
                                  ),
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(child: Text('Failed to load user data')),
      bottomNavigationBar: BottomNavigation(
        active: _active,
      ),
    );
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
  }

  Widget _buildProfileInfoCard({required String title, required String value}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      color:
          const Color.fromARGB(255, 255, 255, 255), // Ubah warna latar belakang
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF003161), // Ubah warna teks
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF003161), // Ubah warna teks
          ),
        ),
      ),
    );
  }

  void _edit() {
    // Implement edit profile
  }
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
