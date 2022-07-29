import 'package:github_client/core/shared/providers.dart';
import 'package:github_client/search/application/search_history_notifier.dart';
import 'package:github_client/search/infrastructure/search_history_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final searchHistoryRepositoryProvider = Provider(
  (ref) => SearchHistoryRepository(
    ref.watch(sembastProvider),
  ),
);

final searchHistoryNotifierProvider =
    StateNotifierProvider<SearchHistoryNotifier, AsyncValue<List<String>>>(
  (ref) => SearchHistoryNotifier(
    ref.watch(searchHistoryRepositoryProvider),
  ),
);
