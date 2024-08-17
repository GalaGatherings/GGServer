import 'package:flutter/material.dart';
import 'package:gala_gatherings/auth_notifier.dart';

import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
 @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/home');
      // final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

      // if (authNotifier.isAuthenticated) {
      // } else {
      //   Navigator.pushReplacementNamed(context, '/login');
      // }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset('assets/images/gala.png', height: 100),
      ),
    );
  }
}
