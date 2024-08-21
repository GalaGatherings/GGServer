import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:gala_gatherings/screens/FeedPage.dart';
import 'package:gala_gatherings/screens/FilterPage.dart';
import 'package:gala_gatherings/screens/MessagesPage.dart';
import 'package:gala_gatherings/screens/profile_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex; // Optional parameter for setting the initial tab index

  MainLayout({this.initialIndex = 0}); // Default to 0 (FeedPage) if not provided

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex; // Use `late` to defer initialization until `initState`

  final List<Widget> _pages = [
    FeedPage(),  // FeedPage is the first page
    MessagesPage(),
    FilterPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Initialize _currentIndex in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],  // Display the selected page
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        showElevation: true, // Show shadow on the bar
        onItemSelected: (index) => setState(() {
          _currentIndex = index;
        }),
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text('Feed'),
            activeColor: Colors.purpleAccent,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.message),
            title: Text('Messages'),
            activeColor: Colors.purpleAccent,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.event),
            title: Text('Filter'),
            activeColor: Colors.purpleAccent,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile'),
            activeColor: Colors.purpleAccent,
          ),
        ],
      ),
    );
  }
}