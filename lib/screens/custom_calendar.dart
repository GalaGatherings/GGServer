

import 'package:flutter/material.dart';
import 'package:gala_gatherings/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // For formatting dates

class CustomCalendarScreen extends StatefulWidget {
  final bool isLoggedIn;

  const CustomCalendarScreen(this.isLoggedIn);

  @override
  // ignore: library_private_types_in_public_api
  _CustomCalendarScreenState createState() => _CustomCalendarScreenState();
}

class _CustomCalendarScreenState extends State<CustomCalendarScreen> {
  DateTime _focusedDay = DateTime.now(); // Track the currently focused day
  // ignore: unused_field
  DateTime _selectedDay = DateTime.now(); // Track the selected day
  // This will store the selected dates
  List<DateTime> selectedDates = [];
  List<Map<String, String>> galaEvents = [];
  List<Map<String, String>> taskEvents = [];

  // Controls the visibility of the time picker panel
  bool _isGalaPanelOpen = false;
  // ignore: unused_field
  bool _isTaskPanelOpen = false;
  // Variables for storing selected time
  int selectedStartHour = 1;
  int selectedEndHour = 1;
  String selectedStartPeriod = 'AM';
  String selectedEndPeriod = 'AM';
  void _submitAvailabiltyEventData() {
    //for availabilty
  }
  void _submitGalaEventData() async {
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
    var gala = {"gala": galaEvents};
    print("Gala Events Submitted: $gala");
    //  _isGalaPanelOpen = !_isGalaPanelOpen;

    Provider.of<AuthNotifier>(context, listen: false)
        .user_update(gala)
        .then((value) => {
          
         
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(value),
                    ))
        });
    //  print("resJeson  $res");
    //  var resJson= json.encode(res);
    //  print("resJson  $resJson");

    //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //                   content: Text(resJson['message']),
    //                 ));

    // API call logic can be added here
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      // Update both the selected day and the focused day
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;

      // Add or remove selected dates
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
                child: Row(
                  children: [
                    // Icon(
                    //   Icons.close,
                    //   color: Colors.white,
                    // ),
                    Text(
                      'CLOSE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            // GestureDetector(
            //   onTap: () =>
            //       Provider.of<AuthNotifier>(context, listen: false).logout(),
            //   child: Container(
            //     padding: EdgeInsets.all(8),
            //     child: Text(
            //       'Logout',
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffFBCFCC),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                // color: Color(0xffFBCFCC),
                child: TableCalendar(
                  pageAnimationEnabled: true,
                  focusedDay: _focusedDay, // Bind the focused day here
                  firstDay: DateTime(2024),
                  lastDay: DateTime(2030),
                  selectedDayPredicate: (day) => selectedDates.contains(day),
                  onDaySelected: _onDaySelected,
                  onPageChanged: (focusedDay) {
                    // Update the focused day when the month changes
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(
                      color: Color(0xff212525),
                      fontSize: 20,
                    ),
                    selectedTextStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                    todayDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xffAFFD9C),
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(
                      color: Color(0xff212525),
                      fontSize: 20,
                    ),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    titleCentered: true,
                    headerMargin: EdgeInsets.only(bottom: 15),
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      color: Color(0xffFB6641),
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                    ),
                    leftChevronIcon:
                        Icon(Icons.chevron_left, color: Colors.black),
                    rightChevronIcon:
                        Icon(Icons.chevron_right, color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (user_type == 'customer') ...[
                _buildMenuButton('GALA', context, _submitGalaEventData),
              ] else ...[
                _buildMenuButton(
                    'AVAILABILITY', context, _submitAvailabiltyEventData),
              ],
              if (_isGalaPanelOpen)
                _buildTimeSelector(context, _submitGalaEventData),
              SizedBox(height: 10),
              _buildMenuButton(
                  'TASK MANAGEMENT', context, _submitTaskManagementData),
                  if (_isTaskPanelOpen)
                _buildTaskAndTimeSelector(context, _submitTaskManagementData),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      String text, BuildContext context, VoidCallback submitFunction) {
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
        Container(
          constraints: BoxConstraints(maxHeight: 40, maxWidth: 40),
          //  padding: EdgeInsets.all(30),
          width: 35,
          height: 35,

          decoration: BoxDecoration(
              color: Color(0xffFB6641),
              borderRadius: BorderRadius.all(Radius.circular(50))),
          child: Center(
            child: IconButton(
              icon: Icon(
                _isGalaPanelOpen ? Icons.remove : Icons.add, // Toggle icon
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  if (text == 'GALA')
                    _isGalaPanelOpen = !_isGalaPanelOpen;
                  // Toggle panel visibility
                  else if (text == 'TASK MANAGEMENT')
                    _isGalaPanelOpen = !_isGalaPanelOpen;
                });
              },
            ),
          ),
        ),
        // ElevatedButton(
        //   onPressed: submitFunction,
        //   child: Text("Submit"),
        // )
      ],
    );
  }

  Widget _buildTimeSelector(BuildContext context, VoidCallback submitFunction) {
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
                    width: MediaQuery.of(context).size.width /
                        6, // Fixed width for time
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
                              color: hour == selectedStartHour
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          );
                        },
                        childCount: 12,
                      ),
                    ),
                  ),
                  // Start Period Picker (AM/PM)
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        6, // Fixed width for AM/PM
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
                              color: period == selectedStartPeriod
                                  ? Colors.green
                                  : Colors.grey,
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
                    width: MediaQuery.of(context).size.width /
                        6, // Fixed width for time
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
                              color: hour == selectedEndHour
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          );
                        },
                        childCount: 12,
                      ),
                    ),
                  ),
                  // End Period Picker (AM/PM)
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        6, // Fixed width for AM/PM
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
                              color: period == selectedEndPeriod
                                  ? Colors.green
                                  : Colors.grey,
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
        GestureDetector(
          onTap: submitFunction,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xffD9D9D9),
                borderRadius: BorderRadius.all(Radius.circular(13)),
              ),
              child: Text(
                "Submit",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )),
        )
      ],
    );
  }

  Widget _buildTaskAndTimeSelector(BuildContext context, VoidCallback submitFunction) {
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
                    width: MediaQuery.of(context).size.width /
                        6, // Fixed width for time
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
                              color: hour == selectedStartHour
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          );
                        },
                        childCount: 12,
                      ),
                    ),
                  ),
                  // Start Period Picker (AM/PM)
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        6, // Fixed width for AM/PM
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
                              color: period == selectedStartPeriod
                                  ? Colors.green
                                  : Colors.grey,
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
                    width: MediaQuery.of(context).size.width /
                        6, // Fixed width for time
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
                              color: hour == selectedEndHour
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          );
                        },
                        childCount: 12,
                      ),
                    ),
                  ),
                  // End Period Picker (AM/PM)
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        6, // Fixed width for AM/PM
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
                              color: period == selectedEndPeriod
                                  ? Colors.green
                                  : Colors.grey,
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
        Container(child: Text('Tasks '),),
        GestureDetector(
          onTap: submitFunction,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xffD9D9D9),
                borderRadius: BorderRadius.all(Radius.circular(13)),
              ),
              child: Text(
                "Submit",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )),
        )
      ],
    );
  }



}
