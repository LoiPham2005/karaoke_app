// ════════════════════════════════════════════════════════════════
// 📁 lib/core/services/file_service.dart (CHỈ FILE OPERATIONS)
// ════════════════════════════════════════════════════════════════
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_base/core/common/utils/logger.dart';

/// File service for general file operations
///
/// Responsibilities:
/// - Download files
/// - Open files
/// - File utilities (exists, size, delete)
class FileService {
  factory FileService() => _instance;
  FileService._();
  static final FileService _instance = FileService._();

  final Dio _dio = Dio();

  // ═══════════════════════════════════════════════════════════════
  // DOWNLOAD OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Download file from URL
  Future<File?> downloadFile(
    String url, {
    String? fileName,
    String? folderName,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final dir =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/${folderName ?? "MyAppFiles"}');

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final filePath = '${folder.path}/${fileName ?? url.split('/').last}';

      await _dio.download(url, filePath, onReceiveProgress: onProgress);

      Logger.info('File downloaded: $filePath');
      return File(filePath);
    } catch (e, stackTrace) {
      Logger.error('Failed to download file', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Open file with system default app
  Future<bool> openFile(File file) async {
    try {
      if (!await file.exists()) {
        Logger.warning('File does not exist: ${file.path}');
        return false;
      }

      final result = await OpenFilex.open(file.path);
      return result.type == ResultType.done;
    } catch (e) {
      Logger.error('Failed to open file', error: e);
      return false;
    }
  }

  /// Download and open immediately
  Future<bool> downloadAndOpen(
    String url, {
    String? fileName,
    String? folderName,
    void Function(int, int)? onProgress,
  }) async {
    final file = await downloadFile(
      url,
      fileName: fileName,
      folderName: folderName,
      onProgress: onProgress,
    );
    return file != null ? await openFile(file) : false;
  }

  // ═══════════════════════════════════════════════════════════════
  // FILE UTILITIES
  // ═══════════════════════════════════════════════════════════════

  /// Check if file exists
  Future<bool> exists(String path) async {
    try {
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }

  /// Get file size in bytes
  Future<int?> getSize(String path) async {
    try {
      return await File(path).length();
    } catch (_) {
      return null;
    }
  }

  /// Get file size with human-readable format
  Future<String> getSizeFormatted(String path) async {
    final bytes = await getSize(path);
    if (bytes == null) return 'Unknown';

    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Delete file
  Future<bool> delete(String path) async {
    try {
      await File(path).delete();
      Logger.info('File deleted: $path');
      return true;
    } catch (e) {
      Logger.error('Failed to delete file', error: e);
      return false;
    }
  }

  /// Get file extension
  String getExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// Check file type
  bool isImage(String path) {
    final ext = getExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(ext);
  }

  bool isVideo(String path) {
    final ext = getExtension(path);
    return ['mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv', 'm4v'].contains(ext);
  }

  bool isPdf(String path) {
    return getExtension(path) == 'pdf';
  }

  bool isDocument(String path) {
    final ext = getExtension(path);
    return [
      'doc',
      'docx',
      'txt',
      'pdf',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
    ].contains(ext);
  }
}
