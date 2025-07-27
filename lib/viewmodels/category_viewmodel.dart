
// lib/viewmodels/category_stories_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/data/repositories/news_repository.dart';
import 'package:news_app/models/news_model.dart';

final categoryStoriesViewModelProvider = StateNotifierProvider.family<CategoryStoriesViewModel, CategoryStoriesState, int>(
  (ref, categoryId) {
    final repository = ref.watch(newsRepositoryProvider);
    return CategoryStoriesViewModel(repository, categoryId);
  },
);

class CategoryStoriesState {
  final List<NewsModel> stories;
  final bool isLoading;
  final String? error;

  CategoryStoriesState({
    this.stories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryStoriesState copyWith({
    List<NewsModel>? stories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryStoriesState(
      stories: stories ?? this.stories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CategoryStoriesViewModel extends StateNotifier<CategoryStoriesState> {
  final NewsRepository _repository;
  final int categoryId;

  CategoryStoriesViewModel(this._repository, this.categoryId) : super(CategoryStoriesState()) {
    fetchStories();
  }

  Future<void> fetchStories() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final stories = await _repository.fetchStoriesByCategory(categoryId);
      state = state.copyWith(
        stories: stories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}