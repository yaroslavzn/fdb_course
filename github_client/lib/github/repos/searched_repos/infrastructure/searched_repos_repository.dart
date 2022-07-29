import 'package:dartz/dartz.dart';
import 'package:github_client/core/domain/fresh.dart';
import 'package:github_client/core/infrastructure/response_exceptions.dart';
import 'package:github_client/github/core/domain/github_failure.dart';
import 'package:github_client/github/core/domain/github_repo.dart';
import 'package:github_client/github/repos/core/infrastructure/extensions.dart';
import 'package:github_client/github/repos/searched_repos/infrastructure/searched_repos_remote_service.dart';

class SearchedReposRepository {
  final SearchedReposRemoteService _remoteService;

  SearchedReposRepository(this._remoteService);

  Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> getSearchedRepos(
    String query,
    int page,
  ) async {
    try {
      final remoteReposResponse =
          await _remoteService.getSearchedReposPage(query, page);

      return right(
        await remoteReposResponse.maybeWhen(
          orElse: () => Fresh.no(
            [],
            hasNextPage: false,
          ),
          withNewData: (data, maxPage) {
            return Fresh.yes(data.toDomain(), hasNextPage: page < maxPage);
          },
        ),
      );
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}
