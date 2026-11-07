import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  final SupabaseClient _supabase;

  StorageService({SupabaseClient? client})
      : _supabase = client ?? SupabaseService.client;

  String _resolveContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// Mengunggah gambar avatar ke Supabase Storage bucket 'avatars' dengan nama file unik bertanggal
  Future<String?> uploadAvatar({
    required XFile file,
    required String userId,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final cleanExtension = file.name.split('.').last.toLowerCase();
      final contentType = _resolveContentType(cleanExtension);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$userId/avatar_$timestamp.$cleanExtension';

      // 1. Bersihkan file avatar lama di folder milik user untuk menghemat ruang penyimpanan
      try {
        final existingFiles = await _supabase.storage.from('avatars').list(path: userId);
        if (existingFiles.isNotEmpty) {
          final pathsToRemove = existingFiles.map((f) => '$userId/${f.name}').toList();
          await _supabase.storage.from('avatars').remove(pathsToRemove);
        }
      } catch (cleanupError) {
        debugPrint('StorageService: Non-fatal old avatar cleanup notice: $cleanupError');
      }

      // 2. Unggah file baru dengan nama unik untuk mencegah tabrakan cache CDN dan Flutter ImageCache
      await _supabase.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: contentType,
            ),
          );

      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);

      // 3. Simpan URL baru ke kolom avatar_url di tabel profiles
      await _supabase
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      return publicUrl;
    } catch (e, stack) {
      debugPrint('StorageService.uploadAvatar error: $e\n$stack');
      return null;
    }
  }
}
