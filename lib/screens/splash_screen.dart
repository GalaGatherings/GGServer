import 'package:flutter/material.dart';
import 'package:gala_gatherings/screens/home_screen.dart';
import 'package:gala_gatherings/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    openHomeScreen();
    // _checkLoginStatus();
  }

  void openHomeScreen() async {
    await Future.delayed(Duration(seconds: 3));
    // Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (context) => HomeScreen()),
    //   );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
  // void _checkLoginStatus() async {
  //   // Simulate a delay to mimic checking login status
  //   await Future.delayed(Duration(seconds: 3));

  //   bool isLoggedIn = false; // Replace with actual login status check

  //   if (isLoggedIn) {
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (context) => HomeScreen()),
  //     );
  //   } else {
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (context) => LoginScreen()),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF121111),
        body: Center(
          child: Container(
            child: Image.asset(
              'assets/images/gala.png',
              fit: BoxFit.cover,
            ),
          ),
        ));
  }
}
