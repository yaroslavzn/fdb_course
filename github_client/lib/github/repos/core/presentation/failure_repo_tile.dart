import 'package:flutter/material.dart';
import 'package:github_client/github/core/domain/github_failure.dart';
import 'package:github_client/github/core/shared/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FailureRepoTile extends ConsumerWidget {
  final GithubFailure failure;
  const FailureRepoTile({
    Key? key,
    required this.failure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Theme.of(context).colorScheme.error,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTileTheme(
        textColor: Theme.of(context).colorScheme.onError,
        iconColor: Theme.of(context).colorScheme.onError,
        child: ListTile(
          title: const Text('An error occured, please retry'),
          subtitle: Text('API returned ${failure.errorCode}'),
          leading: const SizedBox(
            height: double.infinity,
            child: Icon(Icons.warning),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(starredReposNotifierProvider.notifier)
                  .getNextStarredReposPage();
            },
          ),
        ),
      ),
    );
  }
}
