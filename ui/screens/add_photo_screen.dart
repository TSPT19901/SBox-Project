import 'package:flutter/material.dart';
import '../../data/repository/image_repo.dart';

class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({super.key});

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  final _imageRepo = ImageRepo();
  bool _isLoading = false;

  Future<void> _pickFromCamera() async {
    final file = await _imageRepo.fromCamera();
    if (file != null) {
      setState(() => _isLoading = true);
      await _imageRepo.uploadPhoto(file);
      Navigator.pop(context, true);
    }
  }

  Future<void> _pickFromGallery() async {
    final file = await _imageRepo.fromGallery();
    if (file != null) {
      setState(() => _isLoading = true);
      await _imageRepo.uploadPhoto(file);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Photo')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take a Photo'),
                  ),

                  SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                  ),
                ],
              ),
            ),
    );
  }
}
