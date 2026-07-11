import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/services/image_upload_service.dart';

class ImageUploadNotifier extends StateNotifier<bool> {
  ImageUploadNotifier() : super(false);

  Future<String?> uploadUserAvatar(File image, String url, String token) async {
    state = true;
    try {
      final service = ImageUploadService();
      final result = await service.uploadImage(url, image, token: token);
      return result;
    } finally {
      state = false;
    }
  }
}

final imageUploadProvider = StateNotifierProvider<ImageUploadNotifier, bool>((ref) {
  return ImageUploadNotifier();
});
