import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:github_client/auth/application/auth_notifier.dart';
import 'package:github_client/auth/shared/providers.dart';
import 'package:github_client/core/presentation/routes/app_router.gr.dart';
import 'package:github_client/core/shared/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final initializationProvider = FutureProvider<Unit>((ref) async {
  await ref.read(sembastProvider).init();
  ref.read(dioProvider)
    ..options = BaseOptions(
      headers: {
        'Accept': 'application/vnd.github.v3.html+json',
      },
      validateStatus: (status) =>
          status != null && status >= 200 && status < 400,
    )
    ..interceptors.add(
      ref.read(oauth2InterceptorProvider),
    );
  final authNotifier = ref.read(authNotifierProvider.notifier);

  await authNotifier.checkAndUpdateAuthStatus();

  return unit;
});

class AppWidget extends ConsumerWidget {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(initializationProvider, (previous, next) {});
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeMap(
        orElse: () {},
        authenticated: (state) {
          _appRouter.pushAndPopUntil(
            const StarredReposRoute(),
            predicate: (_) => false,
          );
        },
        unauthenticated: (state) {
          _appRouter.pushAndPopUntil(
            const SignInRoute(),
            predicate: (_) => false,
          );
        },
      );
    });

    return MaterialApp.router(
      title: 'Repo Viewer',
      debugShowCheckedModeBanner: false,
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
