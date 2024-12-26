import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerField extends StatelessWidget {
  final String label;
  final XFile? image;
  final Function(XFile?) onImagePicked;
  final Function(File) showImageDialog;
  final Future<void> Function(ImageSource, Function(XFile?)) pickImage;

  const ImagePickerField({
    Key? key,
    required this.label,
    required this.image,
    required this.onImagePicked,
    required this.showImageDialog,
    required this.pickImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF006A67))),
        SizedBox(height: 8),
        GestureDetector(
          onTap:
              image != null ? () => showImageDialog(File(image!.path)) : null,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF006A67), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: image == null
                ? Container(
                    height: 100, // Set a shorter height for the preview
                    child: Center(
                        child: Text("Tidak ada foto",
                            style: TextStyle(color: Colors.black))),
                  )
                : AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(image!.path),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
          ),
        ),
        if (image != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Klik foto untuk melihat lebih detail",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => pickImage(ImageSource.gallery, onImagePicked),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF006A67),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: Size(double.infinity, 50), // Make button full width
          ),
          child: Text('Pilih foto', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
