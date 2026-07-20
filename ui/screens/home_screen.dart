import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:real_final_project/data/repository/image_repo.dart';
import 'package:real_final_project/model/image.dart';
import 'package:real_final_project/ui/screens/add_photo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final imageRepo = ImageRepo();
  List<Photo> _photos = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });

    final photo = await imageRepo.getPhotos();

    setState(() {
      _photos = photo;
      _isLoading = false;
    });
  }

  Future<void> _uploadPhoto() async {
    final uploaded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPhotoScreen()),
    );
    if (uploaded == true) {
      await _loadPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? const Center(child: Text('No photos yet. Click upload to add your photo'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    final photo = _photos[index];
                    final imageBytes = base64Decode(photo.base64);
                    return Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadPhoto,
        child: const Icon(Icons.add),
      ),
    );
  }
}
