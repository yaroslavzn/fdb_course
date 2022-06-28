import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:github_client/core/domain/fresh.dart';
import 'package:github_client/github/core/domain/github_failure.dart';
import 'package:github_client/github/core/domain/github_repo.dart';
import 'package:github_client/github/repos/starred_repos/infrastructure/pagination_config.dart';
import 'package:github_client/github/repos/starred_repos/infrastructure/starred_repos_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'starred_repos_notifier.freezed.dart';

@freezed
class StarredReposState with _$StarredReposState {
  const StarredReposState._();

  const factory StarredReposState.initial(
    Fresh<List<GithubRepo>> repos,
  ) = _Initial;
  const factory StarredReposState.loadInProgress(
    Fresh<List<GithubRepo>> repos, {
    required int itemsPerPage,
  }) = _LoadInProgress;
  const factory StarredReposState.loadSuccess(
    Fresh<List<GithubRepo>> repos, {
    required bool hasNextPage,
  }) = _LoadSuccess;
  const factory StarredReposState.loadFailure(
    Fresh<List<GithubRepo>> repos, {
    required GithubFailure failure,
  }) = _LoadFailure;
}

class StarredReposNotifier extends StateNotifier<StarredReposState> {
  final StarredReposRepositiry _repositiry;

  StarredReposNotifier(this._repositiry)
      : super(StarredReposState.initial(Fresh.yes([])));

  int _page = 1;

  Future<void> getNextStarredReposPage() async {
    state = StarredReposState.loadInProgress(
      state.repos,
      itemsPerPage: PaginationConfig.maxPerPage,
    );
    final failureOrSuccess = await _repositiry.getStarredReposPage(_page);

    state = failureOrSuccess.fold(
        (l) => StarredReposState.loadFailure(state.repos, failure: l), (r) {
      _page++;

      return StarredReposState.loadSuccess(
        r.copyWith(
          entity: [
            ...state.repos.entity,
            ...r.entity,
          ],
        ),
        hasNextPage: r.isFresh,
      );
    });
  }
}
