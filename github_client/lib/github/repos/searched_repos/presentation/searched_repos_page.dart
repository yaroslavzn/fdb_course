import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:github_client/auth/shared/providers.dart';
import 'package:github_client/core/presentation/routes/app_router.gr.dart';
import 'package:github_client/github/core/shared/providers.dart';
import 'package:github_client/github/repos/core/presentation/paginated_repos_list_view.dart';
import 'package:github_client/search/presentation/search_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SearchedReposPage extends ConsumerStatefulWidget {
  final String searchTerm;
  const SearchedReposPage({
    Key? key,
    required this.searchTerm,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SearchedReposPageState();
  }
}

class _SearchedReposPageState extends ConsumerState<SearchedReposPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => ref
          .read(searchedReposNotifierProvider.notifier)
          .getFirstPage(widget.searchTerm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.searchTerm),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
            icon: const Icon(MdiIcons.logoutVariant),
          ),
        ],
      ),
      body: SearchBar(
        body: PaginatedReposListView(
          paginatedReposNotifierProvider: searchedReposNotifierProvider,
          nextPageGetter: (ref) => ref
              .read(searchedReposNotifierProvider.notifier)
              .getNextSearchedReposPage(widget.searchTerm),
          noResultsMessage:
              "This is all we could find for your search term. Really...",
        ),
        hint: 'Search all repositories...',
        title: 'Starred Repos',
        onSearchTermSubmit: (searchTerm) {
          AutoRouter.of(context).pushAndPopUntil(
            SearchedReposRoute(searchTerm: searchTerm),
            predicate: (route) => route.settings.name == StarredReposRoute.name,
          );
        },
        onLogoutAction: () {
          ref.read(authNotifierProvider.notifier).signOut();
        },
      ),
    );
  }
}
