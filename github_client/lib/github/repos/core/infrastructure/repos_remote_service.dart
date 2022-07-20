import 'package:dio/dio.dart';
import 'package:github_client/core/infrastructure/dio_extensions.dart';
import 'package:github_client/core/infrastructure/remote_response.dart';
import 'package:github_client/core/infrastructure/response_exceptions.dart';
import 'package:github_client/github/core/infrastructure/github_headers.dart';
import 'package:github_client/github/core/infrastructure/github_headers_cache.dart';
import 'package:github_client/github/core/infrastructure/github_repo_dto.dart';

abstract class ReposRemoteService {
  final Dio _dio;
  final GithubHeadersCache _headersCache;

  ReposRemoteService(
    this._dio,
    this._headersCache,
  );

  Future<RemoteResponse<List<GithubRepoDTO>>> getReposPage({
    required Uri requestUri,
    required List<Map<String, dynamic>> Function(dynamic json) jsonDataSelector,
  }) async {
    final previousHeaders = await _headersCache.getHeaders(requestUri);

    try {
      final response = await _dio.getUri(
        requestUri,
        options: Options(
          headers: {
            'If-None-Match': previousHeaders?.etag ?? '',
          },
        ),
      );

      if (response.statusCode == 304) {
        return RemoteResponse.notModified(
          maxPage: previousHeaders?.link?.maxPage ?? 0,
        );
      } else if (response.statusCode == 200) {
        final headers = GithubHeaders.parse(response);
        await _headersCache.saveHeaders(requestUri, headers);

        final List<Map<String, dynamic>> responseData =
            List.from(jsonDataSelector(response.data));
        final transformedData =
            responseData.map((e) => GithubRepoDTO.fromJson(e)).toList();

        return RemoteResponse.withNewData(
          transformedData,
          maxPage: headers.link?.maxPage ?? 1,
        );
      } else {
        throw RestApiException(response.statusCode);
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        return const RemoteResponse.noConnection();
      } else if (e.response != null) {
        throw RestApiException(e.response?.statusCode);
      } else {
        rethrow;
      }
    }
  }
}
