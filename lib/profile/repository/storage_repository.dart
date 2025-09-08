import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageRepository {
  final _picker = ImagePicker();

  /// Picks an image from the gallery and returns a File
  Future<File?> pickImageFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    return picked != null ? File(picked.path) : null;
  }

  /// Uploads the profile picture to Firebase Storage and returns the download URL
  Future<String> uploadProfilePicture(File file) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref =
          FirebaseStorage.instance.ref().child('profile_pictures/$uid.jpg');

      // Upload the file to Firebase Storage
      await ref.putFile(file);

      // Get the download URL of the uploaded image
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Error uploading profile picture: $e");
    }
  }
}
