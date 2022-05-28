import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:github_client/github/core/domain/user.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDTO with _$UserDTO {
  const UserDTO._();

  const factory UserDTO({
    @JsonKey(name: 'avatar_url') required String avatarUrl,
    @JsonKey(name: 'login') required String name,
  }) = _UserDTO;

  factory UserDTO.fromJson(Map<String, dynamic> json) =>
      _$UserDTOFromJson(json);

  factory UserDTO.fromDomain(User _) {
    return UserDTO(
      avatarUrl: _.avatarUrl,
      name: _.name,
    );
  }

  User toDomain() {
    return User(
      avatarUrl: avatarUrl,
      name: name,
    );
  }
}
