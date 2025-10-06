import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef PhotoSelectionCallback = void Function(File image);

class ImagePriseProfil extends StatefulWidget {
  final PhotoSelectionCallback onPhotoSelectionne;
  final String? imageUrl;

  const ImagePriseProfil({
    super.key,
    required this.onPhotoSelectionne,
    this.imageUrl,
  });

  @override
  State<ImagePriseProfil> createState() => _ImagePriseProfilState();
}

class _ImagePriseProfilState extends State<ImagePriseProfil> {
  File? _image;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.imageUrl;

    // Ouvre directement le choix caméra / galerie à l'affichage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPickerDialog();
    });
  }

  Future<void> _showPickerDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Caméra'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _imageUrl = null; // on remplace l'ancienne image
      });
      widget.onPhotoSelectionne(_image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 150,
      child: _image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(75),
              child: Image.file(_image!, fit: BoxFit.cover),
            )
          : (_imageUrl != null && _imageUrl!.isNotEmpty)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(75),
              child: Image.network(_imageUrl!, fit: BoxFit.cover),
            )
          : Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(75),
                border: Border.all(color: Colors.grey),
              ),
              child: const Center(
                child: Icon(Icons.person, size: 80, color: Colors.grey),
              ),
            ),
    );
  }
}
