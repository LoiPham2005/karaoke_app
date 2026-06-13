// ════════════════════════════════════════════════════════════════
// 📁 lib/core/services/media/media_service.dart
//
// MediaService — service tổng hợp cho ảnh / video / file:
//   • PICK   — chọn ảnh/video từ gallery hoặc camera (upload)
//   • SAVE   — tải ảnh/video về thư viện máy (gallery)
//   • DOWNLOAD — tải file bất kỳ về bộ nhớ app (có progress)
//   • OPEN   — mở file bằng app hệ thống (PDF, doc, ảnh...)
//
// Cách dùng nhanh:
//   final file = await media.pickImage(source: ImageSource.gallery);
//   await media.saveImageToGallery('https://.../photo.jpg', context: context);
//   await media.openFile(file.path);
//   await media.downloadAndOpenFile('https://.../report.pdf');
// ════════════════════════════════════════════════════════════════
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:karaoke/core/base/di/injection.dart';
import 'package:karaoke/core/services/permission/permission_service.dart';
import 'package:karaoke/core/services/utils/logger.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Shortcut toàn cục — `media.pickImage()`, `media.openFile()`...
MediaService get media => getIt<MediaService>();

/// Callback tiến trình tải file: (đã tải, tổng dung lượng) tính bằng byte.
typedef DownloadProgress = void Function(int received, int total);

@LazySingleton()
class MediaService {
  static const String _tag = 'MEDIA';

  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  PermissionService get _permission => getIt<PermissionService>();

  // ═══════════════════════════════════════════════════════════════
  // PICK — chọn ảnh/video (upload)
  // ═══════════════════════════════════════════════════════════════

  /// Chọn 1 ảnh từ gallery hoặc camera. Tự xin quyền tương ứng.
  ///
  /// [imageQuality] 0-100, [source] mặc định gallery.
  /// Trả `null` nếu user huỷ hoặc không có quyền.
  Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    BuildContext? context,
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      if (!await _ensurePickPermission(source, context)) return null;

