import 'package:github_client/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:github_client/github/repos/searched_repos/infrastructure/searched_repos_repository.dart';

class SearchedReposNotifier extends PaginatedReposNotifier {
  final SearchedReposRepository _repository;

  SearchedReposNotifier(this._repository);

  Future<void> getNextSearchedReposPage(String query) async {
    await super
        .getNextReposPage((page) => _repository.getSearchedRepos(query, page));
  }
}
