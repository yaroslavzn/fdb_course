// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_headers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_GithubHeader _$$_GithubHeaderFromJson(Map<String, dynamic> json) =>
    _$_GithubHeader(
      etag: json['etag'] as String?,
      link: json['link'] == null
          ? null
          : PaginationLink.fromJson(json['link'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_GithubHeaderToJson(_$_GithubHeader instance) =>
    <String, dynamic>{
      'etag': instance.etag,
      'link': instance.link?.toJson(),
    };

_$_PaginationLink _$$_PaginationLinkFromJson(Map<String, dynamic> json) =>
    _$_PaginationLink(
      maxPage: json['maxPage'] as int?,
    );

Map<String, dynamic> _$$_PaginationLinkToJson(_$_PaginationLink instance) =>
    <String, dynamic>{
      'maxPage': instance.maxPage,
    };
