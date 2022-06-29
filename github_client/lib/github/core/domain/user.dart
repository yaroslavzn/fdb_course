import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const User._();

  const factory User({
    required String avatarUrl,
    required String name,
  }) = _User;

  String get avatarUrlSmall => '$avatarUrl?s=64';
}
