import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

@freezed
abstract class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default(0) int currentStep,
    @Default('') String fullName,
    @Default('') String nickname,
    @Default('') String gender,
    @Default('') String batch,
    @Default('') String facultyId,
    @Default('') String prodiId,
    @Default(<String>{}) Set<String> hobbies,
    @Default(<String>{}) Set<String> topics,
  }) = _RegisterState;
}
