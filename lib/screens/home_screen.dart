import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();
  List<VideoPlayerController> _videoControllers = [];

  @override
  void initState() {
    super.initState();

    // Initialize video controllers
    _videoControllers = [
      VideoPlayerController.asset('assets/videos/vid1.mp4')
        ..initialize().then((_) {
          if (mounted) setState(() {});
        }),
      VideoPlayerController.asset('assets/videos/vid2.mp4')
        ..initialize().then((_) {
          if (mounted) setState(() {});
        }),
      VideoPlayerController.asset('assets/videos/vid3.mp4')
        ..initialize().then((_) {
          if (mounted) setState(() {});
        }),
      VideoPlayerController.asset('assets/videos/vid4.mp4')
        ..initialize().then((_) {
          if (mounted) setState(() {});
        }),
      VideoPlayerController.asset('assets/videos/vid5.mp4')
        ..initialize().then((_) {
          if (mounted) setState(() {});
        }),
    ];

    // Play the first video by default
    _playVideoAtIndex(_selectedIndex);
  }

  void _playVideoAtIndex(int index) {
    // Pause the current video
    if (_selectedIndex >= 0 && _selectedIndex < _videoControllers.length) {
      _videoControllers[_selectedIndex].pause();
      _videoControllers[_selectedIndex].seekTo(Duration.zero);
    }

    // Update the selected index
    setState(() {
      _selectedIndex = index;
    });

    // Play the next video and handle video end
    _videoControllers[_selectedIndex].play();
    _videoControllers[_selectedIndex].setLooping(false);
    _videoControllers[_selectedIndex].addListener(() {
      if (_videoControllers[_selectedIndex].value.position ==
          _videoControllers[_selectedIndex].value.duration) {
        // Automatically go to the next video if it exists
        if (_selectedIndex < _videoControllers.length - 1) {
          _pageController.nextPage(
              duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        } else {
          // Loop back to the first video
          _pageController.jumpToPage(0);
          _playVideoAtIndex(0);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to the corresponding video in the PageView
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF121111),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/gala.png',
              height: 50,
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: CircularIconWithImage(),
            onPressed: () {
              // Calendar action
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _videoControllers.length,
            itemBuilder: (context, index) {
              return _videoControllers[index].value.isInitialized
                  ? VideoPlayer(_videoControllers[index])
                  : Center(child: CircularProgressIndicator());
            },
            onPageChanged: (index) {
              _playVideoAtIndex(index);
            },
          ),
          Positioned(
  bottom: 0,
  left: 0,
  right: 0,
  child: ClipRRect(
    borderRadius: BorderRadius.all(Radius.circular(30)), // Same border radius as the container
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Apply blur effect
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
        decoration: BoxDecoration(
          color: Color(0xffD9D9D9).withOpacity(0.1),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/food.png', height: 30),
              label: 'Food',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/drink.png', height: 30),
              label: 'Drinks',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/flowers.png', height: 30),
              label: 'Flowers',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/dance.png', height: 30),
              label: 'Dance',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/drum.png',
                height: 30,
                color: Colors.white,
              ),
              label: 'Music',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.white70,
          onTap: _onItemTapped,
        ),
      ),
    ),
  ),
),
        ],
      ),
    );
  }
}

class CircularIconWithImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      padding: EdgeInsets.all(10),
      child: Image.asset(
        'assets/images/calendar.png',
        width: 20,
        color: Colors.black,
        fit: BoxFit.contain,
      ),
    );
  }
}
