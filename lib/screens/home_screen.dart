import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: Color(0xFF121111),
        automaticallyImplyLeading: false, // Removes the back button
        title: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/gala.png',
                  height: 80,
                ),
                SizedBox(width: 10),
              ],
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // Background color of the circle
            ),
            padding: EdgeInsets.all(
                10), // Padding to make the image fit nicely within the circle
            child: Image.asset(
              'assets/images/calendar.png', // Path to your image
              width: 25, // Width of the image
              color: Colors.black, // Tint color of the image, if any
              fit: BoxFit.fill, // Fit type for the image
            ),
          )
        ],
      ),
      body: Container(
      
        
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(
                        'assets/images/gala.png'), // Add your image asset
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: ShapeDecoration(shape: BeveledRectangleBorder(borderRadius:BorderRadius.circular(40)),color: Colors.black),
                // color: Colors.black,
                // color: Color(0xffD9D9D9).withOpacity(0.1),
                child: BottomNavigationBar(
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
                      icon: Image.asset('assets/images/drum.png', height: 30),
                      label: 'Music',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.purple,
                  onTap: _onItemTapped,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
