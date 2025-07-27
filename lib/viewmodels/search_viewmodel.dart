
import 'package:news_app/models/news_model.dart';
import 'package:riverpod/riverpod.dart';


final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredStoriesProvider = Provider.family<List<NewsModel>, List<NewsModel>>((ref, allStories) {
  final query = ref.watch(searchQueryProvider);
  return allStories
      .where((story) => (story.title ?? '').toLowerCase().contains(query.toLowerCase()))
      .toList();
});