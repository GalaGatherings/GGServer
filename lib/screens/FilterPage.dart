import 'package:flutter/material.dart';

class FilterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Top Gala logo
          Positioned(
            top: 40,
            left: 16,
            child: Text(
              'Gala!',
              style: TextStyle(
                color: Color(0xFFB084FF),
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Warning icon
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.warning_amber_outlined, color: Colors.white),
              onPressed: () {
                // Action for settings icon
              },
            ),
          ),

          // Filter's title and icon
          Positioned(
            top: 100,
            left: 16,
            child: Row(
              children: [
                Text(
                  'Filter\'s',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Color(0xFF9188A2),
                  child: Icon(Icons.filter_alt, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Filter fields
          Positioned(
            top: 160,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterOption('Availability'),
                SizedBox(height: 20),
                _buildFilterOption('Location'),
                SizedBox(height: 20),
                _buildFilterOption('Capacity'),
                SizedBox(height: 20),
                _buildFilterOption('Category'),
                SizedBox(height: 20),
                _buildFilterOption('Specification'),
              ],
            ),
          ),
        ],
      ),
     
    );
  }

  // Method to build individual filter option
  Widget _buildFilterOption(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Calendar', // Placeholder text, replace with appropriate widget
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }


}
