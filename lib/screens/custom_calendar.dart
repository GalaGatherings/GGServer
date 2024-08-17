import 'package:flutter/material.dart';
import 'package:gala_gatherings/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // For formatting dates

class CustomCalendarScreen extends StatefulWidget {
  final bool isLoggedIn;

  CustomCalendarScreen(this.isLoggedIn);

  @override
  _CustomCalendarScreenState createState() => _CustomCalendarScreenState();
}

class _CustomCalendarScreenState extends State<CustomCalendarScreen> {
  // This will store the selected dates
  List<DateTime> selectedDates = [];
  List<Map<String, String>> galaEvents = [];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (selectedDates.contains(selectedDay)) {
        selectedDates.remove(selectedDay);
      } else {
        selectedDates.add(selectedDay);
      }
    });
  }

  Future<void> _selectTime(BuildContext context, DateTime selectedDate) async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (startTime != null && endTime != null) {
      // Store the event in the galaEvents list
      setState(() {
        galaEvents.add({
          "date": DateFormat('dd-MM-yyyy').format(selectedDate),
          "start_time": startTime.format(context),
          "end_time": endTime.format(context),
        });
      });
    }
  }

  void _submitEventData() {
    // API call to submit the galaEvents data
    print("Submitting: $galaEvents");
    // Call your API here
  }

  @override
  Widget build(BuildContext context) {
    final user_type ='customer';

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
              'assets/images/gala.png',
              height: 50,
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Provider.of<AuthNotifier>(context, listen: false).logout(),
              child: Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              
              pageAnimationEnabled:true,
              focusedDay: DateTime.now(),
              firstDay: DateTime(2024),
              lastDay: DateTime(2030),
              selectedDayPredicate: (day) => selectedDates.contains(day),
              onDaySelected: _onDaySelected,
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
                  color: Color(0xffAFFD9C),
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: Colors.grey),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
              ),
            ),
            SizedBox(height: 20),
            if (user_type == 'customer') ...[
              _buildMenuButton('GALA/AVAILABILITY', context),
            ] else ...[
              _buildMenuButton('AVAILABILITY', context),
            ],
            SizedBox(height: 10),
            _buildMenuButton('TASK MANAGEMENT', context),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitEventData,
              child: Text("Submit Event"),
            ),
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
          onPressed: () async {
            if (selectedDates.isNotEmpty) {
              for (var date in selectedDates) {
                await _selectTime(context, date);
              }
            } else {
              print("No dates selected");
            }
          },
        ),
      ],
    );
  }
}