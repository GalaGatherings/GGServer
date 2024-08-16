import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/gala.png', // Gala logo image
              height: 50,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JUNE 2024', // Example for a month display
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            TableCalendar(
              focusedDay: DateTime.now(),
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              calendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: Colors.grey),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.white),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                // Handle day selected
              },
            ),
            SizedBox(height: 20),
            _buildMenuButton('GALA/AVAILABILITY', context),
            SizedBox(height: 10),
            _buildMenuButton('TASK MANAGEMENT', context),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(
                  8.0), // Add padding to create spacing around the image
              decoration: BoxDecoration(
                shape: BoxShape.circle, // Circular shape
                color: Colors.transparent, // Background color of the circle
              ),
              child: Image.asset(
                'assets/images/gg.png',
                width: 50, // Adjust the width of the image as per your UI
                fit: BoxFit.contain,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu,
                size: 30, color: Colors.white), // Adjust icon size and color
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.notifications,
                    size: 30, color: Colors.white), // Base notification icon
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2), // Small red notification dot
                    decoration: BoxDecoration(
                      color: Colors.red, // Red color for alert
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                ),
              ],
            ),
            label: '',
          ),
        ],
        currentIndex: 0, // Update this based on your selected index
        onTap: (index) {
          // Handle bottom nav tap
        },
      ),
    );
  }

  Widget _buildMenuButton(String text, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add, color: Colors.redAccent),
          onPressed: () {
            // Handle button action
          },
        )
      ],
    );
  }
}
