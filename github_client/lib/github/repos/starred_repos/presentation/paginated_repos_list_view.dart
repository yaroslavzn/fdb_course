import 'package:flutter/material.dart';
import 'package:github_client/github/core/shared/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PaginatedReposListView extends StatelessWidget {
  const PaginatedReposListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(starredReposNotifierProvider);
        return ListView.builder(
          itemBuilder: (context, index) {
            return const Text('Repo widget');
          },
          itemCount: state.map(
            initial: (_) => 0,
            loadInProgress: (_) => _.repos.entity.length + _.itemsPerPage,
            loadSuccess: (_) => _.repos.entity.length,
            loadFailure: (_) => _.repos.entity.length + 1,
          ),
        );
      },
    );
  }
}
