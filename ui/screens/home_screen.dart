import 'dart:convert';

import 'package:flutter/material.dart';
import '/data/repository/image_repo.dart';
import '/model/image.dart';
import '/ui/screens/add_photo_screen.dart';
import '/ui/screens/photo_detail_screen.dart';

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

  Future<void> openDetail(Photo photo) async {
    final deleted = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhotoDetailScreen(photo: photo)),
    );
    if (deleted == true) {
      await _loadPhotos();
    }
  }

  String _relativeDay(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
          ? const Center(
              child: Text('No photos yet. Click upload to add your photo'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                final imageBytes = base64Decode(photo.base64);

                return GestureDetector(
                  onTap: () {
                    openDetail(photo);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              imageBytes,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  photo.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_relativeDay(photo.createdAt)} • Safe',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
