import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:github_client/auth/domain/auth_failure.dart';
import 'package:github_client/core/shared/encoders.dart';
import 'package:github_client/core/infrastructure/dio_extensions.dart';
import 'package:oauth2/oauth2.dart';
import 'package:http/http.dart' as http;

import 'credentials_storage/credentials_storage.dart';

class GithubOAuthHttpClient extends http.BaseClient {
  final httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';

    return httpClient.send(request);
  }
}

class GithubAuthenticator {
  final CredentialsStorage _creadentialsStorage;
  final Dio _dio;

  GithubAuthenticator(this._creadentialsStorage, this._dio);

  static const clientId = 'e751da8c880c91078aa5';
  static const clientSecret = 'c5dcd730c6693c7488fc518ccc2dd0ad100a12b9';
  final scopes = ['read:user', 'repo'];
  final authorizationEndpoint =
      Uri.parse('https://github.com/login/oauth/authorize');
  final accessTokenEndpoint =
      Uri.parse('https://github.com/login/oauth/access_token');
  final revokeTokenEndpoint =
      Uri.parse('https://api.github.com/applications/$clientId/token');
  final callbackUrl = Uri.parse('http://localhost:300/callback');

  Future<Credentials?> getSignedInCredentials() async {
    try {
      final credentials = await _creadentialsStorage.read();

      if (credentials != null) {
        if (credentials.canRefresh && credentials.isExpired) {
          // TODO: refresh token
          final failureOrCredentials = await refresh(credentials);

          return failureOrCredentials.fold((l) => null, (r) => r);
        }
      }

      return credentials;
    } on PlatformException {
      return null;
    }
  }

  Future<bool> isSignedIn() =>
      _creadentialsStorage.read().then((credentials) => credentials != null);

  AuthorizationCodeGrant createCodeGrant() {
    return AuthorizationCodeGrant(
      clientId,
      authorizationEndpoint,
      accessTokenEndpoint,
      secret: clientSecret,
      httpClient: GithubOAuthHttpClient(),
    );
  }

  Uri getAuthorizationUrl(AuthorizationCodeGrant grant) {
    return grant.getAuthorizationUrl(callbackUrl, scopes: scopes);
  }

  Future<Either<AuthFailure, Unit>> handleAuthorizationResponse(
    AuthorizationCodeGrant grant,
    Map<String, String> queryParams,
  ) async {
    try {
      final httpClient = await grant.handleAuthorizationResponse(queryParams);
      await _creadentialsStorage.save(httpClient.credentials);
      return right(unit);
    } on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(
        AuthFailure.server('${e.error}: ${e.description}'),
      );
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  Future<Either<AuthFailure, Unit>> signOut() async {
    try {
      final accessToken = _creadentialsStorage
          .read()
          .then((credentials) => credentials?.accessToken);
      final base64UsernameAndPassword =
          stringToBase64.encode('$clientId:$clientSecret');

      try {
        _dio.deleteUri(
          revokeTokenEndpoint,
          data: {
            'access_token': accessToken,
          },
          options: Options(
            headers: {'Authentication': 'basic $base64UsernameAndPassword'},
          ),
        );
      } on DioError catch (e) {
        if (e.isNoConnectionError) {
          print('Token wasn\'t revoked');
        } else {
          rethrow;
        }
      }

      await _creadentialsStorage.clear();

      return right(unit);
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  Future<Either<AuthFailure, Credentials>> refresh(
    Credentials credentials,
  ) async {
    try {
      final refreshedCredentials = await credentials.refresh(
        identifier: clientId,
        secret: clientSecret,
        httpClient: GithubOAuthHttpClient(),
      );

      await _creadentialsStorage.save(refreshedCredentials);

      return right(refreshedCredentials);
    } on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server('${e.error}: ${e.description}'));
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }
}
