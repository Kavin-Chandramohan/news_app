import 'package:flutter/material.dart';
import 'package:newsapp/screens/bookmarks_screen.dart';
import 'package:newsapp/screens/search_article_screen.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';

// Screen for managing user settings and preferences.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(Icons.bookmark, size: 28),
                          title: const Text(
                            'Bookmarks',
                            style: TextStyle(fontSize: 18),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BookmarksScreen(),
                              ),
                            ).then((_) {
                              // Reset news state when navigating back
                              Provider.of<NewsProvider>(context, listen: false)
                                  .resetToDefaultNews();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(Icons.search, size: 28),
                          title: const Text(
                            'Search Articles',
                            style: TextStyle(fontSize: 18),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            ).then((_) {
                              // Reset news state when navigating back
                              Provider.of<NewsProvider>(context, listen: false)
                                  .resetToDefaultNews();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: SwitchListTile(
                          title: Text(
                            newsProvider.isDarkMode
                                ? 'Dark Mode'
                                : 'Light Mode',
                            style: const TextStyle(fontSize: 18),
                          ),
                          value: newsProvider.isDarkMode,
                          activeColor: Colors.purple,
                          onChanged: (_) {
                            newsProvider.toggleDarkMode(); // Toggle between modes.
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
