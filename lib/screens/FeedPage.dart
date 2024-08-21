import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image with user profile picture
          Positioned.fill(
            child: Image.network(
              'https://picsum.photos/200',  // Replace with your image URL
              fit: BoxFit.cover,
            ),
          ),
          
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
          
          // User Name and Details
          Positioned(
            bottom: 140,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Luigi, 23',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Colors.purpleAccent,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Nearby',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Bottom Interaction Button
          Positioned(
            bottom: 40,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: Center(
                child: Icon(
                  Icons.whatshot,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),

          // Bottom GG logo
          Positioned(
            bottom: 10,
            left: 16,
            child: Text(
              'GG',
              style: TextStyle(
                color: Color(0xFFB084FF),
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}