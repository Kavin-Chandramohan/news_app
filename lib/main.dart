import 'package:flutter/material.dart';
import 'package:newsapp/screens/home_screen.dart';
import 'package:provider/provider.dart';
import './providers/news_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Adding the NewsProvider to manage state across the app.
        ChangeNotifierProvider(create: (context) => NewsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumes the NewsProvider to toggle themes dynamically.
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false, // Removes the debug banner.
          title: 'News App',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blueGrey,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blueGrey[900],
              foregroundColor: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.grey[900],
          ),

          // switches between light and dark themes based on isDarkMode.
          themeMode: newsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}
