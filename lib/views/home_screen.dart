
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/views/bookmark_view.dart';
import 'package:news_app/views/widgets/category_card.dart';
import 'package:news_app/views/widgets/skeleton_shimmer.dart';
import 'package:news_app/views/widgets/story_card.dart';
import 'package:news_app/views/widgets/featured_story_card.dart';
import '../../viewmodels/home_viewmodel.dart';

class HomeView extends ConsumerWidget {
  HomeView({super.key});
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer(BuildContext context) {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer(BuildContext context) {
    scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: scaffoldKey,
      drawer: _buildDrawer(context),
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: homeState.isLoading
          ? const NewsSkeleton(itemCount: 7)
          : homeState.error != null
              ? _buildErrorState(ref, homeState.error!)
              : RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(homeViewModelProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBannerAd(size),
                        _buildCategoriesSection(homeState),
                        _buildTopStoriesSection(homeState),
                        _buildEditorsPickSection(homeState),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Image.asset('lib/images/news.png', height: 50),
            centerTitle: false,
            backgroundColor: const Color(0xFF2D3748),
            automaticallyImplyLeading: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Analytics'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('Bookmarks'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BookmarksView()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2D3748),
      leadingWidth: double.infinity,
      leading: Builder(
        builder: (context) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
                Image.asset('lib/images/news.png', height: 50),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookmarksView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading news',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.refresh(homeViewModelProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerAd(Size size) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: size.height * 0.08,
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Image.asset('assets/images/advert.png', height: 60),
      ),
    );
  }

  // Updated _buildCategoriesSection method for home_view.dart
// Don't forget to add the import at the top of your home_view.dart file:
// import 'package:news_app/views/widgets/category_cards.dart';

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
  
  print('Valid categories after filtering: ${validCategories.length}');
  print('========================');
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C5CE7),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "CATEGORIES",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                          ),
      const SizedBox(height: 16),
      
      // Use the new CategoryCards widget
      CategoryCards(categories: validCategories),
      
      const SizedBox(height: 24),
    ],
  );
}
  Widget _buildTopStoriesSection(dynamic homeState) {
    if (homeState.topStories.isEmpty) return const SizedBox.shrink();

    return  Column(
      children:[ 
        Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C5CE7),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "TOP STORIES",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                ],
                              ),
                            ),

        const SizedBox(height: 16),
        FeaturedStoryCard(story: homeState.topStories.first),
                            ]
    );
  }
  

  Widget _buildEditorsPickSection(dynamic homeState) {
    if (homeState.editorsPick.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C5CE7),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "EDITOR'S PICK",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                ],
                              ),
                            ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
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
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: homeState.editorsPick.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return StoryCard(
              story: homeState.editorsPick[index],
              showCategory: true,
              categoryText: "NEWS TODAY",
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
