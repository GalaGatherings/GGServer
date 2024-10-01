import 'package:gala_gatherings/models/restaurant.dart';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:gala_gatherings/widgets/vendors_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSearchView extends StatefulWidget {
  const GlobalSearchView({super.key});

  @override
  _GlobalSearchViewState createState() => _GlobalSearchViewState();
}

class _GlobalSearchViewState extends State<GlobalSearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> restaurantItems = [];
  int page = 1;
  int limit = 10;
  bool isLoading = false;
  bool hasMoreData = true;
  bool darkMode = true;
  String? selectedBusinessType;

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8'
  };

  // List of available business types for vendors
  List<String> businessTypes = [
    'Catering',
    'Florist',
    'Bartender',
    'Musician',
    'Photographer'
  ];

  @override
  void initState() {
    super.initState();
    getDarkModeStatus();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<String?> getDarkModeStatus() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      darkMode = prefs.getString('dark_mode') == "true" ? true : false;
    });

    return prefs.getString('dark_mode');
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    _fetchData();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchData() async {
    if (!hasMoreData) return; // Stop if there's no more data to fetch

    setState(() {
      isLoading = true;
    });

    var response = await http.post(
      Uri.parse('https://galagatherings.com/global-search/vendors'),
      headers: headers,
      body: jsonEncode({
        'page': page,
        'limit': limit,
        'query': _searchController.text,  // Search query
        'filters': {
          'category': selectedBusinessType, // Selected Business Type
        }
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      
      setState(() {
        if (page == 1) {
          restaurantItems.clear();
        }
        restaurantItems.addAll(data.map((item) => Restaurant.fromJson(item)).toList());
        

        if (data.length < limit) {
          hasMoreData = false; // End of data
        } else {
          page++; // Increment page if more data exists
        }
      });
    } else {
      print("Failed to load data");
    }

    setState(() {
      isLoading = false;
    });
  }

  void _onSearchChanged() {
    setState(() {
      page = 1;
      restaurantItems.clear();
      hasMoreData = true;
    });
    _fetchData();
  }

  void _searchItems(String query) {
    setState(() {
      page = 1;
      restaurantItems.clear();
      hasMoreData = true;
      _fetchData();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedBusinessType = null;
      page = 1;
      restaurantItems.clear();
      hasMoreData = true;
      _fetchData();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkMode
          ? Color(0xff313030)
          : Colors.white, // Full background color
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // Custom padding for the "AppBar"
            decoration: BoxDecoration(
              color: darkMode ? Color(0xff1D1D1D) : Color(0xff7B358D),
              boxShadow: [
                BoxShadow(
                  color: darkMode ? Color(0xff151415).withOpacity(0.69) : Color(0xff7B358D).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 3.h),
                Container(
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(cornerRadius: 15.0, cornerSmoothing: 1),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0xff4F205B).withOpacity(0.4),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    cursorColor: Color(0xff7B358D),
                    style: const TextStyle(fontSize: 14),
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for Vendors',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () => _searchItems(_searchController.text),
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      _searchItems(value);
                    },
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dropdown for selecting business type
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        hint: Text("Select Business Type"),
                        value: selectedBusinessType,
                        items: businessTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedBusinessType = newValue;
                            page = 1;
                            restaurantItems.clear();
                            hasMoreData = true;
                            _fetchData();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    // Button to clear filters
                    ElevatedButton(
                      onPressed: _clearFilters,
                      child: Text("Clear Filters"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkMode ? Color(0xffFA6E00) : Color(0xff7B358D), // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content Body
          Expanded(
            child: restaurantItems.isEmpty && !isLoading
                ? Center(
                    child: Text(
                      'No Vendors Found',
                      style: TextStyle(
                        color: darkMode ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: restaurantItems.length + (hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == restaurantItems.length) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return VendorsCard(restaurant: restaurantItems[index], darkMode: darkMode);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
