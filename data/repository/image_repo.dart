import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/image.dart';

class ImageRepo {
  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  DatabaseReference get _photoRef => _db.child('users/$_uid/photos');

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

    final newRef = _photoRef.push();
    final photo = Photo(
      id: newRef.key!,
      name: name,
      base64: base64String,
      type: type,
      size: size,
      createdAt: DateTime.now(),
    );
    //save to firebase database
    await newRef.set(photo.toMap());
  }

  Future<List<Photo>> getPhotos() async {
    final snapshot = await _photoRef.get();
    if (!snapshot.exists) return [];

    final photos = <Photo>[];
    final data = Map<String, dynamic>.from(snapshot.value as Map);

    data.forEach((key, value) {
      photos.add(
        Photo.fromMap(key, Map<String, dynamic>.from(value as Map)),
      );
    });

    photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return photos;
  }

  Future<void> deletePhoto(String photoId) async {
    await _photoRef.child(photoId).remove();
  }

  Future<void> deleteAllPhotos() async {
    await _photoRef.remove();
  }
}
