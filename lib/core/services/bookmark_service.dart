// lib/services/bookmark_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_app/models/news_model.dart';

class BookmarkService {
  static const String _bookmarksKey = 'bookmarked_stories';

  // Get all bookmarked stories
  Future<List<NewsModel>> getBookmarkedStories() async {
    try {
      print('DEBUG: BookmarkService.getBookmarkedStories() called');
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      print('DEBUG: Found ${bookmarksJson.length} bookmarks in storage');
      
      if (bookmarksJson.isEmpty) {
        print('DEBUG: No bookmarks found in storage');
        return [];
      }

      final stories = <NewsModel>[];
      for (int i = 0; i < bookmarksJson.length; i++) {
        try {
          final jsonString = bookmarksJson[i];
          print('DEBUG: Parsing bookmark $i: ${jsonString.substring(0, 100)}...');
          
          final Map<String, dynamic> json = jsonDecode(jsonString);
          final story = NewsModel.fromJson(json);
          stories.add(story);
          print('DEBUG: Successfully parsed story: ${story.title} (ID: ${story.id})');
        } catch (e) {
          print('DEBUG: Error parsing bookmark at index $i: $e');
          // Continue with other bookmarks even if one fails
        }
      }
      
      print('DEBUG: Returning ${stories.length} valid stories');
      return stories;
    } catch (e) {
      print('DEBUG: Error getting bookmarked stories: $e');
      return [];
    }
  }

  // function yo add a story to bookmarks
  Future<bool> addBookmark(NewsModel story) async {
    try {
      print('DEBUG: BookmarkService.addBookmark() called for story: ${story.title} (ID: ${story.id})');
      
      if (story.id == null) {
        print('DEBUG: Cannot bookmark story without ID');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      print('DEBUG: Current bookmarks count: ${bookmarksJson.length}');

      // function to check if already bookmarked
      final isAlreadyBookmarked = bookmarksJson.any((jsonString) {
        try {
          final Map<String, dynamic> json = jsonDecode(jsonString);
          return json['id'] == story.id;
        } catch (e) {
          print('DEBUG: Error checking existing bookmark: $e');
          return false;
        }
      });

      if (isAlreadyBookmarked) {
        print('DEBUG: Story already bookmarked');
        return false;
      }

      // convert story to JSON and validate
      final storyJson = story.toJson();
      final storyJsonString = jsonEncode(storyJson);
      print('DEBUG: Story JSON: ${storyJsonString.substring(0, 200)}...');

      // validate that we can parse it back
      try {
        final testParse = NewsModel.fromJson(jsonDecode(storyJsonString));
        print('DEBUG: JSON validation successful: ${testParse.title}');
      } catch (e) {
        print('DEBUG: JSON validation failed: $e');
        return false;
      }

      bookmarksJson.add(storyJsonString);
      await prefs.setStringList(_bookmarksKey, bookmarksJson);
      print('DEBUG: Successfully saved bookmark. Total count: ${bookmarksJson.length}');
      
      // Verify it was saved
      final verifyList = prefs.getStringList(_bookmarksKey) ?? [];
      print('DEBUG: Verification - storage now contains ${verifyList.length} bookmarks');
      
      return true;
    } catch (e) {
      print('DEBUG: Error adding bookmark: $e');
      return false;
    }
  }

  // function to remove a story from bookmarks
  Future<bool> removeBookmark(int storyId) async {
    try {
      print('DEBUG: BookmarkService.removeBookmark() called for ID: $storyId');
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      print('DEBUG: Current bookmarks count before removal: ${bookmarksJson.length}');

      final originalLength = bookmarksJson.length;
      bookmarksJson.removeWhere((jsonString) {
        try {
          final Map<String, dynamic> json = jsonDecode(jsonString);
          final matches = json['id'] == storyId;
          if (matches) {
            print('DEBUG: Found and removing bookmark with ID: $storyId');
          }
          return matches;
        } catch (e) {
          print('DEBUG: Error checking bookmark for removal: $e');
          return false;
        }
      });

      final removed = originalLength != bookmarksJson.length;
      if (removed) {
        await prefs.setStringList(_bookmarksKey, bookmarksJson);
        print('DEBUG: Successfully removed bookmark. New count: ${bookmarksJson.length}');
      } else {
        print('DEBUG: No bookmark found with ID: $storyId');
      }

      return removed;
    } catch (e) {
      print('DEBUG: Error removing bookmark: $e');
      return false;
    }
  }

  // function to check if a story is bookmarked
  Future<bool> isBookmarked(int storyId) async {
    try {
      print('DEBUG: BookmarkService.isBookmarked() called for ID: $storyId');
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      
      final isBookmarked = bookmarksJson.any((jsonString) {
        try {
          final Map<String, dynamic> json = jsonDecode(jsonString);
          return json['id'] == storyId;
        } catch (e) {
          print('DEBUG: Error checking bookmark: $e');
          return false;
        }
      });
      
      print('DEBUG: Story ID $storyId is bookmarked: $isBookmarked');
      return isBookmarked;
    } catch (e) {
      print('DEBUG: Error checking bookmark status: $e');
      return false;
    }
  }

  // function to claer  all bookmarks
  Future<bool> clearAllBookmarks() async {
    try {
      print('DEBUG: BookmarkService.clearAllBookmarks() called');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookmarksKey);
      print('DEBUG: Successfully cleared all bookmarks');
      
      // function to check if it was cleared
      final verifyList = prefs.getStringList(_bookmarksKey) ?? [];
      print('DEBUG: Verification - storage now contains ${verifyList.length} bookmarks');
      
      return true;
    } catch (e) {
      print('DEBUG: Error clearing bookmarks: $e');
      return false;
    }
  }

  // Debug method to inspect current bookmarks
  Future<void> debugPrintBookmarks() async {
    try {
      print('DEBUG: === BOOKMARK DEBUG INFO ===');
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      print('DEBUG: Total bookmarks in storage: ${bookmarksJson.length}');
      
      for (int i = 0; i < bookmarksJson.length; i++) {
        try {
          final json = jsonDecode(bookmarksJson[i]);
          print('DEBUG: Bookmark $i - ID: ${json['id']}, Title: ${json['title']}');
        } catch (e) {
          print('DEBUG: Bookmark $i - Invalid JSON: $e');
        }
      }
      print('DEBUG: === END BOOKMARK DEBUG ===');
    } catch (e) {
      print('DEBUG: Error in debugPrintBookmarks: $e');
    }
  }
}