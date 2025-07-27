import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/models/news_model.dart';
import '../data/repositories/news_repository.dart';
import 'package:news_app/models/source_model.dart';
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final repository = ref.watch(newsRepositoryProvider);
  return HomeViewModel(repository);
});

class HomeState {
  final List<NewsModel> topStories;
  final List<NewsModel> editorsPick;
  final List<Source> categories;
  final bool isLoading;
  final String? error;

  HomeState({
    this.topStories = const [],
    this.editorsPick = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<NewsModel>? topStories,
    List<NewsModel>? editorsPick,
    List<Source>? categories,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      topStories: topStories ?? this.topStories,
      editorsPick: editorsPick ?? this.editorsPick,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final NewsRepository _repository;

  HomeViewModel(this._repository) : super(HomeState()) {
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    print('=== HOME VIEW MODEL DEBUG ===');
    print('Starting to load home data...');
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      print('Fetching categories...');
      final categories = await _repository.fetchCategories();
      print('Categories fetched: ${categories.length}');
      
      print('Fetching top stories...');
      final topStories = await _repository.fetchTopStories();
      print('Top stories fetched: ${topStories.length}');
      
      print('Fetching editors pick...');
      final editorsPick = await _repository.fetchEditorsPicks();
      print('Editors pick fetched: ${editorsPick.length}');

      state = state.copyWith(
        categories: categories,
        topStories: topStories,
        editorsPick: editorsPick,
        isLoading: false,
      );
      
      print('Home data loaded successfully!');
      print('Final state - Categories: ${state.categories.length}, Top Stories: ${state.topStories.length}, Editors Pick: ${state.editorsPick.length}');
    } catch (e) {
      print('Error loading home data: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
    print('==============================');
  }
}
