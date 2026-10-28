import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  final SupabaseClient _supabase;

  StorageService({SupabaseClient? client})
      : _supabase = client ?? SupabaseService.client;

  /// Mengunggah gambar avatar ke Supabase Storage bucket 'avatars'
  Future<String?> uploadAvatar({
    required XFile file,
    required String userId,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final fileExtension = file.name.split('.').last;
      final filePath = '$userId/avatar.$fileExtension';

      await _supabase.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);

      // Simpan juga ke kolom avatar_url di tabel profiles
      await _supabase
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      return publicUrl;
    } catch (_) {
      return null;
    }
  }
}
