import 'package:dio/dio.dart';
import 'package:github_client/core/infrastructure/remote_response.dart';
import 'package:github_client/github/core/infrastructure/github_headers_cache.dart';
import 'package:github_client/github/core/infrastructure/github_repo_dto.dart';
import 'package:github_client/github/repos/core/infrastructure/repos_remote_service.dart';
import 'package:github_client/github/repos/starred_repos/infrastructure/pagination_config.dart';

class SearchedReposRemoteService extends ReposRemoteService {
  SearchedReposRemoteService(
    Dio dio,
    GithubHeadersCache headersCache,
  ) : super(dio, headersCache);

  Future<RemoteResponse<List<GithubRepoDTO>>> getSearchedReposPage(
    String query,
    int page,
  ) async {
    final requestUri = Uri.https(
      'api.github.com',
      '/search/repositories',
      {
        'q': query,
        'page': '$page',
        'per_page': PaginationConfig.maxPerPage.toString(),
      },
    );

    return super.getReposPage(
      requestUri: requestUri,
      jsonDataSelector: (json) {
        return List<Map<String, dynamic>>.from(json['items'] as List<dynamic>);
      },
    );
  }
}
