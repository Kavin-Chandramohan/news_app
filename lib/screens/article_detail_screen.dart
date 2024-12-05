import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_article.dart';
import '../providers/news_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

// A screen to display the detailed view of a news article.
class ArticleDetailScreen extends StatelessWidget {
  final NewsArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  // Function to open the article's URL in the browser.
  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(article.url);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch ${article.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        // Action buttons for bookmarking and sharing the article.
        actions: [
          IconButton(
            icon: Icon(
              article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: () {
              Provider.of<NewsProvider>(context, listen: false)
                  .toggleBookmark(article);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            // Share button to share the article link and title.
            onPressed: () {
              Share.share(
                '${article.title}\n\nRead more: ${article.url}',
                subject: article.title,
              );
            },
          ),
        ],
      ),

      // Body of the screen containing article details.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Image
            article.urlToImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: article.urlToImage,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )
                : Container(),

            // Article Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),

                  // Author and Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'By ${article.author}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        DateFormat('MMMM d, yyyy')
                            .format(DateTime.parse(article.publishedAt)),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    article.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),

                  // Full Article Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _launchUrl,
                      child: const Text('Read Full Article'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
