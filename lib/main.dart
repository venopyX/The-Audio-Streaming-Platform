import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black87, // Keep your seed color
          brightness: Brightness.dark, // Set brightness to dark
        ),
        useMaterial3: true, // Keep Material 3 enabled
      ),
      home:  YouTubeTwitchTabs(),
    );
  }
}

class YouTubeTwitchTabs extends StatefulWidget {
  @override
  _YouTubeTwitchTabsState createState() => _YouTubeTwitchTabsState();
}

class _YouTubeTwitchTabsState extends State<YouTubeTwitchTabs> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true, // Ensure the body extends behind the navigation bar
        appBar: AppBar(
        title: Row(
        children: [
        Image.asset(
        'assets/logo.png', // Path to your logo asset
        height: 30, // Adjust the height of the logo
        width: 30, // Adjust the width of the logo
    ),
    SizedBox(width: 10), // Add spacing between the logo and text
    Text(
    'My App', // App name or title
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    backgroundColor: Colors.transparent, // Transparent background
    elevation: 0, // Remove shadow
    ),
    body: Center(
    child: _selectedIndex == 0
    ? Text(
    'YouTube Tab',
    style: TextStyle(fontSize: 24),
    )
        : Text(
    'Twitch Tab',
    style: TextStyle(fontSize: 24),
    ),
    ),
    bottomNavigationBar: ClipRect(
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
    child: Container(
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.3), // Semi-transparent white
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    child: BottomNavigationBar(
    currentIndex: _selectedIndex,
    onTap: _onItemTapped,
    backgroundColor: Colors.transparent, // Transparent background
    elevation: 0, // Remove default shadow
    selectedItemColor: Colors.white, // Selected item color
    unselectedItemColor: Colors.white.withOpacity(0.5), // Unselected item color
    items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
    icon: Icon(Icons.video_library), // YouTube icon
    label: 'YouTube',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.live_tv), // Twitch icon
    label: 'Twitch',
    ),
    ],
    ),
    ),
    ),
    ),
    );
  }
}

// Example Screens
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Screen'),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Search Screen'),
    );
  }
}

