import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '/data/repository/image_repo.dart';
import '/model/image.dart';

class PhotoDetailScreen extends StatefulWidget {
  final Photo photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  final imageRepo = ImageRepo();
  bool _isDeleting = false;
  bool _isSaving = false;

  String _formatSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  Future<void> _saveToGallery() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied. Cannot save photo.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final bytes = base64Decode(widget.photo.base64);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/${widget.photo.name}.${widget.photo.type}',
      );
      await tempFile.writeAsBytes(bytes);
      await MediaStore().saveFile(
        tempFilePath: tempFile.path,
        dirType: DirType.photo,
        dirName: DirName.pictures,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Photo saved to gallery!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete photo?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      await imageRepo.deletePhoto(widget.photo.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }
  Future<void> _renamePhoto() async {
    final controller = TextEditingController(text: widget.photo.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Photo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Photo name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text(
              'Rename',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != widget.photo.name) {
      await imageRepo.renamePhoto(widget.photo.id, newName);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Photo renamed!')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = base64Decode(widget.photo.base64);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.photo.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: InteractiveViewer(
                    child: Image.memory(imageBytes, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.image_outlined, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.photo.type.toUpperCase()} • ${_formatSize(widget.photo.size)} • Added today',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionBtn(
                  icon: Icons.drive_file_rename_outline,
                  label: 'Rename',
                  color: Colors.orange,
                  bg: const Color(0xFFFFF3E0),
                  onTap: _renamePhoto,
                ),
                _actionBtn(
                  icon: _isSaving ? null : Icons.download_outlined,
                  label: 'Save',
                  color: Colors.deepPurple,
                  bg: const Color(0xFFEDE7F6),
                  onTap: _isSaving ? () {} : _saveToGallery,
                  isLoading: _isSaving,
                ),
                _actionBtn(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  color: Colors.redAccent,
                  bg: const Color(0xFFFFEBEE),
                  onTap: _isDeleting ? () {} : _confirmDelete,
                  isLoading: _isDeleting,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData? icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: bg,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
