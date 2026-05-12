import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'movies_screen.dart';
import 'shows_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 1;

  final List<Widget> _screens = [
    const SearchScreen(),
    const HomeScreen(),
    const MoviesScreen(),
    const ShowsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.search_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.search),
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.home_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.movie_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.movie),
            ),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.tv_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.tv),
            ),
            label: 'TV Shows',
          ),
        ],
      ),
    );
  }
}
