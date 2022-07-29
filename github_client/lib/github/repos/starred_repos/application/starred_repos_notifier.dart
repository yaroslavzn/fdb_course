import 'package:github_client/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:github_client/github/repos/starred_repos/infrastructure/starred_repos_repository.dart';

class StarredReposNotifier extends PaginatedReposNotifier {
  final StarredReposRepositiry _repositiry;

  StarredReposNotifier(this._repositiry);

  Future<void> getNextStarredReposPage() async {
    await super
        .getNextReposPage((page) => _repositiry.getStarredReposPage(page));
  }
}
