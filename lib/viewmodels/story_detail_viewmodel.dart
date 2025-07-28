import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/models/news_model.dart';
import 'package:news_app/viewmodels/home_viewmodel.dart';

// Provider for search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider to filter stories based on search query
final filteredTopStoriesProvider = Provider<List<NewsModel>>((ref) {
  final homeState = ref.watch(homeViewModelProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  
  if (searchQuery.isEmpty) {
    return homeState.topStories;
  }
  
  return homeState.topStories
      .where((story) => 
          (story.title ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
          (story.description ?? '').toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();
});

// filter editor's pick stories
final filteredEditorsPickProvider = Provider<List<NewsModel>>((ref) {
  final homeState = ref.watch(homeViewModelProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  
  if (searchQuery.isEmpty) {
    return homeState.editorsPick;
  }
  
  return homeState.editorsPick
      .where((story) => 
          (story.title ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
          (story.description ?? '').toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();
});

// check if search is active
final isSearchActiveProvider = Provider<bool>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  return searchQuery.isNotEmpty;
});

//  get total filtered results count
final filteredResultsCountProvider = Provider<int>((ref) {
  final filteredTopStories = ref.watch(filteredTopStoriesProvider);
  final filteredEditorsPick = ref.watch(filteredEditorsPickProvider);
  
  return filteredTopStories.length + filteredEditorsPick.length;
});