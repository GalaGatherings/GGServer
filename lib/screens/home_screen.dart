import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gala_gatherings/auth_notifier.dart';
import 'package:gala_gatherings/screens/custom_calendar.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool login= false;
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

    // Play the next video
    _videoControllers[_selectedIndex].play();
    _videoControllers[_selectedIndex].setLooping(false);
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
    final isLoggedIn = context.watch<AuthNotifier>().isAuthenticated;
    final user_id = context.watch<AuthNotifier>().userId;
    print("user_id   $user_id");
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
              _onCalendarPressed(context, isLoggedIn);
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
              borderRadius: BorderRadius.all(Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                  decoration: BoxDecoration(
                    color: Color(0xffD9D9D9).withOpacity(0.1),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: 
                  BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    type: BottomNavigationBarType.fixed,
                    items: [
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/images/food.png', height: 30,),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/images/drink.png', height: 30,),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/images/flowers.png', height: 30,),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset('assets/images/camera.png', height: 30,),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset(
                          'assets/images/drum.png',
                          height: 30,
                         
                        ),
                        label: '',
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Colors.white70,
                    // selectedIconTheme: Colors.red,
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

  // Handle the calendar icon press
  void _onCalendarPressed(BuildContext context,bool isLoggedIn) {
    // Get the auth notifier to check the login status
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CustomCalendarScreen(isLoggedIn)),
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

class TaskManagementCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TableCalendar(
        focusedDay: DateTime.now(),
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        calendarFormat: CalendarFormat.month,
        onDaySelected: (selectedDay, focusedDay) {
          // Handle date selection
        },
      ),
    );
  }
}