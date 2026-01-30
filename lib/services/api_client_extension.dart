import 'dart:io';
import 'package:bank_sha/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bank_sha/utils/api_routes.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

extension ApiClientExtension on ApiClient {
  /// Upload file to server
  ///
  /// Parameters:
  /// - endpoint: API endpoint (e.g. '/api/user/upload-profile-image')
  /// - fieldName: Form field name for the file (e.g. 'profile_image')
  /// - file: File to upload
  /// - extraData: Additional form fields to send with the file
  Future<Map<String, dynamic>?> uploadFile(
    String endpoint,
    String fieldName,
    File file, {
    Map<String, String>? extraData,
  }) async {
    try {
      final token = await getToken();

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiRoutes.baseUrl}$endpoint'),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      // Add extra fields if any
      if (extraData != null) {
        request.fields.addAll(extraData);
      }

      // Detect mime type
      final mimeType = lookupMimeType(file.path);
      final fileExtension = path.extension(file.path).replaceAll('.', '');

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: mimeType != null
              ? MediaType.parse(mimeType)
              : MediaType('application', fileExtension),
        ),
      );

      // Send request
      final streamedResponse = await request.send();

      // Convert streamed response to response
      final response = await http.Response.fromStream(streamedResponse);

      // Parse response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Upload failed: ${response.statusCode}',
          'data': response.body,
        };
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}
