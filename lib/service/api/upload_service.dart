import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class UploadService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:3000"));

  // 🔹 Upload ảnh hoặc video
  Future<Map<String, dynamic>?> uploadImageOrVideo({
    required String filePath,
    required int sender,
    required int receiver,
  }) async {
    debugPrint('🔷 Starting uploadImageOrVideo');
    debugPrint('🔷 File path: $filePath');
    debugPrint('🔷 Sender: $sender, Receiver: $receiver');

    try {
      String fileName = filePath.split('/').last;
      debugPrint('🔷 File name: $fileName');

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
        "sender": sender.toString(),
        "receiver": receiver.toString(),
      });
      debugPrint('🔷 FormData created successfully');

      debugPrint('🔷 Sending request to /upload/image');
      final response = await _dio.post("/upload/image", data: formData);
      debugPrint('🔷 Response received: ${response.data}');

      return {
        "url": response.data["url"],
        "message_type": response.data["message_type"],
        "messageId": response.data["messageId"],
      };
    } catch (e) {
      debugPrint("❌ Lỗi khi upload ảnh/video: $e");
      if (e is DioException) {
        debugPrint("❌ DioError details: ${e.response?.data}");
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadFile({
    required String filePath,
    required int sender,
    required int receiver,
  }) async {
    debugPrint('🔷 Starting uploadFile');
    debugPrint('🔷 File path: $filePath');
    debugPrint('🔷 Sender: $sender, Receiver: $receiver');

    try {
      // Lấy tên file đầy đủ với đuôi
      final File file = File(filePath);
      final String fileName = path.basename(file.path);
      final String fileExtension = path.extension(file.path);

      debugPrint('🔷 File name: $fileName');
      debugPrint('🔷 File extension: $fileExtension');

      // Xác định MIME type dựa trên đuôi file
      String mimeType = _getMimeType(fileExtension);

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
        "sender": sender.toString(),
        "receiver": receiver.toString(),
        "original_file_name": fileName, // Gửi thêm tên file gốc
        "file_extension": fileExtension, // Gửi đuôi file
      });
      debugPrint('🔷 FormData created successfully');

      debugPrint('🔷 Sending request to /upload/file');
      final response = await _dio.post("/upload/file", data: formData);
      debugPrint('🔷 Response received: ${response.data}');

      return {
        "url": response.data["url"],
        "message_type": response.data["message_type"],
        "messageId": response.data["messageId"],
      };
    } catch (e) {
      debugPrint("❌ Lỗi khi upload file: $e");
      if (e is DioException) {
        debugPrint("❌ DioError details: ${e.response?.data}");
      }
      return null;
    }
  }

  // Xác định MIME type dựa trên đuôi file
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
        return 'application/octet-stream'; // Mặc định cho các file khác
    }
  }
}
