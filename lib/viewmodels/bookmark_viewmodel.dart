// lib/providers/bookmark_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/core/services/bookmark_service.dart';
import 'package:news_app/models/news_model.dart';

final bookmarkServiceProvider = Provider<BookmarkService>((ref) => BookmarkService());

final bookmarkedStoriesProvider = FutureProvider<List<NewsModel>>((ref) async {
  print('DEBUG: bookmarkedStoriesProvider called');
  final bookmarkService = ref.watch(bookmarkServiceProvider);
  final stories = await bookmarkService.getBookmarkedStories();
  print('DEBUG: Retrieved ${stories.length} bookmarked stories from service');
  return stories;
});

// Change this to AsyncNotifierProvider for better async handling
final bookmarkNotifierProvider = AsyncNotifierProvider<BookmarkNotifier, Set<int>>(() {
  return BookmarkNotifier();
});

class BookmarkNotifier extends AsyncNotifier<Set<int>> {
  BookmarkService get _bookmarkService => ref.read(bookmarkServiceProvider);

  @override
  Future<Set<int>> build() async {
    print('DEBUG: BookmarkNotifier build() called');
    // Load initial bookmarked IDs
    final bookmarkedStories = await _bookmarkService.getBookmarkedStories();
    final ids = bookmarkedStories.map((story) => story.id!).toSet();
    print('DEBUG: Loaded bookmark IDs: $ids');
    return ids;
  }

  Future<bool> toggleBookmark(NewsModel story) async {
    if (story.id == null) {
      print('DEBUG: Story has no ID, cannot bookmark');
      return false;
    }

    print('DEBUG: Toggling bookmark for story ID: ${story.id}, title: ${story.title}');
    
    // Get current state
    final currentState = state.valueOrNull ?? <int>{};
    
    if (currentState.contains(story.id)) {
      print('DEBUG: Removing bookmark for story ID: ${story.id}');
      final success = await _bookmarkService.removeBookmark(story.id!);
      if (success) {
        final newState = Set<int>.from(currentState)..remove(story.id);
        state = AsyncData(newState);
        print('DEBUG: Successfully removed bookmark. New state: $newState');
        
        // Invalidate the bookmarked stories provider to refresh the list
        ref.invalidate(bookmarkedStoriesProvider);
      } else {
        print('DEBUG: Failed to remove bookmark from service');
      }
      return success;
    } else {
      print('DEBUG: Adding bookmark for story ID: ${story.id}');
      final success = await _bookmarkService.addBookmark(story);
      if (success) {
        final newState = Set<int>.from(currentState)..add(story.id!);
        state = AsyncData(newState);
        print('DEBUG: Successfully added bookmark. New state: $newState');
        
        // Invalidate the bookmarked stories provider to refresh the list
        ref.invalidate(bookmarkedStoriesProvider);
      } else {
        print('DEBUG: Failed to add bookmark to service');
      }
      return success;
    }
  }

  bool isBookmarked(int storyId) {
    final currentState = state.valueOrNull ?? <int>{};
    final isBookmarked = currentState.contains(storyId);
    print('DEBUG: Checking if story ID $storyId is bookmarked: $isBookmarked');
    return isBookmarked;
  }

  Future<void> clearAllBookmarks() async {
    print('DEBUG: Clearing all bookmarks');
    final success = await _bookmarkService.clearAllBookmarks();
    if (success) {
      state = const AsyncData(<int>{});
      print('DEBUG: Successfully cleared all bookmarks');
      
      // Invalidate the bookmarked stories provider to refresh the list
      ref.invalidate(bookmarkedStoriesProvider);
    } else {
      print('DEBUG: Failed to clear all bookmarks');
    }
  }

  // Helper method to refresh bookmarks from storage
  Future<void> refresh() async {
    print('DEBUG: Refreshing bookmarks');
    state = const AsyncLoading();
    try {
      final bookmarkedStories = await _bookmarkService.getBookmarkedStories();
      final ids = bookmarkedStories.map((story) => story.id!).toSet();
      state = AsyncData(ids);
      print('DEBUG: Refreshed bookmark IDs: $ids');
    } catch (error, stackTrace) {
      print('DEBUG: Error refreshing bookmarks: $error');
      state = AsyncError(error, stackTrace);
    }
  }
}

// Optional: Add a provider to check if a specific story is bookmarked
final isStoryBookmarkedProvider = Provider.family<bool, int>((ref, storyId) {
  final bookmarkState = ref.watch(bookmarkNotifierProvider);
  return bookmarkState.when(
    data: (bookmarks) => bookmarks.contains(storyId),
    loading: () => false,
    error: (_, __) => false,
  );
});

// Optional: Add a provider for bookmark count
final bookmarkCountProvider = Provider<int>((ref) {
  final bookmarkState = ref.watch(bookmarkNotifierProvider);
  return bookmarkState.when(
    data: (bookmarks) => bookmarks.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});