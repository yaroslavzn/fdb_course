import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:github_client/core/domain/fresh.dart';
import 'package:github_client/github/core/domain/github_failure.dart';
import 'package:github_client/github/core/domain/github_repo.dart';
import 'package:github_client/github/repos/starred_repos/infrastructure/pagination_config.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'paginated_repos_notifier.freezed.dart';

@freezed
class PaginatedReposState with _$PaginatedReposState {
  const PaginatedReposState._();

  const factory PaginatedReposState.initial(
    Fresh<List<GithubRepo>> repos,
  ) = _Initial;

  const factory PaginatedReposState.loadInProgress(
    Fresh<List<GithubRepo>> repos, {
    required int itemsPerPage,
  }) = _LoadInProgress;

  const factory PaginatedReposState.loadSuccess(
    Fresh<List<GithubRepo>> repos, {
    required bool hasNextPage,
  }) = _LoadSuccess;

  const factory PaginatedReposState.loadFailure(
    Fresh<List<GithubRepo>> repos, {
    required GithubFailure failure,
  }) = _LoadFailure;
}

typedef PaginatedReposGetter
    = Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> Function(int page);

class PaginatedReposNotifier extends StateNotifier<PaginatedReposState> {
  PaginatedReposNotifier() : super(PaginatedReposState.initial(Fresh.yes([])));

  int _page = 1;

  @protected
  Future<void> getNextReposPage(PaginatedReposGetter getter) async {
    state = PaginatedReposState.loadInProgress(
      state.repos,
      itemsPerPage: PaginationConfig.maxPerPage,
    );
    final failureOrSuccess = await getter(_page);

    state = failureOrSuccess.fold(
        (l) => PaginatedReposState.loadFailure(state.repos, failure: l), (r) {
      _page++;

      return PaginatedReposState.loadSuccess(
        r.copyWith(
          entity: [
            ...state.repos.entity,
            ...r.entity,
          ],
        ),
        hasNextPage: r.hasNextPage ?? false,
      );
    });
  }
}
