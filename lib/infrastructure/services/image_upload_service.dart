import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImageUploadService {
  /// Upload avatar image to the backend.
  /// [url] should be the full PATCH endpoint (e.g. https://domain/api/auth/me/)
  /// Backend expects: PATCH with multipart field 'profile.avatar'
  Future<String?> uploadImage(String url, File imageFile, {String? token}) async {
    try {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('PATCH', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      final fileExtension = imageFile.path.split('.').last;
      final mimeType = _mimeType(fileExtension);

      final multipartFile = await http.MultipartFile.fromPath(
        'profile.avatar',
        imageFile.path,
        contentType: MediaType('image', mimeType),
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        // Backend returns the updated profile with avatar_url
        return body['avatar_url']?.toString() ??
            body['profile']?['avatar_url']?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _mimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'webp':
        return 'webp';
      default:
        return 'jpeg';
    }
  }
}
