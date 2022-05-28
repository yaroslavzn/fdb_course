import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:github_client/github/core/domain/user.dart';

part 'github_repo.freezed.dart';

@freezed
class GithubRepo with _$GithubRepo {
  const GithubRepo._();

  const factory GithubRepo({
    required User owner,
    required String description,
    required String name,
    required int stargazersCount,
  }) = _GithubRepo;

  String get fullName => '${owner.name}/$name';
}
