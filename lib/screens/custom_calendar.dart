import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  List<Map<String, String>> taskEvents = [];

  // Controls the visibility of the time picker panel
  bool _isGalaPanelOpen = false;

  // Variables for storing selected time
  int selectedStartHour = 1;
  int selectedEndHour = 1;
  String selectedStartPeriod = 'AM';
  String selectedEndPeriod = 'AM';

 void _submitGalaEventData() {
  // Clear the list to prevent duplicate submissions
  galaEvents.clear();
  
  // Loop through all selected dates and create an event for each date
  selectedDates.forEach((date) {
    galaEvents.add({
      "date": DateFormat('dd-MM-yyyy').format(date),
      "start_time": "$selectedStartHour $selectedStartPeriod",
      "end_time": "$selectedEndHour $selectedEndPeriod"
    });
  });

  print("Gala Events Submitted: $galaEvents");

  // API call logic can be added here
}

void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
  setState(() {
    // Ensure no duplicate entries in selected dates
    if (selectedDates.contains(selectedDay)) {
      selectedDates.remove(selectedDay);
    } else {
      selectedDates.add(selectedDay);
    }
  });
}
  void _submitTaskManagementData() {
    // Separate functionality for task management
    // You can customize this section as per task management requirement
    taskEvents.add({
      "task": "Task Management Example",
      "start_time": "$selectedStartHour $selectedStartPeriod",
      "end_time": "$selectedEndHour $selectedEndPeriod"
    });

    print("Task Management Events Submitted: $taskEvents");
    
    // API call logic for Task Management can be added here
  }

  @override
  Widget build(BuildContext context) {
    final user_type = 'customer';

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                pageAnimationEnabled: true,
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
                    color: Colors.green,
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
              Container(height: 20),
              if (user_type == 'customer') ...[
                _buildMenuButton('GALA/AVAILABILITY', context, _submitGalaEventData),
              ] else ...[
                _buildMenuButton('AVAILABILITY', context, _submitTaskManagementData),
              ],
              if (_isGalaPanelOpen) _buildTimeSelector(context),
              Container(height: 10),
              _buildMenuButton('TASK MANAGEMENT', context, _submitTaskManagementData),
              Container(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, BuildContext context, VoidCallback submitFunction) {
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
          icon: Icon(
            _isGalaPanelOpen ? Icons.remove : Icons.add, // Toggle icon
            color: Colors.redAccent,
          ),
          onPressed: () {
            setState(() {
              _isGalaPanelOpen = !_isGalaPanelOpen; // Toggle panel visibility
            });
          },
        ),
        ElevatedButton(
          onPressed: submitFunction,
          child: Text("Submit"),
        )
      ],
    );
  }

  Widget _buildTimeSelector(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Start Time and AM/PM together in a Row
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Start Time Picker
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 6, // Fixed width for time
                    height: 120, // Fixed height for the ListWheelScrollView
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      diameterRatio: 1.5,
                      physics: FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedStartHour = index + 1;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final hour = index + 1;
                          return Text(
                            hour.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              color: hour == selectedStartHour ? Colors.green : Colors.grey,
                            ),
                          );
                        },
                        childCount: 12,
                      ),
                    ),
                  ),
                  // Start Period Picker (AM/PM)
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 6, // Fixed width for AM/PM
                    height: 120, // Fixed height for the ListWheelScrollView
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      diameterRatio: 1.5,
                      physics: FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedStartPeriod = index == 0 ? 'AM' : 'PM';
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final period = index == 0 ? 'AM' : 'PM';
                          return Text(
                            period,
                            style: TextStyle(
                              fontSize: 24,
                              color: period == selectedStartPeriod ? Colors.green : Colors.grey,
                            ),
                          );
                        },
                        childCount: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // End Time and AM/PM together in a Row
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // End Time Picker
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 6, // Fixed width for time
                    height: 150, // Fixed height for the ListWheelScrollView
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                                           diameterRatio: 1.5,
                      physics: FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedEndHour = index + 1;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final hour = index + 1;
                          return Text(
                            hour.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              color: hour == selectedEndHour ? Colors.green : Colors.grey,
                            ),
                          );
                        },
                        childCount: 12,
                      ),
                    ),
                  ),
                  // End Period Picker (AM/PM)
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 6, // Fixed width for AM/PM
                    height: 150, // Fixed height for the ListWheelScrollView
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      diameterRatio: 1.5,
                      physics: FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedEndPeriod = index == 0 ? 'AM' : 'PM';
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final period = index == 0 ? 'AM' : 'PM';
                          return Text(
                            period,
                            style: TextStyle(
                              fontSize: 24,
                              color: period == selectedEndPeriod ? Colors.green : Colors.grey,
                            ),
                          );
                        },
                        childCount: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}