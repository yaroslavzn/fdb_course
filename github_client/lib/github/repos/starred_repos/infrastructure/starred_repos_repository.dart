import 'package:dartz/dartz.dart';
import 'package:github_client/core/domain/fresh.dart';
import 'package:github_client/core/infrastructure/response_exceptions.dart';
import 'package:github_client/github/core/domain/github_failure.dart';
import 'package:github_client/github/core/domain/github_repo.dart';
import 'package:github_client/github/core/infrastructure/github_repo_dto.dart';
import 'package:github_client/github/repos/core/infrastructure/extensions.dart';
import 'package:github_client/github/repos/starred_repos/infrastructure/starred_repos_local_service.dart';
import 'package:github_client/github/repos/starred_repos/infrastructure/starred_repos_remote_service.dart';

class StarredReposRepositiry {
  final StarredReposRemoteService _remoteService;
  final StarredReposLocalService _localService;

  StarredReposRepositiry(this._remoteService, this._localService);

  Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> getStarredReposPage(
    int page,
  ) async {
    try {
      final remoteReposResponse =
          await _remoteService.getStarredReposPage(page);

      return right(
        await remoteReposResponse.when(
          noConnection: () async => Fresh.no(
            await _localService.getPage(page).then((value) => value.toDomain()),
            hasNextPage: page < await _localService.getLocalPageCount(),
          ),
          notModified: (maxPage) async => Fresh.yes(
            await _localService.getPage(page).then((value) => value.toDomain()),
            hasNextPage: page < maxPage,
          ),
          withNewData: (data, maxPage) async {
            await _localService.upsertPage(data, page);
            return Fresh.yes(
              data.toDomain(),
              hasNextPage: page < maxPage,
            );
          },
        ),
      );
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}
