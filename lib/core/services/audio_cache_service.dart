// lib/core/services/audio_cache_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AudioCacheService {
  static final DefaultCacheManager _cacheManager = DefaultCacheManager();

  /// Lädt eine Audiodatei aus dem Cache oder streamt & speichert sie herunter
  static Future<String> getOrFetchAudioPath(String url) async {
    if (kIsWeb || url.isEmpty || !url.startsWith('http')) {
      return url;
    }

    try {
      final FileInfo? fileInfo = await _cacheManager.getFileFromCache(url);
      if (fileInfo != null && await fileInfo.file.exists()) {
        return fileInfo.file.path;
      }

      final File downloadedFile = await _cacheManager.getSingleFile(url);
      return downloadedFile.path;
    } catch (e) {
      debugPrint('AudioCacheService Fehler: $e. Fallback auf Direkt-URL.');
      return url;
    }
  }

  /// Bereinigt alte gecachte Audio-Dateien
  static Future<void> clearAudioCache() async {
    try {
      await _cacheManager.emptyCache();
      debugPrint('Audio-Cache erfolgreich geleert.');
    } catch (e) {
      debugPrint('Fehler beim Leeren des Audio-Caches: $e');
    }
  }
}