import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:github_client/github/core/domain/github_repo.dart';
import 'package:github_client/github/core/infrastructure/user_dto.dart';

part 'github_repo_dto.freezed.dart';
part 'github_repo_dto.g.dart';

String _descriptionFromJson(Object? json) => (json as String?) ?? '';

@freezed
class GithubRepoDTO with _$GithubRepoDTO {
  const GithubRepoDTO._();

  const factory GithubRepoDTO({
    required UserDTO owner,
    @JsonKey(fromJson: _descriptionFromJson) required String description,
    required String name,
    @JsonKey(name: 'stargazers_count') required int stargazersCount,
  }) = _GithubRepoDTO;

  factory GithubRepoDTO.fromJson(Map<String, dynamic> json) =>
      _$GithubRepoDTOFromJson(json);

  factory GithubRepoDTO.fromDomain(GithubRepo _) {
    return GithubRepoDTO(
      owner: UserDTO.fromDomain(_.owner),
      description: _.description,
      name: _.name,
      stargazersCount: _.stargazersCount,
    );
  }

  GithubRepo toDomain() {
    return GithubRepo(
      owner: owner.toDomain(),
      description: description,
      name: name,
      stargazersCount: stargazersCount,
    );
  }
}
