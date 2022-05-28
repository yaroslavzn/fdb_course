import 'package:auto_route/annotations.dart';
import 'package:github_client/auth/presentation/authorization_page.dart';
import 'package:github_client/auth/presentation/sign_in_page.dart';
import 'package:github_client/github/repos/starred_repos/presentation/starred_repos_page.dart';
import 'package:github_client/splash/presentation/splash_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    AutoRoute(page: SplashPage, initial: true),
    AutoRoute(page: SignInPage, path: '/sign-in'),
    AutoRoute(page: AuthorizationPage, path: '/auth'),
    AutoRoute(page: StarredReposPage, path: '/starred'),
  ],
)
class $AppRouter {}
