import 'dart:convert';

import 'package:gala_gatherings/api_service.dart';

import 'package:gala_gatherings/constants/globalVaribales.dart';
import 'package:gala_gatherings/main.dart';
// Import Lottie
import 'package:gala_gatherings/screens/Tabs/Profile/profile_view.dart';
import 'package:figma_squircle/figma_squircle.dart';


import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => _notifications;

  void addNotification(Map<String, dynamic> notification) {
    _notifications.add(notification);

    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}

class NotificationScreen extends StatefulWidget {
  final int initialTabIndex;
  final bool redirect;

  const NotificationScreen({
    Key? key,
    this.initialTabIndex = 0,
    this.redirect = false,
  }) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool showAllSocialNotifications = false;
  bool showAllAcceptedOrderNotifications = false;
  bool showAllIncomingOrderNotifications = false;
  bool showAllPaymentNotifications = false;
  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _pageController.jumpToPage(_selectedTabIndex);
    //   _scrollToSelectedTab();
    // });
    _fetchNotifications();
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   Provider.of<NotificationProvider>(context, listen: false)
    //       .addNotification({
    //     'title': message.notification?.title,
    //     'body': message.notification?.body,
    //     'data': message.data,
    //   });

    //   _fetchNotifications();
    //   print("Notification received: ${message.notification?.body}");
    // });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
    _scrollToSelectedTab();
  }

  void _scrollToSelectedTab() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _selectedTabIndex * 65.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      await Provider.of<Auth>(context, listen: false).getNotificationList();
    } catch (error) {
      print('Failed to fetch notifications: $error');
    }
  }

  Future<void> _onRefresh() async {
    try {
      await _fetchNotifications();
      _refreshController.refreshCompleted();
    } catch (error) {
      _refreshController.refreshFailed();
    }
  }

  String formatItems(List<dynamic> items) {
    List<String> formattedItems = [];
    for (int i = 0; i < items.length; i += 1) {
      String line = items
          .skip(i)
          .take(1)
          .map((item) => '${item['name']} x ${item['quantity']}')
          .join(', ');
      formattedItems.add(line);
    }
    return formattedItems.join('\n');
  }

  String oneItem(List<dynamic> items) {
    List<String> formattedItems = [];
    for (int i = 0; i < 1; i += 1) {
      String line = items
          .skip(i)
          .take(1)
          .map((item) => '${item['name']} x ${item['quantity']}')
          .join(', ');
      formattedItems.add(line);
    }
    return formattedItems.join('\n');
  }

  String timeAgo(String d) {
    final DateFormat formatter =
        DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
    var date = formatter.parseUtc(d);
    final Duration difference = DateTime.now().difference(date);

    if (difference.inSeconds < 20) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final int weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final int months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final int years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  Widget buildNotificationList(
      String title,
      List<Map<String, dynamic>> notifications,
      bool showAll,
      bool isAccepted,
      String user_type) {
    final List<Map<String, dynamic>> displayedNotifications = notifications;
    // final List<Map<String, dynamic>> displayedNotifications =
    //     showAll ? notifications : notifications.take(10).toList();

    Color boxShadowColor;

    if (user_type == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (user_type == 'Customer') {
      boxShadowColor = const Color(0xff2E0536);
    } else if (user_type == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color.fromRGBO(
          77, 191, 74, 0.6); // Default color if user_type is none of the above
    }

    return notifications.isEmpty
        ? Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(
              //   height: 100,
              // ),
              Text(
                'No new  ',
                style: TextStyle(
                    color: Color(0xff4F7D7C).withOpacity(0.4),
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    fontFamily: 'Product Sans'),
              ),
              Text(
                'notifications  ',
                style: TextStyle(
                    color: Color(0xff4F7D7C).withOpacity(0.4),
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    fontFamily: 'Product Sans'),
              ),
            ],
          ))
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.transparent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                   
                  ],
                ),
                Column(
                  children:
                      List.generate(displayedNotifications.length, (index) {
                    final notification = displayedNotifications[index];
                    return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 16.0),
                        padding: const EdgeInsets.fromLTRB(10, 10, 15, 10),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 15.0,
                              cornerSmoothing: 1,
                            ),
                          ),
                          shadows: [
                            BoxShadow(
                              color: boxShadowColor.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: _buildActionButtons(
                              notification, isAccepted, boxShadowColor, index),
                        ));
                  }),
                )
              ],
            ),
          );
  }

  Widget buildOrderTracking(
      String title,
      List<Map<String, dynamic>> notifications,
      bool showAll,
      bool isAccepted,
      String user_type) {
    final List<Map<String, dynamic>> displayedNotifications = notifications;
    // final List<Map<String, dynamic>> displayedNotifications =
    //     showAll ? notifications : notifications.take(10).toList();

    Color boxShadowColor;

    if (user_type == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (user_type == 'Customer') {
      boxShadowColor = const Color(0xff2E0536);
    } else if (user_type == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color.fromRGBO(
          77, 191, 74, 0.6); // Default color if user_type is none of the above
    }

    return notifications.isEmpty
        ? Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(
              //   height: 100,
              // ),
              Text(
                'No new  ',
                style: TextStyle(
                    color: Color(0xff4F7D7C).withOpacity(0.4),
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    fontFamily: 'Product Sans'),
              ),
              Text(
                'notifications  ',
                style: TextStyle(
                    color: Color(0xff4F7D7C).withOpacity(0.4),
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    fontFamily: 'Product Sans'),
              ),
            ],
          ))
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.transparent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children:
                      List.generate(displayedNotifications.length, (index) {
                    final notification = displayedNotifications[index];
                    return Container(
                        // margin: const EdgeInsets.symmetric(
                        //     vertical: 8.0, horizontal: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        // decoration: ShapeDecoration(
                        //   color: Colors.white,
                        //   shape: SmoothRectangleBorder(
                        //     borderRadius: SmoothBorderRadius(
                        //       cornerRadius: 15.0,
                        //       cornerSmoothing: 1,
                        //     ),
                        //   ),
                        //   shadows: [
                        //     BoxShadow(
                        //       color: boxShadowColor.withOpacity(0.2),
                        //       spreadRadius: 2,
                        //       blurRadius: 10,
                        //       offset: Offset(0, 3),
                        //     ),
                        //   ],
                        // ),
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: _buildActionButtonsCustomer(
                              notification, isAccepted, boxShadowColor, index),
                        ));
                  }),
                )
              ],
            ),
          );
  }

  bool showFullItems = false;
  Future<bool> checkServiceAvailability(
      String userId, String latitude, String longitude) async {
    try {
      var response = await Provider.of<Auth>(context, listen: false)
          .getDistance(userId, latitude, longitude);
      if (response != null && response['service_available'] != null) {
        return response['service_available'];
      }
      return false;
    } catch (e) {
      print("Error checking service availability: $e");
      return false;
    }
  }

  Map<int, bool> expandedOrderIndices = {};
  Widget _buildActionButtons(Map<String, dynamic> notification, bool isAccepted,
      Color boxShadowColor, int index) {
    // Local method to asynchronously check service availability
    Future<bool> getServiceAvailability() {
      if (notification['status'] == 'Submitted' ||notification['status'] == 'Packed'  ) {
        return checkServiceAvailability(
            notification['order_from_user_id'],
            notification['customer_location']['latitude'],
            notification['customer_location']['longitude']);
      } else {
        return Future.value(false);
      }
    }

    return FutureBuilder<bool>(
      future: getServiceAvailability(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the data, return a loader.
          return Container(
              width: 20, height: 20, child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // In case of error, show an error message.
          return Text("Error: ${snapshot.error}");
        } else {
          // Use the service availability to build the row
          return buildActionButtonsRow(
              notification, boxShadowColor, index, snapshot.data ?? false);
        }
      },
    );
  }

  Widget buildActionButtonsRow(Map<String, dynamic> notification,
      Color boxShadowColor, int index, bool serviceAvailable) {
    void handleStatusChange(String newStatus) async {
      try {
        await Provider.of<Auth>(context, listen: false).statusChange(
          notification['_id'],
          notification['user_id'],
          notification['order_from_user_id'],
          newStatus,
        );
        setState(() {}); // Trigger UI update
      } catch (e) {
        print("${e.toString()}");
      }
    }

    void assignDeliveryPartner() async {
      print("assignDeliveryPartner");
      handleStatusChange('assigning_rider');
      // Show a loading indicator or similar UI until the task assignment is complete
      // showModalBottomSheet(
      //   context: context,
      //   isScrollControlled: true,
      //   backgroundColor: Colors.transparent,
      //   builder: (context) => Container(
      //     height: MediaQuery.of(context).size.height * 0.5,
      //     decoration: BoxDecoration(
      //       color: Colors.white,
      //       borderRadius: BorderRadius.only(
      //         topLeft: Radius.circular(30),
      //         topRight: Radius.circular(30),
      //       ),
      //     ),
      //     child: Center(
      //       child: CircularProgressIndicator(), // Show loading spinner
      //     ),
      //   ),
      // );

      try {
        // Call the API and get the response
        var res = await Provider.of<Auth>(context, listen: false)
            .assignDeliveryPartnerUengage(
          notification['_id'],
          notification['user_id'],
          notification['order_from_user_id'],
        );

        // Parse the response
        var parsedRes = jsonDecode(res);
        print("Parsed Response: $parsedRes");

        // Check the conditions for the response
        if (parsedRes['status'] == true &&
            parsedRes['Status_code'] == "ACCEPTED") {
          int taskId = parsedRes['taskId'];
          String vendorOrderId = parsedRes['vendor_order_id'];

          print("Task ID: $taskId, Vendor Order ID: $vendorOrderId");
          _onRefresh();

          // Close the loading modal
          // Navigator.pop(context);

          // Show the Delivery Status Modal (Replace AssignDeliveryModal with DeliveryStatusScreen)
          // showModalBottomSheet(
          //   context: context,
          //   barrierColor: Colors.black.withOpacity(0.3),
          //   isScrollControlled: true,
          //   backgroundColor: Colors.white,
          //   builder: (context) => DraggableScrollableSheet(
          //     initialChildSize: 0.9,
          //     minChildSize: 0.5,
          //     maxChildSize: 0.9,
          //     builder: (BuildContext context, ScrollController scrollController) {
          //       return DeliveryStatusScreen(
          //         // taskId: taskId, // Pass necessary parameters to the screen
          //         // vendorOrderId: vendorOrderId,
          //         scrollController: scrollController,
          //       );
          //     },
          //   ),
          // );
        } else {
          // Handle task not accepted case
          print("Task not accepted");

          // Optionally close the loading modal and show an error message
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Task not accepted. Please try again later.')),
          );
        }
      } catch (e) {
        print(e.toString());

        // Close the loading modal in case of an error
        Navigator.pop(context);

        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: ${e.toString()}')),
        );
      }
    }

