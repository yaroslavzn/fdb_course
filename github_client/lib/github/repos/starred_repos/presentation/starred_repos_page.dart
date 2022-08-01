import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:github_client/auth/shared/providers.dart';
import 'package:github_client/core/presentation/routes/app_router.gr.dart';
import 'package:github_client/github/core/shared/providers.dart';
import 'package:github_client/github/repos/core/presentation/paginated_repos_list_view.dart';
import 'package:github_client/search/presentation/search_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StarredReposPage extends ConsumerStatefulWidget {
  const StarredReposPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StarredReposPageState();
}

class _StarredReposPageState extends ConsumerState<StarredReposPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => ref
          .read(starredReposNotifierProvider.notifier)
          .getNextStarredReposPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchBar(
        body: PaginatedReposListView(
          paginatedReposNotifierProvider: starredReposNotifierProvider,
          nextPageGetter: (ref) => ref
              .read(starredReposNotifierProvider.notifier)
              .getNextStarredReposPage(),
          noResultsMessage:
              "That's about everything we could find in your starred repos right now.",
        ),
        hint: 'Search all repositories...',
        title: 'Starred Repos',
        onSearchTermSubmit: (searchTerm) {
          AutoRouter.of(context).push(
            SearchedReposRoute(searchTerm: searchTerm),
          );
        },
        onLogoutAction: () {
          ref.read(authNotifierProvider.notifier).signOut();
        },
      ),
    );
  }
}
