import 'package:dio/dio.dart';
import 'package:github_client/core/infrastructure/remote_response.dart';
import 'package:github_client/github/core/infrastructure/github_headers_cache.dart';
import 'package:github_client/github/core/infrastructure/github_repo_dto.dart';
import 'package:github_client/github/repos/core/infrastructure/repos_remote_service.dart';
import 'package:github_client/github/repos/starred_repos/infrastructure/pagination_config.dart';

class StarredReposRemoteService extends ReposRemoteService {
  StarredReposRemoteService(
    Dio dio,
    GithubHeadersCache headersCache,
  ) : super(dio, headersCache);

  Future<RemoteResponse<List<GithubRepoDTO>>> getStarredReposPage(
    int page,
  ) async {
    final requestUri = Uri.https(
      'api.github.com',
      '/user/starred',
      {
        'page': '$page',
        'per_page': PaginationConfig.maxPerPage.toString(),
      },
    );

    return super.getReposPage(
      requestUri: requestUri,
      jsonDataSelector: (json) {
        return json as List<Map<String, dynamic>>;
      },
    );
  }
}
