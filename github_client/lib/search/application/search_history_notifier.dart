import 'package:github_client/search/infrastructure/search_history_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchHistoryNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final SearchHistoryRepository _repository;

  SearchHistoryNotifier(this._repository) : super(const AsyncValue.loading());

  void watchSearchTerms({String? term}) {
    _repository.watchSearchTerms(filter: term).listen(
      (data) {
        state = AsyncValue.data(data);
      },
      onError: (Object error) {
        state = AsyncValue.error(error);
      },
    );
  }

  Future<void> addSearchTerm(String term) => _repository.addSearchTerm(term);

  Future<void> deleteSearchTerm(String term) =>
      _repository.deleteSearchTerm(term);

  Future<void> putSearchTermFirst(String term) =>
      _repository.putSearchTermFirst(term);
}
