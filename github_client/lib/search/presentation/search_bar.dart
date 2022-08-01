import 'package:flutter/material.dart';
import 'package:github_client/search/shared/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class SearchBar extends ConsumerStatefulWidget {
  final String title;
  final String hint;
  final Widget body;
  final void Function(String searchTerm) onSearchTermSubmit;
  final void Function() onLogoutAction;

  const SearchBar({
    required this.title,
    required this.hint,
    required this.body,
    required this.onSearchTermSubmit,
    required this.onLogoutAction,
  });

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
    return FloatingSearchBar(
      onSubmitted: widget.onSearchTermSubmit,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            'Tap to search 👆',
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      hint: widget.hint,
      builder: (context, transition) {
        return Consumer(
          builder: (context, ref, child) {
            final searchHistoryState = ref.watch(searchHistoryNotifierProvider);

            return searchHistoryState.map(
              data: (data) {
                return Column(
                  children: data.value
                      .map(
                        (term) => ListTile(
                          title: Text(term),
                        ),
                      )
                      .toList(),
                );
              },
              error: (_) => ListTile(
                title: Text('Very unexpected error: ${_.error}'),
              ),
              loading: (_) => const ListTile(
                title: LinearProgressIndicator(),
              ),
            );
          },
        );
      },
      body: FloatingSearchBarScrollNotifier(child: widget.body),
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
        FloatingSearchBarAction(
          child: IconButton(
            onPressed: widget.onLogoutAction,
            icon: const Icon(MdiIcons.logoutVariant),
            splashRadius: 18,
          ),
        )
      ],
    );
  }
}
