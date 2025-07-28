import 'package:news_app/models/news_model.dart';
import 'package:news_app/models/source_model.dart';
import 'package:riverpod/riverpod.dart';
import '../../core/services/api_service.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return NewsRepository(api);
});

class NewsRepository {
  final ApiService _api;
  
  NewsRepository(this._api);
  
  List<Map<String, dynamic>> _extractListFromResponse(dynamic res) {
    if (res is List) {
      return res.cast<Map<String, dynamic>>();
    } else if (res is Map) {
      if (res.containsKey('data') && res['data'] is Map) {
        final dataMap = res['data'] as Map;
        if (dataMap.containsKey('data') && dataMap['data'] is List) {
          final items = dataMap['data'] as List;
          // Extract the 'story' object from each item
          return items.map((item) {
            if (item is Map && item.containsKey('story')) {
              return item['story'] as Map<String, dynamic>;
            }
            return item as Map<String, dynamic>;
          }).toList();
        }
      }
      
      // Try other common API response patterns
      final possibleKeys = ['data', 'items', 'results', 'stories', 'categories'];
      for (String key in possibleKeys) {
        if (res.containsKey(key) && res[key] is List) {
          return (res[key] as List).cast<Map<String, dynamic>>();
        }
      }
      
      print('Response structure: ${res.keys}');
    }
    return [];
  }
  
  // Special method for extracting categories (different structure)
  List<Map<String, dynamic>> _extractCategoriesFromResponse(dynamic res) {
    if (res is List) {
      return res.cast<Map<String, dynamic>>();
    } else if (res is Map) {
      // ...for handling the specific categories Api structure: {message: "", data: {data: [...]}}
      if (res.containsKey('data') && res['data'] is Map) {
        final dataMap = res['data'] as Map;
        if (dataMap.containsKey('data') && dataMap['data'] is List) {
          // For categories, we don't need to extract nested 'story' objects
          return (dataMap['data'] as List).cast<Map<String, dynamic>>();
        }
      }
      
      // ..anohther API response patterns
      /*final possibleKeys = ['data', 'items', 'results', 'categories'];
      for (String key in possibleKeys) {
        if (res.containsKey(key) && res[key] is List) {
          return (res[key] as List).cast<Map<String, dynamic>>();
        }
      }*/
      
      print('Categories response structure: ${res.keys}');
    }
    return [];
  }
  
  Future<List<Source>> fetchCategories() async {
    dynamic res;
    try {
      res = await _api.get('/api/general/categories');
      print('Categories API response: $res'); // Debug log
      
      // ...using the special categories extraction method
      final listData = _extractCategoriesFromResponse(res);

      print('Extracted ${listData.length} categories'); // Debug log
      
      if (listData.isNotEmpty) {
        // Debug log
        print('First category raw data: ${listData.first}'); 
      }
      
      // ...parsing the categories
      final validCategories = <Source>[];
      for (var categoryData in listData) {
        try {
          print('Parsing category data: $categoryData'); // Debug log
          final category = Source.fromJson(categoryData);
          print('Parsed category: $category'); // Debug log
          
          if (category.id != null && category.name != null) {
            validCategories.add(category);
            print('Added valid category: ${category.name} (ID: ${category.id})');
          } else {
            print('Skipping category - ID: ${category.id}, Name: ${category.name}');
          }
        } catch (e, stackTrace) {
          print('Error parsing category: $categoryData');
          print('Error: $e');
          print('Stack trace: $stackTrace');
        }
      }
      
      print('Valid categories count: ${validCategories.length}'); // Debug log
      return validCategories;
    } catch (e, stackTrace) {
      print('Error fetching categories: $e');
      print('Stack trace: $stackTrace');
      print('Full response: $res'); // Debug log
      throw Exception('Failed to fetch categories: $e');
    }
  }
  
  Future<List<NewsModel>> fetchTopStories() async {
    try {
      final res = await _api.get('/api/general/top-stories');
      final listData = _extractListFromResponse(res);
      print('Extracted ${listData.length} top stories');
      
      return listData.map((e) {
        try {
          return NewsModel.fromJson(e);
        } catch (parseError) {
          print('Error parsing story: $e, Error: $parseError');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error fetching top stories: $e');
      throw Exception('Failed to fetch top stories: $e');
    }
  }
  
  Future<List<NewsModel>> fetchEditorsPicks() async {
    try {
      final res = await _api.get('/api/general/editor-picks?page=1&per_page=15');
      final listData = _extractListFromResponse(res);
      return listData.map((e) => NewsModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching editors picks: $e');
      throw Exception('Failed to fetch editors picks: $e');
    }
  }
  
  Future<List<NewsModel>> fetchFeaturedStories() async {
    try {
      final res = await _api.get('/api/general/stories/featured-stories?page=1&per_page=15');
      final listData = _extractListFromResponse(res);
      return listData.map((e) => NewsModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching featured stories: $e');
      throw Exception('Failed to fetch featured stories: $e');
    }
  }
  
  Future<List<NewsModel>> fetchLatestStories() async {
    try {
      final res = await _api.get('/api/general/stories/latest-stories?page=1&per_page=7');
      final listData = _extractListFromResponse(res);
      return listData.map((e) => NewsModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching latest stories: $e');
      throw Exception('Failed to fetch latest stories: $e');
    }
  }
  
  Future<List<NewsModel>> fetchMissedStories() async {
    try {
      final res = await _api.get('/api/general/stories/missed-stories?page=1&per_page=5');
      final listData = _extractListFromResponse(res);
      return listData.map((e) => NewsModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching missed stories: $e');
      throw Exception('Failed to fetch missed stories: $e');
    }
  }
  
  Future<List<NewsModel>> fetchStoriesByCategory(int categoryId) async {
    try {
      // Debug log
      print('Fetching stories for category ID: $categoryId'); 
      final res = await _api.get('/api/general/categories/$categoryId/stories?page=1&per_page=15');
      final listData = _extractListFromResponse(res);
      // Debug log
      print('Found ${listData.length} stories for category $categoryId'); 
      return listData.map((e) => NewsModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching stories by category: $e');
      throw Exception('Failed to fetch stories by category: $e');
    }
  }
  
  Future<NewsModel> fetchSingleStory(int storyId) async {
    try {
      final res = await _api.get('/api/general/stories/$storyId');
      if (res is Map<String, dynamic>) {
        // function to check if the story data is nested under a key
        if (res.containsKey('data') && res['data'] is Map) {
          return NewsModel.fromJson(res['data'] as Map<String, dynamic>);
        } else if (res.containsKey('story') && res['story'] is Map) {
          return NewsModel.fromJson(res['story'] as Map<String, dynamic>);
        } else {
          // ... to Assume the map itself is the story data
          return NewsModel.fromJson(res);
        }
      }
      throw Exception('Invalid response format for single story');
    } catch (e) {
      print('Error fetching single story: $e');
      throw Exception('Failed to fetch story: $e');
    }
  }
}