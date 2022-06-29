import 'package:flutter/material.dart';
import 'package:github_client/core/presentation/toasts.dart';
import 'package:github_client/github/core/presentation/no_results_display.dart';
import 'package:github_client/github/core/shared/providers.dart';
import 'package:github_client/github/repos/starred_repos/application/starred_repos_notifier.dart';
import 'package:github_client/github/repos/starred_repos/presentation/failure_repo_tile.dart';
import 'package:github_client/github/repos/starred_repos/presentation/loading_repo_tile.dart';
import 'package:github_client/github/repos/starred_repos/presentation/repo_tile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PaginatedReposListView extends StatefulWidget {
  const PaginatedReposListView({
    Key? key,
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
        ref.listen<StarredReposState>(starredReposNotifierProvider,
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
        final state = ref.watch(starredReposNotifierProvider);
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final limit = notification.metrics.maxScrollExtent -
                notification.metrics.viewportDimension / 3;

            if (canLoadNextPage && notification.metrics.pixels >= limit) {
              canLoadNextPage = false;
              ref
                  .read(starredReposNotifierProvider.notifier)
                  .getNextStarredReposPage();
            }
            return false;
          },
          child: state.maybeWhen(
            loadSuccess: (repos, _) => repos.entity.isEmpty,
            orElse: () => false,
          )
              ? const NoResultsDisplay(
                  message:
                      "That's about everything we could find in your starred repos right now.",
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

  final StarredReposState state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
