import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maker/components/confirmation_dialog.dart';
import 'package:maker/pages/assetDetail.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AssetCard extends StatefulWidget {
  final asset;
  final Function(String, Color) onError;

  const AssetCard({Key? key, required this.asset, required this.onError})
      : super(key: key);

  @override
  _AssetCardState createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  String? role;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        role = userData['role'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonSize =
        screenWidth * 0.1; // Adjust button size based on screen width

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssetDetailPage(assetId: widget.asset.id),
              ),
            );
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: FractionallySizedBox(
                  widthFactor: 0.9, // Set the width as 90% of the parent width
                  child: Stack(
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              color: Colors.white,
                              child: Text(
                                widget.asset.platNomor,
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: screenWidth *
                                      0.02, // Adjust font size based on screen width
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      widget.asset.imageFront,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // Positioned(
                                //   top: 8,
                                //   left: 8,
                                //   child: Container(
                                //     padding: EdgeInsets.symmetric(
                                //         horizontal: 8, vertical: 4),
                                //     color: Colors.blue[900],
                                //     child: Text(
                                //       widget.asset.jenisKendaraan,
                                //       style: TextStyle(
                                //         color: Colors.white,
                                //         fontSize: screenWidth *
                                //             0.02, // Adjust font size based on screen width
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //       maxLines: 1,
                                //       overflow: TextOverflow.ellipsis,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.asset.jenisKendaraan,
                                    style: TextStyle(
                                      fontSize: screenWidth *
                                          0.032, // Adjust font size based on screen width
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF000B58),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    widget.asset.driverName,
                                    style: TextStyle(
                                      fontSize: screenWidth *
                                          0.022, // Adjust font size based on screen width
                                      color: Color(0xFF000B58),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    widget.asset.createdAt,
                                    style: TextStyle(
                                      fontSize: screenWidth *
                                          0.022, // Adjust font size based on screen width
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: ClipPath(
                          clipper: QuarterCircleClipper(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[900],
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                              ),
                            ),
                            width: buttonSize,
                            height: buttonSize,
                            child: Center(
                              child: Transform.translate(
                                offset:
                                    Offset(buttonSize * 0.1, -buttonSize * 0.1),
                                child: PopupMenuButton<String>(
                                  onSelected: (String result) {
                                    switch (result) {
                                      case 'edit':
                                        Navigator.pushNamed(
                                            context, '/editAsset',
                                            arguments: widget.asset.id);
                                        break;
                                      case 'hapus':
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ConfirmationDialog(
                                              title: 'Konfirmasi Hapus',
                                              content:
                                                  'Apakah anda yakin untuk menghapus data ${widget.asset.jenisKendaraan}?',
                                              onConfirm: () async {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                String? token =
                                                    prefs.getString('token');

                                                if (token == null ||
                                                    widget.asset.id == null) {
                                                  widget.onError(
                                                      'Token not found',
                                                      Colors.red);
                                                  return;
                                                }

                                                var response =
                                                    await http.delete(
                                                  Uri.parse(
                                                      'https://salmon-magpie-708343.hostingersite.com/api/assets/${widget.asset.id}'),
                                                  headers: {
                                                    'Authorization':
                                                        'Bearer $token',
                                                  },
                                                );

                                                var responseBody =
                                                    jsonDecode(response.body);

                                                if (responseBody['status'] ==
                                                    'success') {
                                                  widget.onError(
                                                      responseBody['message'],
                                                      Colors.green);
                                                  Future.delayed(
                                                      Duration(seconds: 2), () {
                                                    if (mounted) {
                                                      Navigator.of(context)
                                                          .pop(); // Kembali ke halaman sebelumnya
                                                    }
                                                  });
                                                } else {
                                                  widget.onError(
                                                      responseBody['message'],
                                                      Colors.red);
                                                }
                                              },
                                              onCancel: () async {
                                                widget.onError(
                                                    'Proses tindak lanjut dibatalkan',
                                                    Colors.red);
                                              },
                                            );
                                          },
                                        );
                                        break;
                                      case 'verifikasi_koordinator':
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ConfirmationDialog(
                                              title: 'Konfirmasi Penerusan',
                                              content:
                                                  'Apakah anda yakin untuk meneruskan data ${widget.asset.jenisKendaraan} ke Inspektor?',
                                              onConfirm: () async {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                String? token =
                                                    prefs.getString('token');

                                                if (token == null ||
                                                    widget.asset.id == null) {
                                                  widget.onError(
                                                      'Token not found',
                                                      Colors.red);
                                                  return;
                                                }

                                                var response = await http.put(
                                                  Uri.parse(
                                                      'https://salmon-magpie-708343.hostingersite.com/api/assets-verify-koordinator/${widget.asset.id}'),
                                                  headers: {
                                                    'Authorization':
                                                        'Bearer $token',
                                                    'Content-Type':
                                                        'application/json',
                                                  },
                                                  body: jsonEncode({
                                                    'is_verified_by_koordinator':
                                                        true,
                                                  }),
                                                );

                                                var responseBody =
                                                    jsonDecode(response.body);

                                                if (responseBody['status'] ==
                                                    'success') {
                                                  widget.onError(
                                                      responseBody['message'],
                                                      Colors.green);
                                                  Future.delayed(
                                                      Duration(seconds: 2), () {
                                                    if (mounted) {
                                                      Navigator.of(context)
                                                          .pop(); // Kembali ke halaman sebelumnya
                                                    }
                                                  });
                                                } else {
                                                  widget.onError(
                                                      responseBody['message'],
                                                      Colors.red);
                                                }
                                              },
                                              onCancel: () async {
                                                // Handle cancellation
                                                widget.onError(
                                                    'Penerusan dibatalkan',
                                                    Colors.red);
                                              },
                                            );
                                          },
                                        );
                                        break;
                                      case 'verifikasi_inspektor':
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ConfirmationDialog(
                                              title: 'Konfirmasi Penerusan',
                                              content:
                                                  'Apakah anda yakin untuk memverifikasi data ${widget.asset.jenisKendaraan}?',
                                              onConfirm: () async {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                String? token =
                                                    prefs.getString('token');

                                                if (token == null ||
                                                    widget.asset.id == null) {
                                                  widget.onError(
                                                      'Token not found',
                                                      Colors.red);
                                                  return;
                                                }

                                                var response = await http.put(
                                                  Uri.parse(
                                                      'https://salmon-magpie-708343.hostingersite.com/api/assets-verify-inspector/${widget.asset.id}'),
                                                  headers: {
                                                    'Authorization':
                                                        'Bearer $token',
                                                    'Content-Type':
                                                        'application/json',
                                                  },
                                                  body: jsonEncode({
                                                    'is_verified_by_inspector':
                                                        true,
                                                    'status': 'accepted',
                                                  }),
                                                );

                                                var responseBody =
                                                    jsonDecode(response.body);

                                                if (responseBody['status'] ==
                                                    'success') {
                                                  widget.onError(
                                                      responseBody['message'],
                                                      Colors.green);
                                                  Future.delayed(
                                                      Duration(seconds: 2), () {
                                                    if (mounted) {
                                                      Navigator.of(context)
                                                          .pop(); // Kembali ke halaman sebelumnya
                                                    }
                                                  });
                                                } else {
                                                  widget.onError(
                                                      responseBody['message'],
                                                      Colors.red);
                                                }
                                              },
                                              onCancel: () async {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                String? token =
                                                    prefs.getString('token');

                                                if (token == null ||
                                                    widget.asset.id == null) {
                                                  widget.onError(
                                                      'Token not found',
                                                      Colors.red);
                                                  return;
                                                }

                                                var response = await http.put(
                                                  Uri.parse(
                                                      'https://salmon-magpie-708343.hostingersite.com/api/assets-verify-inspector/${widget.asset.id}'),
                                                  headers: {
                                                    'Authorization':
                                                        'Bearer $token',
                                                    'Content-Type':
                                                        'application/json',
                                                  },
                                                  body: jsonEncode({
                                                    'is_verified_by_inspector':
                                                        false,
                                                    'status': 'rejected',
                                                  }),
                                                );

                                                var responseBody =
                                                    jsonDecode(response.body);

                                                if (responseBody['status'] ==
                                                    'success') {
                                                  widget.onError(
                                                      responseBody['message'],
                                                      Colors.green);
                                                  Future.delayed(
                                                      Duration(seconds: 2), () {
                                                    if (mounted) {
                                                      Navigator.of(context)
                                                          .pop(); // Kembali ke halaman sebelumnya
                                                    }
                                                  });
                                                } else {
                                                  widget.onError(
                                                      responseBody['message'],
                                                      Colors.red);
                                                }
                                              },
                                            );
                                          },
                                        );
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    List<PopupMenuEntry<String>> items = [
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'hapus',
                                        child: Text('Hapus'),
                                      ),
                                    ];

                                    if (role == 'koordinator' &&
                                        widget.asset.isVerifiedByKoordinator ==
                                            false) {
                                      items.add(const PopupMenuItem<String>(
                                        value: 'verifikasi_koordinator',
                                        child: Text('Lanjutkan ke Inspektor?'),
                                      ));
                                    }

                                    if (role == 'inspektor' &&
                                        widget.asset.isVerifiedByInspektor ==
                                            false) {
                                      items.add(const PopupMenuItem<String>(
                                        value: 'verifikasi_inspektor',
                                        child: Text('Verifikasi Asset?'),
                                      ));
                                    }

                                    return items;
                                  },
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                    size: buttonSize * 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class QuarterCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.arcToPoint(
      Offset(0, 0),
      radius: Radius.circular(size.width),
      clockwise: true,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
