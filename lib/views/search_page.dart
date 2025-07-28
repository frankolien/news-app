import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowingPage extends ConsumerStatefulWidget {
  const FollowingPage({super.key});

  @override
  ConsumerState<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends ConsumerState<FollowingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample data - replace with your actual data
  final List<FollowingItem> _followingItems = [
    FollowingItem(
      title: 'Food',
      icon: Icons.restaurant,
      iconColor: Colors.red,
      type: FollowingItemType.category,
    ),
    FollowingItem(
      title: 'Saved Recipes',
      icon: Icons.bookmark_outline,
      iconColor: Colors.pink,
      type: FollowingItemType.saved,
    ),
    FollowingItem(
      title: 'Shared with You',
      icon: Icons.people_outline,
      iconColor: Colors.pink,
      type: FollowingItemType.shared,
    ),
    FollowingItem(
      title: 'Saved Stories',
      icon: Icons.bookmark,
      iconColor: Colors.red,
      type: FollowingItemType.saved,
    ),
    FollowingItem(
      title: 'History',
      icon: Icons.history,
      iconColor: Colors.red,
      type: FollowingItemType.history,
    ),
  ];

  final List<FollowingSection> _sections = [
    FollowingSection(
      title: 'Special Coverage',
      items: [
        FollowingItem(
          title: 'Politics',
          icon: Icons.account_balance,
          iconColor: Colors.blue,
          type: FollowingItemType.specialCoverage,
        ),
      ],
    ),
    FollowingSection(
      title: 'Channels & Topics',
      items: [
        FollowingItem(
          title: 'Apple News Spotlight',
          icon: Icons.radio_button_checked,
          iconColor: Colors.pink,
          type: FollowingItemType.channel,
        ),
      ],
    ),
    FollowingSection(
      title: 'Suggested by Siri',
      items: [
        FollowingItem(
          title: 'Business',
          icon: Icons.business_center,
          iconColor: Colors.grey,
          type: FollowingItemType.suggested,
          hasAddButton: true,
        ),
        FollowingItem(
          title: 'Health',
          icon: Icons.local_hospital,
          iconColor: Colors.orange,
          type: FollowingItemType.suggested,
          hasAddButton: true,
        ),
      ],
    ),
  ];

  List<FollowingItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _followingItems;
    return _followingItems
        .where((item) =>
            item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<FollowingSection> get _filteredSections {
    if (_searchQuery.isEmpty) return _sections;
    return _sections
        .map((section) => FollowingSection(
              title: section.title,
              items: section.items
                  .where((item) => item.title
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList(),
            ))
        .where((section) => section.items.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'News',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Following',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Handle edit action
            },
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Channels, Topics, & Stories',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Main following items
                ..._filteredItems.map((item) => _buildFollowingTile(item)),
                const SizedBox(height: 20),
                // Sections
                ..._filteredSections.map((section) => _buildSection(section)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowingTile(FollowingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            color: item.iconColor,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: item.hasAddButton
            ? IconButton(
                onPressed: () {
                  // Handle add action
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.red,
                ),
              )
            : null,
        onTap: () {
          // Handle item tap
        },
      ),
    );
  }

  Widget _buildSection(FollowingSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                section.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
        ...section.items.map((item) => _buildFollowingTile(item)),
        const SizedBox(height: 20),
      ],
    );
  }

 
}

// Data models
class FollowingItem {
  final String title;
  final IconData icon;
  final Color iconColor;
  final FollowingItemType type;
  final bool hasAddButton;

  FollowingItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.type,
    this.hasAddButton = false,
  });
}

class FollowingSection {
  final String title;
  final List<FollowingItem> items;

  FollowingSection({
    required this.title,
    required this.items,
  });
}

enum FollowingItemType {
  category,
  saved,
  shared,
  history,
  specialCoverage,
  channel,
  suggested,
}