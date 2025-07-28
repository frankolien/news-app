import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/views/widgets/homescreenview/category_card.dart';
import 'package:news_app/views/widgets/homescreenview/category_cards.dart';
import 'package:news_app/views/widgets/homescreenview/error_state.dart';
import 'package:news_app/views/widgets/homescreenview/featured_story_card.dart';
import 'package:news_app/views/widgets/homescreenview/home_app_bar.dart';
import 'package:news_app/views/widgets/homescreenview/home_drawe.dart';
import 'package:news_app/views/widgets/homescreenview/section_header.dart';
import 'package:news_app/views/widgets/homescreenview/skeleton_shimmer.dart';
import 'package:news_app/views/widgets/homescreenview/story_card.dart';
import '../../viewmodels/home_viewmodel.dart';

// Search providers
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredTopStoriesProvider = Provider<List<dynamic>>((ref) {
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

final filteredEditorsPickProvider = Provider<List<dynamic>>((ref) {
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

final isSearchActiveProvider = Provider<bool>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  return searchQuery.isNotEmpty;
});

class HomeView extends ConsumerWidget {
  HomeView({super.key});
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final isSearchActive = ref.watch(isSearchActiveProvider);

    return Scaffold(
      key: scaffoldKey,
      drawer: const HomeDrawer(),
      backgroundColor: Colors.grey[50],
      appBar: const HomeAppBar(),
      body: homeState.isLoading
          ? const NewsSkeleton(itemCount: 7)
          : homeState.error != null
              ? ErrorState(
                  error: homeState.error!,
                  onRetry: () => ref.refresh(homeViewModelProvider),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(homeViewModelProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SearchBar(),
                        
                        if (isSearchActive) _buildSearchResultsInfo(ref),
                        
                        // Only show categories when not searching
                        if (!isSearchActive) _buildCategoriesSection(homeState),
                        
                        _buildTopStoriesSection(ref),
                        _buildEditorsPickSection(ref),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSearchResultsInfo(WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final filteredTopStories = ref.watch(filteredTopStoriesProvider);
    final filteredEditorsPick = ref.watch(filteredEditorsPickProvider);
    final totalResults = filteredTopStories.length + filteredEditorsPick.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Found $totalResults result${totalResults != 1 ? 's' : ''} for "$searchQuery"',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = '';
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(dynamic homeState) {
    print('=== CATEGORIES DEBUG ===');
    print('homeState type: ${homeState.runtimeType}');
    print('Total categories from API: ${homeState.categories?.length ?? 'null'}');
    
    // Check if categories is null or empty
    if (homeState.categories == null) {
      print('Categories is null!');
      return const SizedBox.shrink();
    }
    
    if (homeState.categories.length == 0) {
      print('Categories is empty!');
      return const SizedBox.shrink();
    }
    
    // Debug: Print all categories
    for (int i = 0; i < homeState.categories.length; i++) {
      final cat = homeState.categories[i];
      print('Category $i: id=${cat.id}, name=${cat.name}');
    }
    
    // Filter out categories that don't have valid IDs
    final validCategories = homeState.categories
        .where((category) => category.id != null)
        .toList();
  
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "CATEGORIES"),
        const SizedBox(height: 16),
        CategoryCard(categories: validCategories, category: null,),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTopStoriesSection(WidgetRef ref) {
    final filteredTopStories = ref.watch(filteredTopStoriesProvider);
    final isSearchActive = ref.watch(isSearchActiveProvider);

    if (filteredTopStories.isEmpty) {
      if (isSearchActive) {
        return const SizedBox.shrink(); // Don't show empty state during search
      }
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SectionHeader(title: "TOP STORIES"),
        const SizedBox(height: 16),
        // Show all filtered stories during search, otherwise just the first one
        if (isSearchActive) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (int i = 0; i < filteredTopStories.length; i++) ...[
                  StoryCard(
                    story: filteredTopStories[i],
                    showCategory: true,
                    categoryText: "TOP STORY",
                  ),
                  if (i < filteredTopStories.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ] else ...[
          FeaturedStoryCard(story: filteredTopStories.first),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEditorsPickSection(WidgetRef ref) {
    final filteredEditorsPick = ref.watch(filteredEditorsPickProvider);
    final isSearchActive = ref.watch(isSearchActiveProvider);

    if (filteredEditorsPick.isEmpty) {
      if (isSearchActive) {
        return const SizedBox.shrink(); // Don't show empty state during search
      }
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const SectionHeader(title: "EDITOR'S PICK"),
        const SizedBox(height: 16),
        if (!isSearchActive) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "LATEST TODAY",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Use a simple Column with manual spacing
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (int i = 0; i < filteredEditorsPick.length; i++) ...[
                StoryCard(
                  story: filteredEditorsPick[i],
                  showCategory: true,
                  categoryText: isSearchActive ? "EDITOR'S PICK" : "NEWS TODAY",
                ),
                if (i < filteredEditorsPick.length - 1) const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// Custom SearchBar widget
class SearchBar extends ConsumerWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Search stories by title...',
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 24,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}