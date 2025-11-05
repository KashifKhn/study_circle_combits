import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:study_circle/utils/logger.dart';

/// Cloudinary configuration and upload service
class CloudinaryConfig {
  // Cloudinary credentials
  static const String cloudName = 'dwi4kicqh';
  static const String apiKey = '789971392183486';
  static const String apiSecret = 'El-C5nWZm2CMklFUXmNqbPZa__0';
  static const String uploadPreset = 'study_circle_uploads';

  // Base URL for Cloudinary API
  static const String baseUrl = 'https://api.cloudinary.com/v1_1/$cloudName';

  /// Upload an image to Cloudinary
  /// Returns the secure URL of the uploaded image
  static Future<String?> uploadImage(File imageFile) async {
    try {
      AppLogger.info('Uploading image to Cloudinary...');

      final url = Uri.parse('$baseUrl/image/upload');
      final request = http.MultipartRequest('POST', url);

      // Add upload preset and file
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'study_circle/images';

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Send request
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseString);
        final secureUrl = jsonResponse['secure_url'] as String;
        AppLogger.info('Image uploaded successfully: $secureUrl');
        return secureUrl;
      } else {
        AppLogger.error('Failed to upload image', responseString);
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error uploading image to Cloudinary', e, stackTrace);
      return null;
    }
  }

  /// Upload a PDF to Cloudinary
  /// Returns the secure URL of the uploaded PDF
  static Future<String?> uploadPDF(File pdfFile) async {
    try {
      AppLogger.info('Uploading PDF to Cloudinary...');

      final url = Uri.parse('$baseUrl/raw/upload');
      final request = http.MultipartRequest('POST', url);

      // Add upload preset and file
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'study_circle/pdfs';

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', pdfFile.path),
      );

      // Send request
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseString);
        final secureUrl = jsonResponse['secure_url'] as String;
        AppLogger.info('PDF uploaded successfully: $secureUrl');
        return secureUrl;
      } else {
        AppLogger.error('Failed to upload PDF', responseString);
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error uploading PDF to Cloudinary', e, stackTrace);
      return null;
    }
  }

  /// Upload a video to Cloudinary
  /// Returns the secure URL of the uploaded video
  static Future<String?> uploadVideo(File videoFile) async {
    try {
      AppLogger.info('Uploading video to Cloudinary...');

      final url = Uri.parse('$baseUrl/video/upload');
      final request = http.MultipartRequest('POST', url);

      // Add upload preset and file
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'study_circle/videos';

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', videoFile.path),
      );

      // Send request
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseString);
        final secureUrl = jsonResponse['secure_url'] as String;
        AppLogger.info('Video uploaded successfully: $secureUrl');
        return secureUrl;
      } else {
        AppLogger.error('Failed to upload video', responseString);
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error uploading video to Cloudinary', e, stackTrace);
      return null;
    }
  }

  /// Upload any file type to Cloudinary
  /// Automatically detects the file type and uploads accordingly
  static Future<String?> uploadFile(File file) async {
    final extension = file.path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return uploadImage(file);
    } else if (extension == 'pdf') {
      return uploadPDF(file);
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      return uploadVideo(file);
    } else {
      // Upload as raw file
      return uploadPDF(file); // Use raw upload endpoint
    }
  }

  /// Get an optimized URL for an image
  /// Adds transformation parameters for better performance
  static String getOptimizedImageUrl(
    String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    final transformations = <String>[];

    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_auto');

    final transformation = transformations.join(',');
    return 'https://res.cloudinary.com/$cloudName/image/upload/$transformation/$publicId';
  }
}
