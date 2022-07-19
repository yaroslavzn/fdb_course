import 'package:github_client/core/infrastructure/sembast_database.dart';
import 'package:github_client/github/core/infrastructure/github_repo_dto.dart';
import 'package:github_client/github/repos/starred_repos/infrastructure/pagination_config.dart';
import 'package:sembast/sembast.dart';
import 'package:collection/collection.dart';

class StarredReposLocalService {
  final SembastDatabase _sembastDatabase;
  final _store = intMapStoreFactory.store('starredRepos');

  StarredReposLocalService(this._sembastDatabase);

  Future<void> upsertPage(List<GithubRepoDTO> dtos, int page) async {
    final sembastPage = page - 1;

    await _store
        .records(
          dtos.mapIndexed(
            (index, _) => index + sembastPage * PaginationConfig.maxPerPage,
          ),
        )
        .put(
          _sembastDatabase.instance,
          dtos.map((e) => e.toJson()).toList(),
        );
  }

  Future<List<GithubRepoDTO>> getPage(int page) async {
    final sembastPage = page - 1;

    final pageItems = await _store.find(
      _sembastDatabase.instance,
      finder: Finder(
        limit: PaginationConfig.maxPerPage,
        offset: PaginationConfig.maxPerPage * sembastPage,
      ),
    );

    return pageItems
        .map(
          (e) => GithubRepoDTO.fromJson(e.value),
        )
        .toList();
  }

  Future<int> getLocalPageCount() async {
    final reposCount = await _store.count(_sembastDatabase.instance);

    return (reposCount / PaginationConfig.maxPerPage).ceil();
  }
}
