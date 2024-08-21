import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Add your settings page navigation here
            },
          ),
        ],
        title: Text(
          'Gala!',
          style: TextStyle(
            color: Color(0xFFB084FF),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            // Profile Picture and Name
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[800], // Background color for the circle
              child: Icon(
                Icons.person, // Replace with your desired icon
                color: Colors.white,
                size: 50, // Size of the icon
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Xevier Yami',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // Shortlist, Events, Payments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProfileStat('Shortlist', '1'),
                _buildProfileStat('Events', '1'),
                _buildProfileStat('Payments', '1'),
              ],
            ),
            SizedBox(height: 20),

            // Display clips section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Display clips',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildDisplayClips(),
            SizedBox(height: 20),

            // Specifications and Contact Information
            _buildInfoCard('Specifications', 'SPECIFICATION FOR FILTERS'),
            SizedBox(height: 20),
            _buildInfoCard('Contact information', 'Personal number and office address', isPaid: true),
          ],
        ),
      ),
      
    );
  }

  // Widget to build profile stat
  Widget _buildProfileStat(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Widget to build display clips section
  Widget _buildDisplayClips() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildClipCard('https://picsum.photos/200'),
          _buildClipCard('https://picsum.photos/200'),
          _buildClipCard('https://picsum.photos/200'),
          _buildClipCard('https://picsum.photos/200'),
        ],
      ),
    );
  }

  // Widget to build individual clip card
  Widget _buildClipCard(String imageUrl) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      width: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Widget to build specifications and contact information cards
  Widget _buildInfoCard(String title, String content, {bool isPaid = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isPaid)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Paid',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build bottom navigation bar
 
}



