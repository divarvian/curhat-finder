import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/auth/presentation/providers/auth_state.dart';
import 'package:curhat_finder/features/auth/presentation/providers/auth_provider.dart';
import 'package:curhat_finder/features/counselor/presentation/providers/counselor_provider.dart';
import 'package:curhat_finder/features/profile/domain/user_profile_model.dart';
import 'package:curhat_finder/features/profile/presentation/providers/profile_provider.dart';

class FakeAuthNotifier extends Notifier<AuthState> implements AuthNotifier {
  final AuthState _initial;
  final VoidCallback? onRefresh;
  FakeAuthNotifier(this._initial, {this.onRefresh});

  @override
  AuthState build() => _initial;

  @override
  Future<void> refreshProfile() async {
    onRefresh?.call();
  }

  @override
  Future<bool> checkUserExists(String email) async => true;

  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<bool> register({
    required String email,
    required String password,
    required String role,
    required String fullName,
    String? nickname,
    String? gender,
    String? batchYear,
    String? faculty,
    String? studyProgram,
    List<String>? hobbies,
    List<String>? topics,
  }) async => true;

  @override
  Future<void> logout() async {}
}

class FakeCounselorNotifier extends CounselorNotifier {
  final CounselorState _initial;
  FakeCounselorNotifier(this._initial);

  @override
  CounselorState build() => _initial;
}

class FakeProfileNotifier extends ProfileNotifier {
  final UserProfile _initial;
  FakeProfileNotifier(this._initial);

  @override
  UserProfile build() => _initial;

  @override
  Future<void> reloadProfile() async {}
}
