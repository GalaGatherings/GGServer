import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  // Controls the visibility of the time picker panel
  bool _isGalaPanelOpen = false;
  // ignore: unused_field
  bool _isTaskPanelOpen = false;
  // Variables for storing selected time
  int selectedStartHour = 1;
  int selectedEndHour = 1;
  String selectedStartPeriod = 'AM';

  String selectedEndPeriod = 'AM';
  bool _isAddingTask = false;
  List<Map<String, dynamic>> taskEvents = [];
  List<Map<String, dynamic>> allTasks = [];

  @override
  void initState() {
    super.initState();
    fetchAllTasks(); // Fetch all tasks for the user when the screen is loaded
  }

  Future<void> fetchAllTasks() async {
    try {
      // Fetch all tasks for the user once in initState
      var tasksData =
          await Provider.of<AuthNotifier>(context, listen: false).getTaskData();

      if (tasksData != null && tasksData is List) {
        setState(() {
          // Store all tasks fetched from the backend
          allTasks = tasksData
              .map<Map<String, dynamic>>((task) => task as Map<String, dynamic>)
              .toList();
        });
      }

      // After fetching all tasks, filter them for the current date
      fetchTaskData();
    } catch (error) {
      print("Error fetching task data: $error");
    }
  }
void fetchTaskData() {
  setState(() {
    // Convert the selected dates to string format
    List<String> selectedDateStrings = selectedDates.map((date) {
      return DateFormat('dd-MM-yyyy').format(date);
    }).toList();

    // Filter tasks from `allTasks` based on selected dates
    taskEvents = allTasks.where((task) {
      return selectedDateStrings.contains(task['date']);
    }).toList();

    // Sort the filtered taskEvents by date in ascending order
    taskEvents.sort((a, b) {
      // Parse the dates from the task events
      DateTime dateA = DateFormat('dd-MM-yyyy').parse(a['date']);
      DateTime dateB = DateFormat('dd-MM-yyyy').parse(b['date']);
      return dateA.compareTo(dateB); // Ascending order
    });
  });
}

  void _submitAvailabiltyEventData() {
    //for availabilty
  }
  TextEditingController taskController = TextEditingController();

  void _submitTaskManagementData() {
    bool isValid = true; // Flag to check if all data is valid

    // Check if taskController is empty
    if (taskController.text.isEmpty) {
      isValid = false;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a task name.'),
      ));
    }

    // Loop through all selected dates and create an event for each date
    selectedDates.forEach((date) {
      if (selectedStartHour == null || selectedEndHour == null) {
        isValid = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select start and end times.'),
        ));
      }

      // If valid, create the task data
      if (isValid) {
        var taskData = {
          "task": taskController.text,
          "date": DateFormat('dd-MM-yyyy').format(date),
          "start_time": "$selectedStartHour $selectedStartPeriod",
          "end_time": "$selectedEndHour $selectedEndPeriod"
        };

        // Send each task to the API for individual processing
        Provider.of<AuthNotifier>(context, listen: false)
            .updateTask(taskData)
            .then((value) {
              fetchAllTasks();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
          ));
        });
    
      }
    });

    // Clear the task input fields and reset the form only if everything is valid
    if (isValid) {
      setState(() {
        taskController.clear();
        _isAddingTask = false;
      });
      print("Task Management Events Submitted");
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is removed from the widget tree
    taskController.dispose();
    super.dispose();
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

      // Filter tasks based on the updated selected dates
      fetchTaskData();
    });
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
              // Show the "Add New Task" button by default
              // Show the "Add New Task" button when the form is not open
              if (!_isAddingTask && _isTaskPanelOpen)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isAddingTask =
                          true; // Show the task input form when clicked
                      _isTaskPanelOpen = true;
                    });
                  },
                  child: Text('ADD NEW TASK'),
                ),

// Show the "Close Task" button when the form is open
              if (_isAddingTask && _isTaskPanelOpen)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isAddingTask = false; // Close the task input form
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .redAccent, // Optional: Change button color to red
                  ),
                  child: Text(
                    'CLOSE TASK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
// Show the task input form when the user clicks "Add New Task"
              if (_isAddingTask)
                _buildTaskAndTimeSelector(context, _submitTaskManagementData),

              SizedBox(height: 20),
              if (_isTaskPanelOpen) _buildTaskListUI(context),
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
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Color(0xffFB6641),
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          child: Center(
            child: IconButton(
              icon: Icon(
                // Dynamically set the icon based on the panel's state
                (text == 'GALA' || text == 'AVAILABILITY')
                    ? (_isGalaPanelOpen ? Icons.remove : Icons.add)
                    : (_isTaskPanelOpen ? Icons.remove : Icons.add),
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  if (text == 'GALA' || text == 'AVAILABILITY') {
                    _isGalaPanelOpen = !_isGalaPanelOpen; // Toggle GALA panel
                  } else if (text == 'TASK MANAGEMENT') {
                    _isTaskPanelOpen = !_isTaskPanelOpen;
                    _isAddingTask = !_isAddingTask; // Toggle TASK panel
                  }
                });
              },
            ),
          ),
        ),
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

  Widget _buildTaskAndTimeSelector(
      BuildContext context, VoidCallback submitFunction) {
    return Column(
      children: [
        // Task Name Input Field
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            width: MediaQuery.of(context).size.width, // Full-width container
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            decoration: BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(13)),
            ),
            child: TextField(
              controller: taskController,
              maxLines: null, // Allows the text to wrap onto the next line
              decoration: InputDecoration(
                hintText: "Enter Task Name",
                hintStyle: TextStyle(color: Colors.black54),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Time Pickers
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
            ),
          ),
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget _buildTaskListUI(BuildContext context) {
    if (taskEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No tasks available for the selected date(s).',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xffFB6641),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TASKS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Time',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: taskEvents.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    color: index % 2 == 0
                        ? Color(0xffFBCFCC)
                        : Colors.white, // Alternating row colors
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width / 1.8),
                            child: Text(
                              taskEvents[index]['task']!,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${taskEvents[index]['start_time']} - ${taskEvents[index]['end_time']}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
