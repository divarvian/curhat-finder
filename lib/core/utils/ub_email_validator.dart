class UbEmailValidator {
  UbEmailValidator._();

  static const String ubDomainSuffix = 'ub.ac.id';
  static const String studentDomain = 'student.ub.ac.id';
  static const String invalidDomainMessage =
      'Gunakan email resmi UB (contoh: @student.ub.ac.id atau @demo.ub.ac.id)';

  /// Memeriksa apakah sebuah alamat email merupakan domain resmi Universitas Brawijaya
  /// (misal: student.ub.ac.id, demo.ub.ac.id, ub.ac.id, *.ub.ac.id).
  static bool isUbEmail(String? email) {
    if (email == null) return false;
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) return false;

    final atIndex = trimmed.indexOf('@');
    if (atIndex <= 0 ||
        atIndex != trimmed.lastIndexOf('@') ||
        atIndex == trimmed.length - 1) {
      return false;
    }

    final localPart = trimmed.substring(0, atIndex);
    final domain = trimmed.substring(atIndex + 1);

    if (localPart.contains(' ') || domain.contains(' ')) {
      return false;
    }

    // Domain harus persis 'ub.ac.id' atau berakhiran '.ub.ac.id'
    if (domain != ubDomainSuffix && !domain.endsWith('.$ubDomainSuffix')) {
      return false;
    }

    // Pastikan tidak ada segmen domain yang kosong (misal '.ub.ac.id' atau '..ub.ac.id')
    final segments = domain.split('.');
    if (segments.any((s) => s.isEmpty)) {
      return false;
    }

    return true;
  }

  /// Memformat input login (username/NIM atau email).
  /// Jika tidak mengandung '@', otomatis menambahkan domain '@student.ub.ac.id'.
  static String formatLoginEmail(String rawInput) {
    final trimmed = rawInput.trim().toLowerCase();
    if (!trimmed.contains('@')) {
      return '$trimmed@$studentDomain';
    }
    return trimmed;
  }

  /// Validator untuk field login (menerima email UB atau username/NIM tanpa '@').
  static String? validateLoginInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email/Username wajib diisi';
    }

    final trimmed = value.trim().toLowerCase();
    if (trimmed.contains('@')) {
      if (!isUbEmail(trimmed)) {
        return invalidDomainMessage;
      }
    } else {
      if (trimmed.contains(' ')) {
        return 'Username tidak boleh mengandung spasi';
      }
    }

    return null;
  }

  /// Validator khusus untuk input email pendaftaran.
  static String? validateRegisterEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final trimmed = value.trim().toLowerCase();
    if (!isUbEmail(trimmed)) {
      return invalidDomainMessage;
    }

    return null;
  }
}