// Helper function to show error dialogs
    void _showErrorDialog(String message) {
      Navigator.pop(context); // Close any open modals
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    void getDeliveryTaskStatus() async {
      print("getDeliveryStatus ");
      try {
        var res =
            await Provider.of<Auth>(context, listen: false).getTaskStatus(11);
        print("resvv  $res");
        setState(() {}); // Trigger UI update
      } catch (e) {
        print("${e.toString()}");
      }
    }
print("serviceAvailable es  $serviceAvailable");

    if (notification['status'] == 'Submitted') {
      // print("notification ${json.encode(notification['payment_method'])}");
      return Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Buyer logo

          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 13,
                  cornerSmoothing: 1,
                ),
              ),
              image: DecorationImage(
                image: NetworkImage(
                  notification['buyer_logo'],
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 10.0),
          // Order details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatItems(notification['items']),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xff0A4C61),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      timeAgo(notification['created_date']),
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Color(0xff519896),
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      notification['payment_method'] == 'online'
                          ? 'PAID'
                          : 'COD',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          // decorationThickness: 4,

                          fontSize: 12.0,
                          color: Color(0xff0A4C61),
                          fontFamily: 'Product Sans'

                          // fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Container(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      serviceAvailable ? '*Deliverable' : '*Self Delivery',
                      style: TextStyle(
                          color: Color(0xffFA6E00),
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    ))
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "USD  ${notification['amount']}",
                style: TextStyle(
                  fontSize: 15.0,
                  color: Color(0xff0A4C61),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (notification['location'] != null &&
                          notification['location']['latitude'] != null) {
                        final String googleMapsUrl =
                            'https://www.google.com/maps/search/?api=1&query=${notification['location']['latitude']},${notification['location']['longitude']}';
                       _launchURL(googleMapsUrl);
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: boxShadowColor
                                .withOpacity(0.2), // Color with 35% opacity
                            blurRadius: 10, // Blur amount
                            offset: Offset(0, 4), // X and Y offset
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/Location.png',
                      ),
                    ),
                  ),

                  SizedBox(width: 10),
                  // Reject button
                  GestureDetector(
                    onTap: () async {
                      try {
                        await Provider.of<Auth>(context, listen: false)
                            .rejectOrder(
                                notification['_id'],
                                notification['user_id'],
                                notification['order_from_user_id']);
                      } catch (e) {
                        print("${e.toString()}");
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: ShapeDecoration(
                        color: Color(0xFFFD4F4F),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 10.0,
                            cornerSmoothing: 1,
                          ),
                        ),
                        shadows: [
                          BoxShadow(
                            color: boxShadowColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Accept button
                  GestureDetector(
                    onTap: () async {
                      try {
                        await Provider.of<Auth>(context, listen: false)
                            .acceptOrder(
                                notification['_id'],
                                notification['user_id'],
                                notification['order_from_user_id']);
                      } catch (e) {
                        print("${e.toString()}");
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: ShapeDecoration(
                        color: Color(0xff1ACD0A),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 10.0,
                            cornerSmoothing: 1,
                          ),
                        ),
                        shadows: [
                          BoxShadow(
                            color: boxShadowColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    } else if (notification['status'] == 'Accepted') {
      return Row(
        children: [
          // Buyer logo
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 13,
                  cornerSmoothing: 1,
                ),
              ),
              image: DecorationImage(
                image: NetworkImage(notification['buyer_logo']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10.0),
          // Order details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 130,
                      child: Text(
                        expandedOrderIndices[index] ?? false
                            ? formatItems(notification['items'])
                            : oneItem(notification['items']),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff0A4C61),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Product Sans'),
                      ),
                    ),
                    if (notification['items'].length > 1)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            expandedOrderIndices[index] =
                                !(expandedOrderIndices[index] ?? false);
                          });
                        },
                        child: Icon(
                          (expandedOrderIndices[index] ?? false)
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Color(0xffFA6E00),
                        ),
                      ),
                  ],
                ),
                // Text(
                //   timeAgo(notification['created_date']),
                //   style: TextStyle(
                //     fontSize: 10.0,
                //     color: Color(0xffFA6E00),
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                Text(
                  "Order ID - ${notification['order_no']}",
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Color(0xff519896),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 40),
          // Complete button
          GestureDetector(
            onTap: () => handleStatusChange('Prepared'),
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: ShapeDecoration(
                color: Color(0xff0A4C61),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 13.5,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: Text(
                'Complete',
                style:
                    TextStyle(color: Colors.white, fontFamily: 'Product Sans'),
              ),
            ),
          ),
        ],
      );
    } else if (notification['status'] == 'Prepared') {
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 13,
                  cornerSmoothing: 1,
                ),
              ),
              image: DecorationImage(
                image: NetworkImage(notification['buyer_logo']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expandedOrderIndices[index] ?? false
                          ? formatItems(notification['items'])
                          : oneItem(notification['items']),
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xff0A4C61),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Product Sans'),
                    ),
                    if (notification['items'].length > 1)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            expandedOrderIndices[index] =
                                !(expandedOrderIndices[index] ?? false);
                          });
                        },
                        child: Icon(
                          (expandedOrderIndices[index] ?? false)
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Color(0xffFA6E00),
                        ),
                      ),
                  ],
                ),
                Text(
                  'Completed',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xff519896),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Product Sans'),
                ),
              ],
            ),
          ),
          // Packed button
          GestureDetector(
            onTap: () => handleStatusChange('Packed'),
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: ShapeDecoration(
                color: Color(0xff5FF59B),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 13.5,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: Text(
                "Packed",
                style: TextStyle(
                    color: Color(0xff0A4C61), fontFamily: 'Product Sans'),
              ),
            ),
          ),
        ],
      );
    }
    // for manual delivery delivery = false  make serviceAvailable false here only for testing now make it serviceAvailable else !serviceAvailable
    else if (notification['status'] == 'Packed' && !serviceAvailable) {
      //false
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 13,
                  cornerSmoothing: 1,
                ),
              ),
              image: DecorationImage(
                image: NetworkImage(notification['buyer_logo']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 110,
                      child: Text(
                        expandedOrderIndices[index] ?? false
                            ? formatItems(notification['items'])
                            : oneItem(notification['items']),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff0A4C61),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Product Sans'),
                      ),
                    ),
                    if (notification['items'].length > 1)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            expandedOrderIndices[index] =
                                !(expandedOrderIndices[index] ?? false);
                          });
                        },
                        child: Icon(
                          (expandedOrderIndices[index] ?? false)
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Color(0xffFA6E00),
                        ),
                      ),
                  ],
                ),
                Text(
                  'Completed',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xff519896),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Product Sans'),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff519896).withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                        final phoneNumber = notification['customer_phone'];
                        final url = 'tel:$phoneNumber';

                        try {
                          await _launchURL(url);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Could not launch phone call $e')),
                          );
                        }
                      },
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: const Color(0xFFFA6E00),
                    child: Image.asset('assets/images/Phone.png'),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () async {
                    if (notification['location'] != null &&
                        notification['location']['latitude'] != null) {
                      final String googleMapsUrl =
                          'https://www.google.com/maps/search/?api=1&query=${notification['location']['latitude']},${notification['location']['longitude']}';
                     _launchURL(googleMapsUrl);
                    }
                  },
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.white,
                    child: Image.asset('assets/images/Location.png'),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 10,
          ),
          // Out for delivery button
          GestureDetector(
            onTap: () => handleStatusChange('Out for delivery'),
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: ShapeDecoration(
                color: Color(0xffFA6E00),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 13.5,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: Text(
                "Out for delivery",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Product Sans'),
              ),
            ),
          ),
        ],
      );
    }
    //  for delivery true
    else if (notification['status'] == 'Packed' && serviceAvailable) {
      //true
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 13,
                  cornerSmoothing: 1,
                ),
              ),
              image: DecorationImage(
                image: NetworkImage(notification['buyer_logo']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 110,
                      child: Text(
                        expandedOrderIndices[index] ?? false
                            ? formatItems(notification['items'])
                            : oneItem(notification['items']),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff0A4C61),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Product Sans'),
                      ),
                    ),
                    if (notification['items'].length > 1)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            expandedOrderIndices[index] =
                                !(expandedOrderIndices[index] ?? false);
                          });
                        },
                        child: Icon(
                          (expandedOrderIndices[index] ?? false)
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Color(0xffFA6E00),
                        ),
                      ),
                  ],
                ),
                Text(
                  'Completed',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xff519896),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Product Sans'),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 10,
          ),
          // Out for delivery button
          GestureDetector(
            onTap: () => assignDeliveryPartner(),
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              decoration: ShapeDecoration(
                color: Color(0xffFA6E00),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 13.5,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: Text(
                "Assign delivery",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Product Sans'),
              ),
            ),
          ),
        ],
      );
    } else if (notification['status'] == 'self_delivery') {
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 13,
                  cornerSmoothing: 1,
                ),
              ),
              image: DecorationImage(
                image: NetworkImage(notification['buyer_logo']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 110,
                      child: Text(
                        expandedOrderIndices[index] ?? false
                            ? formatItems(notification['items'])
                            : oneItem(notification['items']),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff0A4C61),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Product Sans'),
                      ),
                    ),
                    if (notification['items'].length > 1)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            expandedOrderIndices[index] =
                                !(expandedOrderIndices[index] ?? false);
                          });
                        },
                        child: Icon(
                          (expandedOrderIndices[index] ?? false)
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Color(0xffFA6E00),
                        ),
                      ),
                  ],
                ),
                Text(
                  'Completed',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xff519896),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Product Sans'),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff519896).withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                        final phoneNumber = notification['customer_phone'];
                        final url = 'tel:$phoneNumber';

                        try {
                          await _launchURL(url);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Could not launch phone call $e')),
                          );
                        }
                      },
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: const Color(0xFFFA6E00),
                    child: Image.asset('assets/images/Phone.png'),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () async {
                    if (notification['location'] != null &&
                        notification['location']['latitude'] != null) {
                      final String googleMapsUrl =
                          'https://www.google.com/maps/search/?api=1&query=${notification['location']['latitude']},${notification['location']['longitude']}';
                     _launchURL(googleMapsUrl);
                    }
                  },
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.white,
                    child: Image.asset('assets/images/Location.png'),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 10,
          ),
          // Out for delivery button
          GestureDetector(
            onTap: () => handleStatusChange('Out for delivery'),
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: ShapeDecoration(
                color: Color(0xffFA6E00),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 13.5,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: Text(
                "Out for delivery",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Product Sans'),
              ),
            ),
          ),
        ],
      );
    }
    //delivery end
    else if (notification['status'] == 'assigning_rider') {
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 13,
                  cornerSmoothing: 1,
                ),
              ),
              image: DecorationImage(
                image: NetworkImage(notification['buyer_logo']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 110,
                      child: Text(
                        expandedOrderIndices[index] ?? false
                            ? formatItems(notification['items'])
                            : oneItem(notification['items']),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff0A4C61),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Product Sans'),
                      ),
                    ),
                    if (notification['items'].length > 1)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            expandedOrderIndices[index] =
                                !(expandedOrderIndices[index] ?? false);
                          });
                        },
                        child: Icon(
                          (expandedOrderIndices[index] ?? false)
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Color(0xffFA6E00),
                        ),
                      ),
                  ],
                ),
                Text(
                  'Completed',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xff519896),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Product Sans'),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 10,
          ),
          // Out for delivery button
          GestureDetector(
            onTap: () => setState(() {}),
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              decoration: ShapeDecoration(
                color: Color(0xffFA6E00),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 13.5,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: Text(
                "Looking For Rider",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Product Sans'),
              ),
            ),
          ),
        ],
      );
    }
    //if assgined rider
    else if (notification['status'] == 'assigned' ||
        notification['status'] == 'reached_pickup' ||
        notification['status'] == 'order_accepted' ||
        notification['status'] == 'dispatched' ||
        notification['status'] == 'Out for delivery' && serviceAvailable) {
      return Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: ShapeDecoration(
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 13,
                      cornerSmoothing: 1,
                    ),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(notification['buyer_logo']) ,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 110,
                          child: Text(
                            expandedOrderIndices[index] ?? false
                                ? formatItems(notification['items'])
                                : oneItem(notification['items']),
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Color(0xff0A4C61),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Product Sans'),
                          ),
                        ),
                        if (notification['items'].length > 1)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                expandedOrderIndices[index] =
                                    !(expandedOrderIndices[index] ?? false);
                              });
                            },
                            child: Icon(
                              (expandedOrderIndices[index] ?? false)
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Color(0xffFA6E00),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      'Order ID - ${notification['order_no']}',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Color(0xff519896),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Product Sans'),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff519896).withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final phoneNumber = notification['customer_phone'];
                        final url = 'tel:$phoneNumber';

                        try {
                          await _launchURL(url);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Could not launch phone call $e')),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: const Color(0xFFFA6E00),
                        child: Image.asset('assets/images/Phone.png'),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (notification['location'] != null &&
                            notification['location']['latitude'] != null) {
                          final String googleMapsUrl =
                              'https://www.google.com/maps/search/?api=1&query=${notification['location']['latitude']},${notification['location']['longitude']}';
                         _launchURL(googleMapsUrl);
                        }
                      },
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.white,
                        child: Image.asset('assets/images/Location.png'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 10,
              ),
              // Out for delivery button
              GestureDetector(
                onTap: () async {
                  if (notification['tracking_link'] != null &&
                      notification['tracking_link'] != '') {
                    try {
                      final Uri url = Uri.parse(notification['tracking_link']);
                      print("notification['tracking_link']: $url");
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      print('Could not open the tracking link: $e');
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                  decoration: ShapeDecoration(
                    color: const Color(0xff229F00),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 13.5,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    "Track",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Product Sans'),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          //for rider info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: ShapeDecoration(
              color: Color(0xffD3EEEE),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 16.0,
                  cornerSmoothing: 1,
                ),
              ),
              shadows: [
                BoxShadow(
                  color: Color(0xffD3EEEE).withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 50.w),
                  child: Text(
                    // '${notification['rider_name']} is on the way',
                    getDeliveryStatusMessage(
                        notification['rider_name'], notification['status']),
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Color(0xff0A4C61),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Product Sans'),
                  ),
                ),

                Spacer(),

                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff519896).withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                       onTap: () async {
                        final phoneNumber = notification['rider_contact'];
                        final url = 'tel:$phoneNumber';

                        try {
                          await _launchURL(url);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Could not launch phone call $e')),
                          );
                        }
                      },
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: const Color(0xFFFA6E00),
                          child: Image.asset('assets/images/Phone.png'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Out for delivery button
              ],
            ),
          ),
        ],
      );
    } else if (notification['status'] == 'Out for delivery' &&
        !serviceAvailable) {
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 13,
                  cornerSmoothing: 1,
                ),
              ),
              image: DecorationImage(
                image: NetworkImage(notification['buyer_logo']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 110,
                      child: Text(
                        expandedOrderIndices[index] ?? false
                            ? formatItems(notification['items'])
                            : oneItem(notification['items']),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff0A4C61),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Product Sans'),
                      ),
                    ),
                    if (notification['items'].length > 1)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            expandedOrderIndices[index] =
                                !(expandedOrderIndices[index] ?? false);
                          });
                        },
                        child: Icon(
                          (expandedOrderIndices[index] ?? false)
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Color(0xffFA6E00),
                        ),
                      ),
                  ],
                ),
                Text(
                  'Completed',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xff519896),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Product Sans'),
                ),
              ],
            ),
          ),
          // Delivered button
          GestureDetector(
            onTap: () => handleStatusChange('delivered'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: ShapeDecoration(
                color: Colors.black.withOpacity(0.69),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 13,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: Text(
                "Delivered",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Product Sans'),
              ),
            ),
          ),
        ],
      );
    } else if (notification['status'] == 'delivered') {
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 13,
                  cornerSmoothing: 1,
                ),
              ),
              image: DecorationImage(
                image: NetworkImage(notification['buyer_logo']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 110,
                      child: Text(
                        expandedOrderIndices[index] ?? false
                            ? formatItems(notification['items'])
                            : oneItem(notification['items']),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff0A4C61),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Product Sans'),
                      ),
                    ),
                    if (notification['items'].length > 1)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            expandedOrderIndices[index] =
                                !(expandedOrderIndices[index] ?? false);
                          });
                        },
                        child: Icon(
                          (expandedOrderIndices[index] ?? false)
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Color(0xffFA6E00),
                        ),
                      ),
                  ],
                ),
                Text(
                  'Delivered',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Color(0xff519896),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Product Sans'),
                ),
              ],
            ),
          ),
          // Delivered button
          GestureDetector(
            // onTap: () => handleStatusChange('Delivered'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: ShapeDecoration(
                color: Colors.black.withOpacity(0.69),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 13,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: const Text(
                "Delivered",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Product Sans'),
              ),
            ),
          ),
        ],
      );
      // return Container(
      //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      //   decoration: BoxDecoration(
      //     color: Color(0xFF0A4C61),
      //     borderRadius: BorderRadius.circular(8),
      //   ),
      //   child: Text(
      //     "Completed",
      //     style: TextStyle(color: Colors.white, fontSize: 10),
      //   ),
      // );
    } else {
      return Container();
    }
  }

