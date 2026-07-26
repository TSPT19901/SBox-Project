import 'dart:convert';
import 'dart:io';
import 'settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/repository/image_repo.dart';
import '../../model/image.dart';
import 'add_photo_screen.dart';
import 'photo_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final imageRepo = ImageRepo();
  List<Photo> _photos = [];
  bool _isLoading = false;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    final photo = await imageRepo.getPhotos();
    setState(() {
      _photos = photo;
      _isLoading = false;
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _selectionMode = true;
      _selectedIds.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }
  
  Future<void> _saveSelected() async {
    final selectedPhotos = _photos
        .where((photo) => _selectedIds.contains(photo.id))
        .toList();

    if (selectedPhotos.isEmpty) {
      return;
    }

    int savedCount = 0;
    int failedCount = 0;

    try {
      final tempDirectory = await getTemporaryDirectory();

      for (final photo in selectedPhotos) {
        try {
          // Convert the Base64 text from Firebase back into image bytes.
          final imageBytes = base64Decode(photo.base64);

          // photo.name normally already includes the extension.
          final tempFile = File('${tempDirectory.path}/${photo.name}');

          // Create a temporary image file.
          await tempFile.writeAsBytes(imageBytes, flush: true);

          // Save the temporary image into the phone's Pictures folder.
          await MediaStore().saveFile(
            tempFilePath: tempFile.path,
            dirType: DirType.photo,
            dirName: DirName.pictures,
          );

          savedCount++;
        } catch (error) {
          failedCount++;

          debugPrint('Unable to save ${photo.name}: $error');
        }
      }

      if (!mounted) return;

      _exitSelectionMode();

      String resultMessage = '$savedCount photo(s) saved to the gallery.';

      if (failedCount > 0) {
        resultMessage = '$savedCount photo(s) saved, $failedCount failed.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resultMessage)));
    } catch (error) {
      debugPrint('Save selected photos error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save photos: $error')));
    }
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _actionButton(
              icon: Icons.add,
              label: 'Add photos',
              iconColor: Colors.deepPurple,
              iconBg: const Color(0xFFEDE7F6),
              onTap: _uploadPhoto,
            ),
            const SizedBox(width: 10),
            _actionButton(
              icon: Icons.download_outlined,
              label: 'Save photo',
              iconColor: Colors.pinkAccent,
              iconBg: const Color(0xFFFCE4EC),
              onTap: _enterSelectionMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: iconBg,
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadPhoto() async {
    final uploaded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPhotoScreen()),
    );
    if (uploaded == true) await _loadPhotos();
  }

  Future<void> openDetail(Photo photo) async {
    final deleted = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhotoDetailScreen(photo: photo)),
    );
    if (deleted == true) await _loadPhotos();
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Welcome !!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final photosChanged =
                                    await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SettingsScreen(),
                                      ),
                                    );

                                if (photosChanged == true) {
                                  await _loadPhotos();
                                }
                              },
                              child: const CircleAvatar(
                                radius: 26,
                                backgroundColor: Color(0xFFEAE4FF),
                                backgroundImage: AssetImage(
                                  'assets/images/bear_avatar.png',
                                ),
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent added',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_selectionMode)
                              TextButton(
                                onPressed: _exitSelectionMode,
                                child: const Text('Cancel'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _photos.isEmpty
                            ? const Center(
                                child: Text(
                                  'No photos yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : Column(
                                children: _photos.map((photo) {
                                  final imageBytes = base64Decode(photo.base64);
                                  final isSelected = _selectedIds.contains(
                                    photo.id,
                                  );
                                  return GestureDetector(
                                    onTap: () {
                                      if (_selectionMode) {
                                        _toggleSelect(photo.id);
                                      } else {
                                        openDetail(photo);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFEDE7F6)
                                              : null,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.deepPurple
                                                : Colors.grey.shade200,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    photo.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${_relativeDay(photo.createdAt)} • Safe',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (_selectionMode)
                                              Checkbox(
                                                value: isSelected,
                                                onChanged: (_) =>
                                                    _toggleSelect(photo.id),
                                                activeColor: Colors.deepPurple,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                  if (_selectionMode)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _selectedIds.isEmpty
                              ? null
                              : _saveSelected,
                          icon: const Icon(Icons.save_alt_outlined),
                          label: Text(
                            _selectedIds.isEmpty
                                ? 'Select photos to save'
                                : 'Save ${_selectedIds.length} photo(s)',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
