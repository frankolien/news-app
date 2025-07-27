
import 'package:news_app/models/news_model.dart';
import 'package:riverpod/riverpod.dart';
import '../data/repositories/news_repository.dart';


final storyDetailProvider = FutureProvider.family<NewsModel, int>((ref, storyId) {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.fetchSingleStory(storyId);
});