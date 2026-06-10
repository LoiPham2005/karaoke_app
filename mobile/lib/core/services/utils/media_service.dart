// ════════════════════════════════════════════════════════════════
// 📁 lib/core/services/media_service.dart (CHỈ MEDIA/GALLERY)
// ════════════════════════════════════════════════════════════════
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:flutter_base/core/common/utils/logger.dart';

/// Media service for gallery operations
///
/// Responsibilities:
/// - Save images to gallery
/// - Save videos to gallery
class MediaService {
  MediaService._();
  static final MediaService _instance = MediaService._();
  factory MediaService() => _instance;

  /// Save image to gallery
  ///
  /// [filePath] can be local file path or network URL
  Future<bool> saveImage(String filePath, {String? albumName}) async {
    try {
      final result = await GallerySaver.saveImage(
        filePath,
        albumName: albumName ?? 'MyApp',
        toDcim: true,
      );

      if (result == true) {
        Logger.success('Image saved to gallery');
        return true;
      }

      Logger.warning('Failed to save image to gallery');
      return false;
    } catch (e, stackTrace) {
      Logger.error('Error saving image', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Save video to gallery
  ///
  /// [filePath] can be local file path or network URL
  Future<bool> saveVideo(String filePath, {String? albumName}) async {
    try {
      final result = await GallerySaver.saveVideo(
        filePath,
        albumName: albumName ?? 'MyApp',
        toDcim: true,
      );

      if (result == true) {
        Logger.success('Video saved to gallery');
        return true;
      }

      Logger.warning('Failed to save video to gallery');
      return false;
    } catch (e, stackTrace) {
      Logger.error('Error saving video', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
