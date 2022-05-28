import 'package:flutter/material.dart';
import 'package:github_client/auth/shared/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StarredReposPage extends ConsumerWidget {
  const StarredReposPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('Sign out'),
          onPressed: () {
            ref.read(authNotifierProvider.notifier).signOut();
          },
        ),
      ),
    );
  }
}
