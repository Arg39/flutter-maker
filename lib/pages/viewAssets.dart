import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maker/components/button_navigation.dart';
import 'package:maker/pages/assetDetail.dart' as assetDetail;
import 'package:maker/services/api_view_asset.dart' as apiService;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maker/components/asset_card.dart';
import 'package:maker/components/error_message.dart';

class AssetListPage extends StatefulWidget {
  @override
  _AssetListPageState createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  String _active = 'viewAssets';
  late apiService.ApiService apiServiceInstance;
  String? token;
  String? username;
  int? userId;
  String? role;
  String? _errorMessage;
  Color _errorColor = Colors.red;

  @override
  void initState() {
    super.initState();
    apiServiceInstance = apiService.ApiService();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenString = prefs.getString('token') ?? '';
    final userDataString = prefs.getString('userData');

    if (userDataString != null && tokenString.isNotEmpty) {
      final userData = jsonDecode(userDataString);
      setState(() {
        token = tokenString;
        username = userData['username'] ?? '';
        userId = userData['id'] ?? 0;
        role = userData['role'] ?? '';
      });
    }
  }

  Future<List<apiService.Asset>> fetchAssets(String endpoint) async {
    if (token == null || username == null || userId == null) {
      throw Exception('User data not found');
    }

    return await apiServiceInstance.fetchAssetsByEndpoint(token!, endpoint);
  }

  void _showError(String message, Color color) {
    setState(() {
      _errorMessage = message;
      _errorColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.white,
                  pinned: true,
                  title: Center(
                    child: Text(
                      'Daftar Aset',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                Expanded(
                  child: DefaultTabController(
                    length: _getTabLength(),
                    child: Column(
                      children: [
                        TabBar(
                          tabs: _buildTabs(),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: _buildTabViews(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_errorMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.transparent,
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
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        active: _active,
      ),
    );
  }

  int _getTabLength() {
    if (role == 'koordinator' || role == 'inspektor') {
      return 2;
    } else if (role == 'driver') {
      return 2;
    } else {
      return 1;
    }
  }

  List<Widget> _buildTabs() {
    List<Widget> tabs = [Tab(text: 'Asset Terverifikasi')];
    if (role == 'koordinator') {
      tabs.add(Tab(text: 'Penerusan'));
    }
    if (role == 'inspektor') {
      tabs.add(Tab(text: 'Verifikasi sebagai Inspektor'));
    }
    if (role == 'driver') {
      tabs.add(Tab(text: 'Pengajuan Asset'));
    }
    return tabs;
  }

  List<Widget> _buildTabViews() {
    List<Widget> tabViews = [_buildAssetList('assets-verified-inspector')];
    if (role == 'koordinator') {
      tabViews.add(_buildAssetList('assets-not-verified'));
    }
    if (role == 'inspektor') {
      tabViews.add(_buildFilteredAssetList('assets-verified-koordinator'));
    }
    if (role == 'driver') {
      tabViews
          .add(_buildAssetList('assets-not-verified-asset-by-driver/$userId'));
    }
    return tabViews;
  }

  Widget _buildAssetList(String endpoint) {
    return FutureBuilder<List<apiService.Asset>>(
      future: fetchAssets(endpoint),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No assets available'));
        }

        final assets = snapshot.data!;
        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final asset = assets[index];
            return AssetCard(
              asset: asset,
              onError: _showError,
            );
          },
        );
      },
    );
  }

  Widget _buildFilteredAssetList(String endpoint) {
    return FutureBuilder<List<apiService.Asset>>(
      future: fetchAssets(endpoint),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No assets available'));
        }

        final assets = snapshot.data!
            .where((asset) =>
                asset.status == null || asset.status == 'ReSubmission')
            .toList();
        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final asset = assets[index];
            return AssetCard(
              asset: asset,
              onError: _showError,
            );
          },
        );
      },
    );
  }
}
