import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/news_article.dart';
import '../providers/news_provider.dart';
import 'article_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

// A screen that displays the list of bookmarked articles.
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  // Displays a bottom sheet for sorting options.
  void _showSortOptionsBottomSheet(
      BuildContext context, NewsProvider newsProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Sort By',
                  style: Theme.of(context).textTheme.titleLarge),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            RadioListTile<SortOption>(
              title: const Text('Newest First'),
              value: SortOption.newest,
              groupValue: newsProvider.currentSortOption,
              onChanged: (SortOption? value) {
                if (value != null) {
                  newsProvider.changeSortOption(value); // Change the sort option.
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<SortOption>(
              title: const Text('Oldest First'),
              value: SortOption.oldest,
              groupValue: newsProvider.currentSortOption,
              onChanged: (SortOption? value) {
                if (value != null) {
                  newsProvider.changeSortOption(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<SortOption>(
              title: const Text('Alphabetical'),
              value: SortOption.alphabetical,
              groupValue: newsProvider.currentSortOption,
              onChanged: (SortOption? value) {
                if (value != null) {
                  newsProvider.changeSortOption(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(
              'Bookmarked Articles',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () {
                  final newsProvider =
                      Provider.of<NewsProvider>(context, listen: false);
                  _showSortOptionsBottomSheet(context, newsProvider); // Show sort options.
                },
              ),
            ],
          ),

          // Body
          Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              final bookmarks = newsProvider.bookmarkedArticles;

              if (bookmarks.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bookmark_border,
                            size: 100, color: Colors.grey),
                        const SizedBox(height: 20),
                        Text(
                          'No bookmarked articles',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Apply sorting to bookmarked articles
              final sortedBookmarks = () {
                switch (newsProvider.currentSortOption) {
                  case SortOption.newest:
                    return List<NewsArticle>.from(bookmarks)
                      ..sort((a, b) => DateTime.parse(b.publishedAt)
                          .compareTo(DateTime.parse(a.publishedAt)));
                  case SortOption.oldest:
                    return List<NewsArticle>.from(bookmarks)
                      ..sort((a, b) => DateTime.parse(a.publishedAt)
                          .compareTo(DateTime.parse(b.publishedAt)));
                  case SortOption.alphabetical:
                    return List<NewsArticle>.from(bookmarks)
                      ..sort((a, b) => a.title.compareTo(b.title));
                }
              }();

              // Display sorted bookmarks in a list.
              return SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = sortedBookmarks[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ArticleDetailScreen(article: article))); // Navigate to article details.
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Article Image
                                if (article.urlToImage.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: article.urlToImage,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),

                                // Article Details
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          article.description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Delete Bookmark Icon
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    newsProvider.toggleBookmark(article); // Remove the bookmark.
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: sortedBookmarks.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