      final picked = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      return picked == null ? null : File(picked.path);
    } catch (e, s) {
      Logger.error('pickImage failed', error: e, stackTrace: s, tag: _tag);
      return null;
    }
  }

  /// Chọn nhiều ảnh từ gallery. [limit] giới hạn số lượng trả về.
  Future<List<File>> pickImages({
    BuildContext? context,
    int limit = 10,
    int imageQuality = 85,
  }) async {
    try {
      if (!await _permission.requestPhotos(context)) return [];

      final picked = await _picker.pickMultiImage(imageQuality: imageQuality);
      return picked.take(limit).map((x) => File(x.path)).toList();
    } catch (e, s) {
      Logger.error('pickImages failed', error: e, stackTrace: s, tag: _tag);
      return [];
    }
  }

  /// Chọn 1 video từ gallery hoặc camera. Tự xin quyền tương ứng.
  ///
  /// [maxDuration] giới hạn thời lượng quay khi dùng camera.
  Future<File?> pickVideo({
    ImageSource source = ImageSource.gallery,
    BuildContext? context,
    Duration? maxDuration,
  }) async {
    try {
      if (!await _ensurePickPermission(source, context)) return null;

      final picked = await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );
      return picked == null ? null : File(picked.path);
    } catch (e, s) {
      Logger.error('pickVideo failed', error: e, stackTrace: s, tag: _tag);
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SAVE — tải ảnh/video về thư viện máy (gallery)
  // ═══════════════════════════════════════════════════════════════

  /// Lưu ảnh vào thư viện máy.
  ///
  /// [pathOrUrl] có thể là URL mạng hoặc đường dẫn file local.
  /// [albumName] tên album/thư mục muốn lưu vào (tuỳ chọn).
  /// Trả `true` nếu lưu thành công.
  Future<bool> saveImageToGallery(
    String pathOrUrl, {
    String? albumName,
    BuildContext? context,
  }) {
    return _saveToGallery(
      pathOrUrl,
      albumName: albumName,
      context: context,
      isVideo: false,
    );
  }

  /// Lưu video vào thư viện máy. Tham số giống [saveImageToGallery].
  Future<bool> saveVideoToGallery(
    String pathOrUrl, {
    String? albumName,
    BuildContext? context,
  }) {
    return _saveToGallery(
      pathOrUrl,
      albumName: albumName,
      context: context,
      isVideo: true,
    );
  }

  Future<bool> _saveToGallery(
    String pathOrUrl, {
    required bool isVideo,
    String? albumName,
    BuildContext? context,
  }) async {
    try {
      // iOS cần quyền thêm vào thư viện ảnh; Android dùng MediaStore.
      if (Platform.isIOS && !await _permission.requestPhotos(context)) {
        return false;
      }

      final saved = isVideo
          ? await GallerySaver.saveVideo(pathOrUrl, albumName: albumName)
          : await GallerySaver.saveImage(pathOrUrl, albumName: albumName);

      if (saved ?? false) {
        Logger.success('Đã lưu ${isVideo ? 'video' : 'ảnh'} vào thư viện', tag: _tag);
        return true;
      }
      Logger.warning('Lưu vào thư viện thất bại: $pathOrUrl', tag: _tag);
      return false;
    } catch (e, s) {
      Logger.error('saveToGallery failed', error: e, stackTrace: s, tag: _tag);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // DOWNLOAD — tải file bất kỳ về bộ nhớ app
  // ═══════════════════════════════════════════════════════════════

  /// Tải 1 file từ [url] về thư mục riêng của app.
  ///
  /// [fileName] tên file lưu (mặc định lấy từ url).
  /// [onProgress] callback tiến trình tải.
  /// Trả về [File] đã tải, hoặc `null` nếu lỗi.
  Future<File?> downloadFile(
    String url, {
    String? fileName,
    DownloadProgress? onProgress,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final name = fileName ?? _fileNameFromUrl(url);
      final savePath = '${dir.path}/$name';

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) onProgress?.call(received, total);
        },
      );

      Logger.success('Đã tải file: $savePath', tag: _tag);
      return File(savePath);
    } catch (e, s) {
      Logger.error('downloadFile failed', error: e, stackTrace: s, tag: _tag);
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // OPEN — mở file bằng app hệ thống
  // ═══════════════════════════════════════════════════════════════

  /// Mở 1 file local ([path]) bằng ứng dụng mặc định của thiết bị.
  /// Trả `true` nếu mở được.
  Future<bool> openFile(String path) async {
    try {
      if (!File(path).existsSync()) {
        Logger.warning('File không tồn tại: $path', tag: _tag);
        return false;
      }
      final result = await OpenFilex.open(path);
      Logger.info('openFile: ${result.type} — ${result.message}', tag: _tag);
      return result.type == ResultType.done;
    } catch (e, s) {
      Logger.error('openFile failed', error: e, stackTrace: s, tag: _tag);
      return false;
    }
  }

  /// Tải file từ [url] về rồi mở luôn bằng app hệ thống.
  Future<bool> downloadAndOpenFile(
    String url, {
    String? fileName,
    DownloadProgress? onProgress,
  }) async {
    final file = await downloadFile(url, fileName: fileName, onProgress: onProgress);
    if (file == null) return false;
    return openFile(file.path);
  }

  // ═══════════════════════════════════════════════════════════════
  // COMPRESS — nén ảnh trước khi upload
  // ═══════════════════════════════════════════════════════════════

  /// Nén ảnh để giảm dung lượng trước khi upload.
  /// [quality] 0-100. Trả về file đã nén, hoặc `null` nếu lỗi.
  Future<File?> compressImage(
    File file, {
    int quality = 85,
    int minWidth = 1920,
    int minHeight = 1080,
  }) async {
    try {
      final targetPath = '${file.parent.path}/cmp_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );
      return result == null ? null : File(result.path);
    } catch (e, s) {
      Logger.error('compressImage failed', error: e, stackTrace: s, tag: _tag);
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // INTERNAL
  // ═══════════════════════════════════════════════════════════════

  /// Xin quyền phù hợp với nguồn pick (camera vs gallery).
  Future<bool> _ensurePickPermission(ImageSource source, BuildContext? context) {
    return source == ImageSource.camera
        ? _permission.requestCamera(context)
        : _permission.requestPhotos(context);
  }

  String _fileNameFromUrl(String url) {
    final clean = url.split('?').first;
    final last = clean.split('/').last;
    if (last.isNotEmpty) return last;
    return 'file_${DateTime.now().millisecondsSinceEpoch}';
  }
}
