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
  late FloatingSearchBarController _controller;
  @override
  void initState() {
    super.initState();
    _controller = FloatingSearchBarController();

    Future.microtask(() {
      ref.read(searchHistoryNotifierProvider.notifier).watchSearchTerms();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void pushPageAndPutFirstInHistory(String searchTerm) {
      widget.onSearchTermSubmit(searchTerm);
      ref
          .read(searchHistoryNotifierProvider.notifier)
          .putSearchTermFirst(searchTerm);
      _controller.close();
    }

    void pushPageAndAddToHistory(String searchTerm) {
      widget.onSearchTermSubmit(searchTerm);
      _controller.close();
      ref
          .read(searchHistoryNotifierProvider.notifier)
          .addSearchTerm(searchTerm);
    }

    return FloatingSearchBar(
      controller: _controller,
      onSubmitted: (query) {
        pushPageAndAddToHistory(query);
      },
      onQueryChanged: (query) {
        ref
            .read(searchHistoryNotifierProvider.notifier)
            .watchSearchTerms(term: query);
      },
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
        return Material(
          color: Theme.of(context).cardColor,
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8.0),
          clipBehavior: Clip.hardEdge,
          child: Consumer(
            builder: (context, ref, child) {
              final searchHistoryState =
                  ref.watch(searchHistoryNotifierProvider);

              return searchHistoryState.map(
                data: (data) {
                  if (data.value.isEmpty && _controller.query.isEmpty) {
                    return Container(
                      alignment: Alignment.center,
                      height: 56.0,
                      child: Text(
                        'Start searching...',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  } else if (data.value.isEmpty) {
                    return ListTile(
                      title: Text(
                        _controller.query,
                      ),
                      leading: const Icon(MdiIcons.magnify),
                      onTap: () {
                        pushPageAndAddToHistory(_controller.query);
                      },
                    );
                  }

                  return Column(
                    children: data.value
                        .map(
                          (term) => ListTile(
                            leading: const Icon(MdiIcons.magnify),
                            title: Text(term),
                            onTap: () {
                              pushPageAndPutFirstInHistory(term);
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                ref
                                    .read(
                                      searchHistoryNotifierProvider.notifier,
                                    )
                                    .deleteSearchTerm(term);
                              },
                            ),
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
          ),
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
