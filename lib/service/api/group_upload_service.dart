import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class GroupUploadService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:3000"));

  Future<Map<String, dynamic>?> uploadGroupImageOrVideo({
    required String filePath,
    required int sender,
    required int groupId,
  }) async {
    debugPrint('🔷 Starting uploadGroupImageOrVideo');
    debugPrint('🔷 File path: $filePath');
    debugPrint('🔷 Sender: $sender, GroupId: $groupId');

    try {
      String fileName = filePath.split('/').last;
      debugPrint('🔷 File name: $fileName');

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
        "sender": sender.toString(),
        "groupId": groupId.toString(),
      });
      debugPrint('🔷 FormData created successfully');

      debugPrint('🔷 Sending request to /upload/group/image');
      final response = await _dio.post("/upload/group/image", data: formData);
      debugPrint('🔷 Response received: ${response.data}');

      return {
        "url": response.data["url"],
        "message_type": response.data["message_type"],
        "messageId": response.data["messageId"],
      };
    } catch (e) {
      debugPrint("❌ Lỗi khi upload ảnh/video nhóm: $e");
      if (e is DioException) {
        debugPrint("❌ DioError details: ${e.response?.data}");
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadGroupFile({
    required String filePath,
    required int sender,
    required int groupId,
  }) async {
    debugPrint('🔷 Starting uploadGroupFile');
    debugPrint('🔷 File path: $filePath');
    debugPrint('🔷 Sender: $sender, GroupId: $groupId');

    try {
      final File file = File(filePath);
      final String fileName = path.basename(file.path);
      final String fileExtension = path.extension(file.path);

      debugPrint('🔷 File name: $fileName');
      debugPrint('🔷 File extension: $fileExtension');

      String mimeType = _getMimeType(fileExtension);

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
        "sender": sender.toString(),
        "groupId": groupId.toString(),
        "original_file_name": fileName,
        "file_extension": fileExtension,
      });
      debugPrint('🔷 FormData created successfully');

      debugPrint('🔷 Sending request to /upload/group/file');
      final response = await _dio.post("/upload/group/file", data: formData);
      debugPrint('🔷 Response received: ${response.data}');

      return {
        "url": response.data["url"],
        "message_type": response.data["message_type"],
        "messageId": response.data["messageId"],
        "file_name": response.data["file_name"],
        "file_extension": response.data["file_extension"],
      };
    } catch (e) {
      debugPrint("❌ Lỗi khi upload file nhóm: $e");
      if (e is DioException) {
        debugPrint("❌ DioError details: ${e.response?.data}");
      }
      return null;
    }
  }

  String _getMimeType(String extension) {
    extension = extension.toLowerCase();
    switch (extension) {
      case '.pdf':
        return 'application/pdf';
      case '.doc':
      case '.docx':
        return 'application/msword';
      case '.xls':
      case '.xlsx':
        return 'application/vnd.ms-excel';
      case '.ppt':
      case '.pptx':
        return 'application/vnd.ms-powerpoint';
      case '.txt':
        return 'text/plain';
      case '.zip':
        return 'application/zip';
      case '.rar':
        return 'application/x-rar-compressed';
      case '.7z':
        return 'application/x-7z-compressed';
      default:
        return 'application/octet-stream';
    }
  }
}
