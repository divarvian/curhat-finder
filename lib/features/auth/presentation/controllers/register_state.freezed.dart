// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterState {

 int get currentStep; String get fullName; String get nickname; String get gender; String get batch; String get facultyId; String get prodiId; Set<String> get hobbies; Set<String> get topics;
/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterStateCopyWith<RegisterState> get copyWith => _$RegisterStateCopyWithImpl<RegisterState>(this as RegisterState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RegisterState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterState&&(identical(other.currentStep, _this.currentStep) || other.currentStep == _this.currentStep)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.batch, _this.batch) || other.batch == _this.batch)&&(identical(other.facultyId, _this.facultyId) || other.facultyId == _this.facultyId)&&(identical(other.prodiId, _this.prodiId) || other.prodiId == _this.prodiId)&&const DeepCollectionEquality().equals(other.hobbies, _this.hobbies)&&const DeepCollectionEquality().equals(other.topics, _this.topics));
}


@override
int get hashCode {
  final _this = this as RegisterState;
  return Object.hash(runtimeType,_this.currentStep,_this.fullName,_this.nickname,_this.gender,_this.batch,_this.facultyId,_this.prodiId,const DeepCollectionEquality().hash(_this.hobbies),const DeepCollectionEquality().hash(_this.topics));
}

@override
String toString() {
  final _this = this as RegisterState;
  return 'RegisterState(currentStep: ${_this.currentStep}, fullName: ${_this.fullName}, nickname: ${_this.nickname}, gender: ${_this.gender}, batch: ${_this.batch}, facultyId: ${_this.facultyId}, prodiId: ${_this.prodiId}, hobbies: ${_this.hobbies}, topics: ${_this.topics})';
}


}

/// @nodoc
abstract mixin class $RegisterStateCopyWith<$Res>  {
  factory $RegisterStateCopyWith(RegisterState value, $Res Function(RegisterState) _then) = _$RegisterStateCopyWithImpl;
@useResult
$Res call({
 int currentStep, String fullName, String nickname, String gender, String batch, String facultyId, String prodiId, Set<String> hobbies, Set<String> topics
});




}
/// @nodoc
class _$RegisterStateCopyWithImpl<$Res>
    implements $RegisterStateCopyWith<$Res> {
  _$RegisterStateCopyWithImpl(this._self, this._then);

  final RegisterState _self;
  final $Res Function(RegisterState) _then;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStep = null,Object? fullName = null,Object? nickname = null,Object? gender = null,Object? batch = null,Object? facultyId = null,Object? prodiId = null,Object? hobbies = null,Object? topics = null,}) {
  return _then(RegisterState(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,batch: null == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as String,facultyId: null == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String,prodiId: null == prodiId ? _self.prodiId : prodiId // ignore: cast_nullable_to_non_nullable
as String,hobbies: null == hobbies ? _self.hobbies : hobbies // ignore: cast_nullable_to_non_nullable
as Set<String>,topics: null == topics ? _self.topics : topics // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterState].
extension RegisterStatePatterns on RegisterState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterState value)  $default,){
final _that = this;
switch (_that) {
case _RegisterState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterState value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStep,  String fullName,  String nickname,  String gender,  String batch,  String facultyId,  String prodiId,  Set<String> hobbies,  Set<String> topics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that.currentStep,_that.fullName,_that.nickname,_that.gender,_that.batch,_that.facultyId,_that.prodiId,_that.hobbies,_that.topics);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStep,  String fullName,  String nickname,  String gender,  String batch,  String facultyId,  String prodiId,  Set<String> hobbies,  Set<String> topics)  $default,) {final _that = this;
switch (_that) {
case _RegisterState():
return $default(_that.currentStep,_that.fullName,_that.nickname,_that.gender,_that.batch,_that.facultyId,_that.prodiId,_that.hobbies,_that.topics);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStep,  String fullName,  String nickname,  String gender,  String batch,  String facultyId,  String prodiId,  Set<String> hobbies,  Set<String> topics)?  $default,) {final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that.currentStep,_that.fullName,_that.nickname,_that.gender,_that.batch,_that.facultyId,_that.prodiId,_that.hobbies,_that.topics);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterState implements RegisterState {
  const _RegisterState({this.currentStep = 0, this.fullName = '', this.nickname = '', this.gender = '', this.batch = '', this.facultyId = '', this.prodiId = '',  Set<String> hobbies = const <String>{},  Set<String> topics = const <String>{}}): _hobbies = hobbies,_topics = topics;
  

@override@JsonKey() final  int currentStep;
@override@JsonKey() final  String fullName;
@override@JsonKey() final  String nickname;
@override@JsonKey() final  String gender;
@override@JsonKey() final  String batch;
@override@JsonKey() final  String facultyId;
@override@JsonKey() final  String prodiId;
 final  Set<String> _hobbies;
@override@JsonKey() Set<String> get hobbies {
  if (_hobbies is EqualUnmodifiableSetView) return _hobbies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_hobbies);
}

 final  Set<String> _topics;
@override@JsonKey() Set<String> get topics {
  if (_topics is EqualUnmodifiableSetView) return _topics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_topics);
}


/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterStateCopyWith<_RegisterState> get copyWith => __$RegisterStateCopyWithImpl<_RegisterState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.prodiId, prodiId) || other.prodiId == prodiId)&&const DeepCollectionEquality().equals(other.hobbies, _hobbies)&&const DeepCollectionEquality().equals(other.topics, _topics));
}


@override
int get hashCode {
    return Object.hash(runtimeType,currentStep,fullName,nickname,gender,batch,facultyId,prodiId,const DeepCollectionEquality().hash(_hobbies),const DeepCollectionEquality().hash(_topics));
}

@override
String toString() {
    return 'RegisterState(currentStep: $currentStep, fullName: $fullName, nickname: $nickname, gender: $gender, batch: $batch, facultyId: $facultyId, prodiId: $prodiId, hobbies: $hobbies, topics: $topics)';
}


}

/// @nodoc
abstract mixin class _$RegisterStateCopyWith<$Res> implements $RegisterStateCopyWith<$Res> {
  factory _$RegisterStateCopyWith(_RegisterState value, $Res Function(_RegisterState) _then) = __$RegisterStateCopyWithImpl;
@override @useResult
$Res call({
 int currentStep, String fullName, String nickname, String gender, String batch, String facultyId, String prodiId, Set<String> hobbies, Set<String> topics
});




}
/// @nodoc
class __$RegisterStateCopyWithImpl<$Res>
    implements _$RegisterStateCopyWith<$Res> {
  __$RegisterStateCopyWithImpl(this._self, this._then);

  final _RegisterState _self;
  final $Res Function(_RegisterState) _then;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStep = null,Object? fullName = null,Object? nickname = null,Object? gender = null,Object? batch = null,Object? facultyId = null,Object? prodiId = null,Object? hobbies = null,Object? topics = null,}) {
  return _then(_RegisterState(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,batch: null == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as String,facultyId: null == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String,prodiId: null == prodiId ? _self.prodiId : prodiId // ignore: cast_nullable_to_non_nullable
as String,hobbies: null == hobbies ? _self._hobbies : hobbies // ignore: cast_nullable_to_non_nullable
as Set<String>,topics: null == topics ? _self._topics : topics // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
