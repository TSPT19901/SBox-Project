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
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  Future<void> _pickFromGallery() async {
    final file = await _imageRepo.fromGallery();
    if (file != null) {
      setState(() => _isLoading = true);
      await _imageRepo.uploadPhoto(file);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Photo',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.deepPurple),
                  SizedBox(height: 16),
                  Text(
                    'Uploading...',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a source',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  const SizedBox(height: 32),
                  sourceCard(
                    icon: Icons.camera_alt_outlined,
                    iconBg: const Color(0xFFEDE7F6),
                    iconColor: Colors.deepPurple,
                    title: 'Take a Photo',
                    subtitle: 'Use your camera to capture a new photo',
                    onTap: _pickFromCamera,
                  ),
                  const SizedBox(height: 16),
                  sourceCard(
                    icon: Icons.photo_library_outlined,
                    iconBg: const Color(0xFFFCE4EC),
                    iconColor: Colors.pinkAccent,
                    title: 'Choose from Gallery',
                    subtitle: 'Pick an existing photo from your device',
                    onTap: _pickFromGallery,
                  ),
                ],
              ),
            ),
    );
  }

  Widget sourceCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: iconBg,
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
