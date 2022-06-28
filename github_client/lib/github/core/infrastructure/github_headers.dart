import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_headers.freezed.dart';
part 'github_headers.g.dart';

@freezed
class GithubHeaders with _$GithubHeaders {
  const GithubHeaders._();

  const factory GithubHeaders({
    String? etag,
    PaginationLink? link,
  }) = _GithubHeader;

  factory GithubHeaders.parse(Response response) {
    final link = response.headers.map['Link']?[0];

    return GithubHeaders(
      etag: response.headers.map['ETag']?[0],
      link: link == null
          ? null
          : PaginationLink.parse(
              link.split(','),
              requestUrl: response.requestOptions.path,
            ),
    );
  }

  factory GithubHeaders.fromJson(Map<String, dynamic> json) =>
      _$GithubHeadersFromJson(json);
}

@freezed
class PaginationLink with _$PaginationLink {
  const PaginationLink._();

  const factory PaginationLink({int? maxPage}) = _PaginationLink;

  factory PaginationLink.parse(
    List<String> values, {
    required String requestUrl,
  }) {
    final urlString = values.firstWhere(
      (elem) => elem.contains('rel="last"'),
      orElse: () => requestUrl,
    );
    return PaginationLink(
      maxPage: _parseMaxPageNumber(urlString),
    );
  }

  static int _parseMaxPageNumber(String value) {
    final uriString = RegExp(
      r'[https?:\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)',
    ).stringMatch(value);

    return int.parse(Uri.parse(uriString!).queryParameters['page']!);
  }

  factory PaginationLink.fromJson(Map<String, dynamic> json) =>
      _$PaginationLinkFromJson(json);
}
