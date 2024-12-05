import 'package:flutter/material.dart';
import 'package:newsapp/screens/setting_screen.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/news_provider.dart';
import 'article_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Categories for the news
  final List<String> categories = [
    'general',
    'business',
    'technology',
    'entertainment',
    'sports',
    'science'
  ];

  @override
  void initState() {
    super.initState();
    // Reset to default news when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      newsProvider.resetToDefaultNews(); // Reset to original news state
    });
  }

  // Function to show sort options in a bottom sheet
  void _showSortOptionsBottomSheet(NewsProvider newsProvider) {
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
                  newsProvider.changeSortOption(value);
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
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // AppBar with actions like sorting and settings
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text('News App',
                    style: Theme.of(context).textTheme.headlineSmall),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: () => _showSortOptionsBottomSheet(newsProvider),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
              // Horizontal category selection for news
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10),
                    child: Row(
                      children: categories
                          .map((category) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ChoiceChip(
                                  label: Text(
                                    category,
                                    style: TextStyle(
                                      color: newsProvider.currentCategory ==
                                              category
                                          ? Colors.black
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                    ),
                                  ),
                                  selected:
                                      newsProvider.currentCategory == category,
                                  onSelected: (_) {
                                    // Fetch news for the selected category
                                    newsProvider.fetchNews(category: category);
                                  },
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                  selectedColor: Colors.blue[300],
                                  checkmarkColor: Colors.white,
                                  side: BorderSide(
                                    color:
                                        newsProvider.currentCategory == category
                                            ? Colors.blue
                                            : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),

              // Carousel for TechCrunch articles
              SliverToBoxAdapter(
                child: newsProvider.isTechCrunchLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CarouselSlider(
                        options: CarouselOptions(
                          height: 220.0,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          viewportFraction: 0.85,
                        ),
                        items: newsProvider.techCrunchArticles.map((article) {
                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ArticleDetailScreen(
                                                  article: article)));
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      )
                                    ],
                                    image: article.urlToImage.isNotEmpty
                                        ? DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                article.urlToImage),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: article.urlToImage.isEmpty
                                      ? Center(
                                          child: Text(
                                            article.title,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        )
                                      : Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                bottom: Radius.circular(15),
                                              ),
                                            ),
                                            child: Text(
                                              article.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
              ),

              // List of news articles
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = newsProvider.articles[index];
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
                                        ArticleDetailScreen(article: article)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                IconButton(
                                  icon: Icon(
                                    article.isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: article.isBookmarked
                                        ? Colors.blue
                                        : null,
                                  ),
                                  onPressed: () {
                                    newsProvider.toggleBookmark(article);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: newsProvider.articles.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
