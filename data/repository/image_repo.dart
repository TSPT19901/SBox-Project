import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../model/image.dart';

class ImageRepo {
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  String get _baseUrl => 'https://sbox-d04a7-default-rtdb.asia-southeast1.firebasedatabase.app/users/$_uid/photos';

  Future<String> _getToken() async {
    return await _auth.currentUser!.getIdToken() ?? '';
  }

  Future<XFile?> fromGallery() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  Future<XFile?> fromCamera() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.camera);
  }

  Future<void> uploadPhoto(XFile file) async {
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    final name = file.name;
    final type = name.split('.').last;
    final size = bytes.length;
    final token = await _getToken();

    final photo = {
      'name': name,
      'base64': base64String,
      'type': type,
      'size': size,
      'createdAt': DateTime.now().toString(),
    };

    final response = await http.post(
      Uri.parse('$_baseUrl.json?auth=$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(photo),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload photo: ${response.body}');
    }

    final newKey = jsonDecode(response.body)['name'];
    await http.patch(
      Uri.parse('$_baseUrl/$newKey.json?auth=$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': newKey}),
    );
  }

  Future<List<Photo>> getPhotos() async {
    final token = await _getToken();

    final response = await http.get(Uri.parse('$_baseUrl.json?auth=$token'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch photos: ${response.body}');
    }

    final body = jsonDecode(response.body);
    if (body == null) return [];

    final data = Map<String, dynamic>.from(body);
    final photos = <Photo>[];

    data.forEach((key, value) {
      photos.add(Photo.fromMap(key, Map<String, dynamic>.from(value)));
    });

    photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return photos;
  }

  Future<void> deletePhoto(String photoId) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/$photoId.json?auth=$token'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete photo: ${response.body}');
    }
  }

  Future<void> renamePhoto(String id, String newName) async {
    final token = await _getToken();

    final response = await http.patch(
      Uri.parse('$_baseUrl/$id.json?auth=$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': newName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to rename photo: ${response.body}');
    }
  }

  Future<void> deleteAllPhotos() async {
    final token = await _getToken();

    await http.delete(Uri.parse('$_baseUrl.json?auth=$token'));
  }
}
