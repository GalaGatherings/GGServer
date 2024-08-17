import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gala_gatherings/auth_notifier.dart';
import 'package:gala_gatherings/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendarScreen extends StatelessWidget {
  final bool isLoggedIn;

  CustomCalendarScreen(
      this.isLoggedIn); // Correct constructor to accept isLoggedIn

  @override
  Widget build(BuildContext context) {
    print("isLoggedIn  ${isLoggedIn}");
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/gala.png', // Gala logo image
              height: 50,
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(), // Close the modal
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => (Provider.of<AuthNotifier>(context, listen: false)
                  .logout()), // Close the modal
              child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  )),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'JUNE 2024', // Example for a month display
            //   style: TextStyle(
            //     fontSize: 25,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white,
            //   ),
            // ),
            // SizedBox(height: 10),
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
            if (isLoggedIn) {
              print("Already logged in");
            } else if(!isLoggedIn) {
              print("Login screen open");
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        )
      ],
    );
  }
}
