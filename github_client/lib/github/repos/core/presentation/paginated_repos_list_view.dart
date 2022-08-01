import 'package:flutter/material.dart';
import 'package:github_client/core/presentation/toasts.dart';
import 'package:github_client/github/core/presentation/no_results_display.dart';
import 'package:github_client/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:github_client/github/repos/core/presentation/failure_repo_tile.dart';
import 'package:github_client/github/repos/core/presentation/loading_repo_tile.dart';
import 'package:github_client/github/repos/core/presentation/repo_tile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class PaginatedReposListView extends StatefulWidget {
  final AutoDisposeStateNotifierProvider<PaginatedReposNotifier,
      PaginatedReposState> paginatedReposNotifierProvider;
  final void Function(WidgetRef ref) nextPageGetter;
  final String noResultsMessage;

  const PaginatedReposListView({
    Key? key,
    required this.paginatedReposNotifierProvider,
    required this.nextPageGetter,
    required this.noResultsMessage,
  }) : super(key: key);

  @override
  State<PaginatedReposListView> createState() => _PaginatedReposListViewState();
}

class _PaginatedReposListViewState extends State<PaginatedReposListView> {
  bool canLoadNextPage = false;
  bool hasAlreadyShownNoConnectionToast = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.listen<PaginatedReposState>(widget.paginatedReposNotifierProvider,
            (previous, state) {
          state.map(
            initial: (_) => canLoadNextPage = true,
            loadInProgress: (_) => canLoadNextPage = false,
            loadSuccess: (_) {
              if (!_.repos.isFresh) {
                hasAlreadyShownNoConnectionToast = true;
                showNoConnectionToast(
                  "You're not online. Some information my be outdated.",
                  context,
                );
              }

              canLoadNextPage = _.hasNextPage;
            },
            loadFailure: (_) => canLoadNextPage = false,
          );
        });
        final state = ref.watch(widget.paginatedReposNotifierProvider);
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final limit = notification.metrics.maxScrollExtent -
                notification.metrics.viewportDimension / 3;

            if (canLoadNextPage && notification.metrics.pixels >= limit) {
              canLoadNextPage = false;

              widget.nextPageGetter(ref);
            }
            return false;
          },
          child: state.maybeWhen(
            loadSuccess: (repos, _) => repos.entity.isEmpty,
            orElse: () => false,
          )
              ? NoResultsDisplay(
                  message: widget.noResultsMessage,
                )
              : _ReposListView(state: state),
        );
      },
    );
  }
}

class _ReposListView extends StatelessWidget {
  const _ReposListView({
    Key? key,
    required this.state,
  }) : super(key: key);

  final PaginatedReposState state;

  @override
  Widget build(BuildContext context) {
    final fsbHeight = FloatingSearchBar.of(context)?.widget.height ?? 0;
    final topPadding = MediaQuery.of(context).padding.top;

    return ListView.builder(
      padding: EdgeInsets.only(top: fsbHeight + 8 + topPadding),
      itemBuilder: (context, index) {
        return state.map(
          initial: (_) => Container(),
          loadInProgress: (_) {
            if (index < _.repos.entity.length) {
              return RepoTile(repo: _.repos.entity[index]);
            } else {
              return const LoadingRepoTile();
            }
          },
          loadSuccess: (_) => RepoTile(repo: _.repos.entity[index]),
          loadFailure: (_) {
            if (index < _.repos.entity.length) {
              return RepoTile(repo: _.repos.entity[index]);
            } else {
              return FailureRepoTile(
                failure: _.failure,
              );
            }
          },
        );
      },
      itemCount: state.map(
        initial: (_) => 0,
        loadInProgress: (_) => _.repos.entity.length + _.itemsPerPage,
        loadSuccess: (_) => _.repos.entity.length,
        loadFailure: (_) => _.repos.entity.length + 1,
      ),
    );
  }
}
