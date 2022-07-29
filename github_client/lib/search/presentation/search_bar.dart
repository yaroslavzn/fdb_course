import 'package:flutter/cupertino.dart';
import 'package:github_client/search/shared/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchBar extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SearchBarState();
  }
}

class _SearchBarState extends ConsumerState<SearchBar> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(searchHistoryNotifierProvider.notifier).watchSearchTerms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
