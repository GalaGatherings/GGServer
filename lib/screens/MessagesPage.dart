import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
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
          
          // Settings icon
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
          
          // Messages title and icon
          Positioned(
            top: 100,
            left: 16,
            child: Row(
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Color(0xFF9188A2),
                  child: Icon(Icons.list, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Message cards
          Positioned(
            top: 160,
            left: 16,
            right: 16,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              children: [
                _buildMessageCard('https://picsum.photos/200'),
                _buildMessageCard('https://picsum.photos/200'),
                _buildMessageCard('https://picsum.photos/200'),
                _buildMessageCard('https://picsum.photos/200'),
              ],
            ),
          ),
        ],
      ),
      
    );
  }

  // Method to build individual message cards
  Widget _buildMessageCard(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }


}