import 'package:github_client/github/core/domain/github_repo.dart';
import 'package:github_client/github/core/infrastructure/github_repo_dto.dart';

extension DTOListToEntityList on List<GithubRepoDTO> {
  List<GithubRepo> toDomain() {
    return map((e) => e.toDomain()).toList();
  }
}
