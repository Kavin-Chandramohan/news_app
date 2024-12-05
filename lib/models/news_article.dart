class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String author;
  final String publishedAt;
  final String content;
  bool isBookmarked; // Indicates if the article is bookmarked by the user.

  // Constructor for initializing a `NewsArticle` object.
  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.author,
    required this.publishedAt,
    required this.content,
    this.isBookmarked = false,
  });

  // Factory constructor to create a `NewsArticle` object from a JSON map.
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      author: json['author'] ?? 'Unknown Author',
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'] ?? '',
    );
  }

  // Converts the `NewsArticle` object into a map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'author': author,
      'publishedAt': publishedAt,
      'content': content,
      'isBookmarked': isBookmarked ? 1 : 0, // Convert bool to int for database storage.
    };
  }

  // Factory constructor to create a `NewsArticle` object from a map, typically retrieved from a database.
  factory NewsArticle.fromMap(Map<String, dynamic> map) {
    return NewsArticle(
      title: map['title'],
      description: map['description'],
      url: map['url'],
      urlToImage: map['urlToImage'],
      author: map['author'],
      publishedAt: map['publishedAt'],
      content: map['content'],
      isBookmarked: map['isBookmarked'] == 1,
    );
  }
}
