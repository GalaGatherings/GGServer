import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:gala_gatherings/auth_notifier.dart'; // Assuming you have your AuthNotifier here

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch the user data when the page initializes
  }

  Future<void> _fetchUserData({bool forceRefresh = false}) async {
    try {
      var rawData = await Provider.of<AuthNotifier>(context, listen: false)
          .getUserData(forceRefresh: forceRefresh);

      if (rawData is Map && rawData.isNotEmpty) {
        setState(() {
          userData = Map<String, dynamic>.from(
              rawData); // Cast to Map<String, dynamic>
        });
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorySelected = context.watch<AuthNotifier>().category;
    print("categorySelected $categorySelected");

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
        title: Container(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/images/gala.png',
            height: 50,
          ),
        ),
      ),
      body: userData == null
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator until data is fetched
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),

                  // Profile Picture, Name and Role
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: userData!['profile_image'] != null
                              ? NetworkImage(userData!['profile_image'])
                              : null,
                          child: userData!['profile_image'] == null
                              ? Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 50,
                                )
                              : null,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData!['name'] ?? 'Unknown User',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/flowers.png',
                                height: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                categorySelected,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Additional User Data
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
                  _buildInfoCard('Specifications',
                      'Describe your experience and hourly price'),
                  SizedBox(height: 20),
                  _buildInfoCard('Contact information',
                      'Personal number and office address',
                      isPaid: false),
                ],
              ),
            ),
    );
  }

  // Widget to build profile stat
  Widget _buildProfileStat(String label, String count) {
    return Container(
      width: MediaQuery.of(context).size.width/3.5,
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22),color: Color(0xffD9D9D9).withOpacity(0.5)),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter'
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Inter'
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build display clips section
  Widget _buildDisplayClips() {
    return SizedBox(
      // height: 130,
      child: Row(
        
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
    return Column(
      mainAxisAlignment:MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Container(
          
          height: 30,
          child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red,size: 20,),
              onPressed: () {},
            ),
        ),
        Container(

          margin: EdgeInsets.only(right: 10),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  // Widget to build specifications and contact information cards
  Widget _buildInfoCard(String title, String content, {bool isPaid = false}) {
    return Container(
      // padding: EdgeInsets.all(16),
     
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
          // Text(
          //   content,
          //   style: TextStyle(
          //     color: Colors.white,
          //     fontSize: 16,
          //   ),
          // ),
           TextFormField(
            cursorColor: Color(0xff7203FF),
          // controller: controller,
          // keyboardType: keyboardType,
          // validator: validator,
          decoration: InputDecoration(
            
            filled: true,
            fillColor: Colors.black,
            hintText: content,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: OutlineInputBorder(
              
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.only(left: 10.0),
          ),
        ),
        ],
      ),
    );
  }
}