// for order tracking
  Widget _buildActionButtonsCustomer(Map<String, dynamic> notification,
      bool isAccepted, Color boxShadowColor, index) {
    if (notification['status'] == 'Submitted' ||
        notification['status'] == 'Accepted' ||
        notification['status'] == 'Out for delivery' ||
        notification['status'] == 'Packed' ||
        notification['status'] == 'Prepared') {
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 9,
                  cornerSmoothing: 1,
                ),
              ),
              shadows: [
                BoxShadow(
                  color: boxShadowColor.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(notification['buyer_logo']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 130,
                      child: Text(
                        expandedOrderIndices[index] ?? false
                            ? formatItems(notification['items'])
                            : oneItem(notification['items']),
                        style: TextStyle(
                            fontSize: 14.0,
                            color: boxShadowColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Product Sans'),
                      ),
                    ),
                    if (notification['items'].length > 1)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            expandedOrderIndices[index] =
                                !(expandedOrderIndices[index] ?? false);
                          });
                        },
                        child: Icon(
                          (expandedOrderIndices[index] ?? false)
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Color(0xffFA6E00),
                        ),
                      ),
                  ],
                ),
                Text(
                  "Order ID - ${notification['order_no']}",
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xff519896),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Product Sans'),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                        final phoneNumber = notification['phone'];
                        final url = 'tel:$phoneNumber';

                        try {
                          await _launchURL(url);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Could not launch phone call $e')),
                          );
                        }
                      },
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: const Color(0xFFFA6E00),
                    child: Image.asset('assets/images/Phone.png'),
                  ),
                ),
                // SizedBox(
                //   width: 10,
                // ),
              ],
            ),
          ),

          SizedBox(
            width: 5,
          ),
          // Out for delivery button
          GestureDetector(
            child: Container(
              padding: notification['status'] == 'Out for delivery'
                  ? EdgeInsets.fromLTRB(10, 10, 10, 10)
                  : EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: ShapeDecoration(
                color: Color(0xff7B358D),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 13,
                    cornerSmoothing: 2,
                  ),
                ),
              ),
              child: Text(
                // "${notification['status']}",
                notification['status'],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Product Sans'),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget buildSocialNotificationList(
      String title, List notifications, bool showAll, String user_type) {
    final List displayedNotifications =notifications;
        
    Color boxShadowColor;

    if (user_type == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (user_type == 'Customer') {
      boxShadowColor = const Color(0xff2E0536);
    } else if (user_type == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color.fromRGBO(
          77, 191, 74, 0.6); // Default color if user_type is none of the above
    }
    return notifications.isEmpty
        ? Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(
              //   height: 100,
              // ),
              Text(
                'No new  ',
                style: TextStyle(
                    color: Color(0xff4F7D7C).withOpacity(0.4),
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    fontFamily: 'Product Sans'),
              ),
              Text(
                'notifications  ',
                style: TextStyle(
                    color: Color(0xff4F7D7C).withOpacity(0.4),
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    fontFamily: 'Product Sans'),
              ),
            ],
          ))
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 1.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      
                    ],
                  ),
                ),
                Column(
                  children:
                      List.generate(displayedNotifications.length, (index) {
                    final notification = displayedNotifications[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 1.0, horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: ShapeDecoration(
                              shape: const SmoothRectangleBorder(),
                              shadows: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                print(
                                    "redirect ${notification['msg']['from']}");
                                String userId = notification['msg']['from'];
                                navigatorKey.currentState?.push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileView(userIdList: [userId]),
                                  ),
                                );
                              },
                              child: ClipSmoothRect(
                                radius: SmoothBorderRadius(
                                  cornerRadius: 9,
                                  cornerSmoothing: 1,
                                ),
                                child: notification['msg']
                                                ['from_profile_photo'] !=
                                            null &&
                                        notification['msg']
                                                ['from_profile_photo']
                                            .isNotEmpty
                                    ? Image.network(
                                        notification['msg']
                                            ['from_profile_photo'],
                                        fit: BoxFit.cover,
                                        width: 35,
                                        height: 35,
                                        loadingBuilder: GlobalVariables()
                                            .loadingBuilderForImage,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return _buildInitialsAvatar(
                                              notification['notification']
                                                  ['body'],
                                              notification['msg']['type'],
                                              boxShadowColor);
                                        },
                                      )
                                    : _buildInitialsAvatar(
                                        notification['notification']['body'],
                                        notification['msg']['type'],
                                        boxShadowColor),
                              ),
                            ),
                          ),

                          //social profile logo
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification['notification']['body'],
                                  style: TextStyle(
                                      color: boxShadowColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      fontFamily: 'Product Sans'),
                                ),
                                Text(
                                  timeAgo(notification['timestamp']),
                                  style: TextStyle(
                                      fontSize: 10.0,
                                      color: Color(0xfffFA6E00)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                )
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final int initialTabIndex =
        args != null ? args['initialTabIndex'] : widget.initialTabIndex;
    final bool redirect = widget.redirect;
    print("initialTabIndex $initialTabIndex $redirect ");

    String? userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    Color boxShadowColor;

    if (userType == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (userType == 'Customer') {
      boxShadowColor = const Color(0xff2E0536);
    } else if (userType == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color.fromRGBO(77, 191, 74, 0.6);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<Auth>(
        builder: (context, itemProvider, child) {
          bool hasNotifications =
              itemProvider.notificationDetails.isNotEmpty || // for social
                  itemProvider.acceptedOrders.isNotEmpty || // for accepted
                  itemProvider.incomingOrders.isNotEmpty || // for incoming
                  itemProvider.paymentDetails.isNotEmpty ||
                  itemProvider.trackCustomerOrders.isNotEmpty ||
                  itemProvider.deliveryStatus.isNotEmpty;

          return hasNotifications
              ? SmartRefresher(
                  onRefresh: _onRefresh,
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: false,
                  child: Container(
                    child: Column(
                      children: [
                        SizedBox(height: 70),
                        Stack(
                          children: [
                            if (redirect)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: Image.asset(
                                      'assets/images/back_double_arrow.png'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Notification & Orders",
                                style: TextStyle(
                                  color: boxShadowColor,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTabItem(
                                    'Socials', 0, boxShadowColor, itemProvider),
                                SizedBox(width: 30),
                                if (userType != 'Customer')
                                  _buildTabItem('Incoming Orders', 1,
                                      boxShadowColor, itemProvider),
                                SizedBox(width: 30),
                                if (userType != 'Customer')
                                  _buildTabItem('Ongoing Orders', 2,
                                      boxShadowColor, itemProvider),
                                if (userType == 'Customer')
                                  _buildTabItem('Order Tracking', 1,
                                      boxShadowColor, itemProvider),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _selectedTabIndex = index;
                                _scrollToSelectedTab();
                              });
                            },
                            children: [
                              _buildPageContent(
                                buildSocialNotificationList(
                                  'Socials',
                                  itemProvider.notificationDetails,
                                  showAllSocialNotifications,
                                  itemProvider.userData?['user_type'] ?? '',
                                ),
                              ),
                              if (userType != 'Customer')
                                _buildPageContent(
                                  buildNotificationList(
                                    'Incoming Orders',
                                    itemProvider.incomingOrders,
                                    showAllIncomingOrderNotifications,
                                    false,
                                    itemProvider.userData?['user_type'] ?? '',
                                  ),
                                ),
                              if (userType != 'Customer')
                                _buildPageContent(
                                  buildNotificationList(
                                    'Ongoing Orders',
                                    itemProvider.ongoingOrders,
                                    showAllAcceptedOrderNotifications,
                                    true,
                                    itemProvider.userData?['user_type'] ?? '',
                                  ),
                                ),
                              if (userType == 'Customer')
                                _buildPageContent(
                                  buildOrderTracking(
                                    'Order Tracking',
                                    itemProvider.trackCustomerOrders,
                                    showAllAcceptedOrderNotifications,
                                    true,
                                    itemProvider.userData?['user_type'] ?? '',
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (itemProvider.paymentVerifications.isNotEmpty)
                          Container(
                            decoration: ShapeDecoration(
                              color: Color(0xff0A4C61),
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 21.0,
                                  cornerSmoothing: 1,
                                ),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: boxShadowColor.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(15),
                            child: ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  barrierColor: Colors.transparent,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      DraggableScrollableSheet(
                                    initialChildSize: 0.95,
                                    minChildSize: 0.5,
                                    maxChildSize: 0.95,
                                    builder: (BuildContext context,
                                        ScrollController scrollController) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xff0A4C61),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30.0),
                                            topRight: Radius.circular(30.0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xff0A4C61)
                                                  .withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30.0),
                                            topRight: Radius.circular(30.0),
                                          ),
                                          child: Stack(
                                            children: [
                                              PaymentScreen(
                                                  scrollController:
                                                      scrollController),
                                              Positioned(
                                                top: 30,
                                                right: 85,
                                                child: CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor: Colors.red,
                                                  child: Text(
                                                    '${itemProvider.paymentVerifications.length}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                maximumSize: Size(200, 100),
                                backgroundColor: Color(0xffFA6E00),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 14.0,
                                    cornerSmoothing: 1,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Verify Payment',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Product Sans',
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Color(0xffFCFF52),
                                    child: Text(
                                      '${itemProvider.paymentVerifications.length}',
                                      style: TextStyle(
                                        color: Color(0xff0A4C61),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 30),
                        // for delivery status allocation
                       
                      
                      ],
                    ),
                  ),
                )
              : SmartRefresher(
                  onRefresh: _onRefresh,
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: false,
                  child: Container(
                    child: Column(
                      children: [
                        SizedBox(height: 70),
                        Stack(
                          children: [
                            if (redirect)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: Image.asset(
                                      'assets/images/back_double_arrow.png'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Notification & Orders",
                                style: TextStyle(
                                  color: boxShadowColor,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTabItem(
                                    'Socials', 0, boxShadowColor, itemProvider),
                                SizedBox(width: 30),
                                if (userType != 'Customer')
                                  _buildTabItem('Incoming Orders', 1,
                                      boxShadowColor, itemProvider),
                                SizedBox(width: 30),
                                if (userType != 'Customer')
                                  _buildTabItem('Ongoing Orders', 2,
                                      boxShadowColor, itemProvider),
                                if (userType == 'Customer')
                                  _buildTabItem('Order Tracking', 1,
                                      boxShadowColor, itemProvider),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _selectedTabIndex = index;
                                _scrollToSelectedTab();
                              });
                            },
                            children: [
                              _buildPageContent(
                                buildSocialNotificationList(
                                  'Socials',
                                  itemProvider.notificationDetails,
                                  showAllSocialNotifications,
                                  itemProvider.userData?['user_type'] ?? '',
                                ),
                              ),
                              if (userType != 'Customer')
                                _buildPageContent(
                                  buildNotificationList(
                                    'Incoming Orders',
                                    itemProvider.incomingOrders,
                                    showAllIncomingOrderNotifications,
                                    false,
                                    itemProvider.userData?['user_type'] ?? '',
                                  ),
                                ),
                              if (userType != 'Customer')
                                _buildPageContent(
                                  buildNotificationList(
                                    'Ongoing Orders',
                                    itemProvider.ongoingOrders,
                                    showAllAcceptedOrderNotifications,
                                    true,
                                    itemProvider.userData?['user_type'] ?? '',
                                  ),
                                ),
                              if (userType == 'Customer')
                                _buildPageContent(
                                  buildOrderTracking(
                                    'Order Tracking',
                                    itemProvider.trackCustomerOrders,
                                    showAllAcceptedOrderNotifications,
                                    true,
                                    itemProvider.userData?['user_type'] ?? '',
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (itemProvider.paymentVerifications.isNotEmpty)
                          Container(
                            decoration: ShapeDecoration(
                              color: Color(0xff0A4C61),
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 21.0,
                                  cornerSmoothing: 1,
                                ),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: boxShadowColor.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(15),
                            child: ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  barrierColor: Colors.transparent,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      DraggableScrollableSheet(
                                    initialChildSize: 0.95,
                                    minChildSize: 0.5,
                                    maxChildSize: 0.95,
                                    builder: (BuildContext context,
                                        ScrollController scrollController) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xff0A4C61),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30.0),
                                            topRight: Radius.circular(30.0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xff0A4C61)
                                                  .withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30.0),
                                            topRight: Radius.circular(30.0),
                                          ),
                                          child: Stack(
                                            children: [
                                              PaymentScreen(
                                                  scrollController:
                                                      scrollController),
                                              Positioned(
                                                top: 30,
                                                right: 85,
                                                child: CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor: Colors.red,
                                                  child: Text(
                                                    '${itemProvider.paymentVerifications.length}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                maximumSize: Size(200, 100),
                                backgroundColor: Color(0xffFA6E00),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 14.0,
                                    cornerSmoothing: 1,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Verify Payment',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Product Sans',
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Color(0xffFCFF52),
                                    child: Text(
                                      '${itemProvider.paymentVerifications.length}',
                                      style: TextStyle(
                                        color: Color(0xff0A4C61),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 30),
                        //for delivery status allocation
                        
                     
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildPageContent(Widget content) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: content,
    );
  }

  Widget _buildTabItem(
      String title, int index, Color boxShadowColor, itemProvider) {
    int notificationCount = 0;

    if (itemProvider.userData?['user_type'] == 'Customer') {
      switch (index) {
        case 0:
          notificationCount = itemProvider.notificationDetails.length;
          break;
        case 1:
          notificationCount = itemProvider.trackCustomerOrders.length;
          break;
        default:
          notificationCount = itemProvider.notificationDetails.length;
          break;
      }
    } else {
      switch (index) {
        case 0:
          notificationCount = itemProvider.notificationDetails.length;
          break;
        case 1:
          notificationCount = itemProvider.incomingOrders.length;
          break;
        case 2:
          notificationCount = itemProvider.ongoingOrders.length;
          break;
        default:
          notificationCount = itemProvider.notificationDetails.length;
          break;
      }
    }
    print("notificationCount $notificationCount");
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 10.0, right: 16.0), // Adjust padding as needed
                child: Text(
                  title,
                  style: TextStyle(
                    color: _selectedTabIndex == index
                        ? boxShadowColor
                        : boxShadowColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (notificationCount != 0 &&
                  index !=
                      0) // removed social notification display  using index
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Color(0xffFA0F00),
                    child: Text(
                      '$notificationCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_selectedTabIndex == index)
            Align(
              alignment: Alignment.center,
              child:
               Container(
                margin: const EdgeInsets.only(top: 4.0, right: 16),
                decoration: BoxDecoration(
                  color: Color(0xffFA6E00),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                height: 4.0,
                child: IntrinsicWidth(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.transparent,
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

String getDeliveryStatusMessage(String riderName, String statusKey) {
  final Map<String, String> mapDelStatus = {
    'assigned': 'Your order has been assigned to $riderName.',
    'dispatched': '$riderName is on the way to deliver your order.',
    'reached_pickup': '$riderName has reached the pickup location.',
    'delivered': '$riderName has delivered your order.',
    'order_accepted': 'Your order has been accepted by customer.',
    'order_cancelled':
        'Unfortunately, your order has been cancelled by $riderName.',
  };

  // Return the appropriate message based on the statusKey
  return mapDelStatus[statusKey] ?? 'Your order status has changed.';
}

class PaymentScreen extends StatefulWidget {
  final ScrollController scrollController;

  PaymentScreen({required this.scrollController});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<int> expandedIndices = [];

  bool showScreenshot = false;
  void verifyPayment(
      BuildContext context, Map<String, dynamic> notification) async {
    final response = await http.post(
      Uri.parse("https://galagatherings.com/order/confirm_payment"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "user_id": notification['payment_from_user_id'],
        "order_from_user_id": notification['payment_to_user_id'],
        "order_id": notification['order_id'],
        "verification_status":
            "verified", // or "not_received" based on your logic
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful verification
      print("Payment verified successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment verified successfully')),
      );
      // Refresh notifications
      await Provider.of<Auth>(context, listen: false).getNotificationList();
    } else {
      // Handle error
      print("Failed to verify payment");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify payment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0A4C61),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Adjust height as needed
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 100,
                  height: 5,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFA6E00),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 13.5,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8.0), // Adjust spacing as needed
              Text(
                'Payment Verification',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(height: 8.0), // Adjust spacing as needed
            ],
          ),
        ),
      ),
      body: Consumer<Auth>(
        builder: (context, itemProvider, child) {
          return itemProvider.paymentVerifications.isNotEmpty
              ? ListView.builder(
                  controller: widget.scrollController,
                  itemCount: itemProvider.paymentVerifications.length,
                  itemBuilder: (context, index) {
                    final notification =
                        itemProvider.paymentVerifications[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 22.0,
                            cornerSmoothing: 1,
                          ),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(
                                          0x591F6F6D), // Color with 35% opacity
                                      blurRadius: 10, // Blur amount
                                      offset: Offset(0, 4), // X and Y offset
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        notification['buyer_profile_logo']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "USD ${notification['amount'] ?? 0} has been paid by ",
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Color(0xff0A4C61),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Product Sans'),
                                    ),
                                    Text(
                                      "${notification['buyer_store_name'] ?? 'Unknown store'}",
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Color(0xff0A4C61),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Product Sans'),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (expandedIndices
                                                  .contains(index)) {
                                                expandedIndices.remove(index);
                                              } else {
                                                expandedIndices.add(index);
                                              }
                                            });
                                          },
                                          child: const Text(
                                            "View screenshot",
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    Color(0xFFFA6E00),
                                                color: Color(0xFF519896),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showScreenshot = !showScreenshot;
                                            });
                                          },
                                          child: Icon(
                                            expandedIndices.contains(index)
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: Color(0xFFFA6E00),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (expandedIndices.contains(index))
                                      Container(
                                        decoration: ShapeDecoration(
                                          shape: SmoothRectangleBorder(
                                            borderRadius: SmoothBorderRadius(
                                              cornerRadius: 20.0,
                                              cornerSmoothing: 1,
                                            ),
                                          ),
                                          shadows: const [
                                            BoxShadow(
                                              color: Color(
                                                  0x591F6F6D), // Color with 35% opacity
                                              blurRadius: 10, // Blur amount
                                              offset: Offset(
                                                  0, 4), // X and Y offset
                                            ),
                                          ],
                                        ),
                                        clipBehavior: Clip
                                            .antiAlias, // Ensures the image is clipped to the shape
                                        child: Image.network(
                                          notification['transaction_image'],
                                          fit: BoxFit.cover,
                                          loadingBuilder: GlobalVariables()
                                              .loadingBuilderForImage,
                                          errorBuilder: GlobalVariables()
                                              .ErrorBuilderForImage,
                                        ),
                                      ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    verifyPayment(context, notification);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 25, vertical: 10),
                                    decoration: ShapeDecoration(
                                      color: Color(0xff5FF59B),
                                      shape: SmoothRectangleBorder(
                                        borderRadius: SmoothBorderRadius(
                                          cornerRadius: 13.0,
                                          cornerSmoothing: 1,
                                        ),
                                      ),
                                      shadows: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text('Verify',
                                        style: TextStyle(
                                            fontFamily: 'Product Sans',
                                            color: Color(0xFF0A4C61),
                                            fontWeight: FontWeight.bold)),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Center(
                  child: Text('No payment history available.',
                      style: TextStyle(color: Colors.white)),
                );
        },
      ),
    );
  }
}

String timeAgo(String d) {
  final DateFormat formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
  var date = formatter.parseUtc(d);
  final Duration difference = DateTime.now().difference(date);

  if (difference.inSeconds < 20) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  } else if (difference.inDays < 30) {
    final int weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks == 1 ? '' : 's'} ago';
  } else if (difference.inDays < 365) {
    final int months = (difference.inDays / 30).floor();
    return '$months month${months == 1 ? '' : 's'} ago';
  } else {
    final int years = (difference.inDays / 365).floor();
    return '$years year${years == 1 ? '' : 's'} ago';
  }
}

Widget _buildInitialsAvatar(String body, String type, Color boxShadowColor) {
  String storeName = '';
  if (type == "social") {
    // Extract the first two words from body for social notifications
    storeName = extractStoreName(body);
  } else {
    storeName = body;
  }
  String initials = _getInitials(storeName);

  return Container(
    color: boxShadowColor,
    child: Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

String extractStoreName(String text) {
  print("$text ");
  List<String> words = text.split('');
  if (words.length >= 2) {
    print('${words[0]} ${words[1]}');
    return '${words[0]} ${words[1]}';
  } else if (words.length == 1) {
    return words[0];
  } else {
    return 'N/A';
  }
}

String _getInitials(String name) {
  List<String> nameParts = name.split(' ');
  if (nameParts.length == 1) {
    return nameParts[0].substring(0, 1).toUpperCase();
  } else {
    return nameParts[0].substring(0, 1).toUpperCase() +
        nameParts[1].substring(0, 1).toUpperCase();
  }
}

Future<void> _launchURL(String url) async {
  try {
    final Uri urlLink = Uri.parse(url);

    await launchUrl(
      urlLink,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    print('Could not open the  link: $e');
  }
}
