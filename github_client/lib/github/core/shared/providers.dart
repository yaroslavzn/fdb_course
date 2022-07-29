import 'package:github_client/core/shared/providers.dart';
import 'package:github_client/github/core/infrastructure/github_headers_cache.dart';
import 'package:github_client/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:github_client/github/repos/searched_repos/application/searched_repos_notifier.dart';
import 'package:github_client/github/repos/searched_repos/infrastructure/searched_repos_remote_service.dart';
import 'package:github_client/github/repos/searched_repos/infrastructure/searched_repos_repository.dart';
import 'package:github_client/github/repos/starred_repos/application/starred_repos_notifier.dart';
import 'package:github_client/github/repos/starred_repos/infrastructure/starred_repos_local_service.dart';
import 'package:github_client/github/repos/starred_repos/infrastructure/starred_repos_remote_service.dart';
import 'package:github_client/github/repos/starred_repos/infrastructure/starred_repos_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final githubHeadersCacheProvider =
    Provider((ref) => GithubHeadersCache(ref.watch(sembastProvider)));

final starredReposLocalServiceProvider =
    Provider((ref) => StarredReposLocalService(ref.watch(sembastProvider)));

final starredReposRemoteServiceProvider = Provider(
  (ref) => StarredReposRemoteService(
    ref.watch(dioProvider),
    ref.watch(githubHeadersCacheProvider),
  ),
);

final starredReposRepositoryProvider = Provider(
  (ref) => StarredReposRepositiry(
    ref.watch(starredReposRemoteServiceProvider),
    ref.watch(starredReposLocalServiceProvider),
  ),
);

final starredReposNotifierProvider =
    StateNotifierProvider.autoDispose<StarredReposNotifier, PaginatedReposState>(
  (ref) => StarredReposNotifier(
    ref.watch(starredReposRepositoryProvider),
  ),
);

final searchedReposRemoteServiceProvider = Provider(
  (ref) => SearchedReposRemoteService(
    ref.watch(dioProvider),
    ref.watch(githubHeadersCacheProvider),
  ),
);

final searchedReposRepositoryProvider = Provider(
  (ref) => SearchedReposRepository(
    ref.watch(searchedReposRemoteServiceProvider),
  ),
);

final searchedReposNotifierProvider =
    StateNotifierProvider.autoDispose<SearchedReposNotifier, PaginatedReposState>(
  (ref) => SearchedReposNotifier(
    ref.watch(searchedReposRepositoryProvider),
  ),
);
