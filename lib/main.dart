import 'package:flutter/material.dart';
import 'package:gala_gatherings/auth_notifier.dart';
import 'package:gala_gatherings/main_layout.dart';
import 'package:gala_gatherings/screens/home_screen.dart';
import 'package:gala_gatherings/screens/login_screen.dart';
import 'package:gala_gatherings/screens/profile_screen.dart';
import 'package:gala_gatherings/screens/signup_screen.dart';
import 'package:gala_gatherings/screens/splash_screen.dart';

import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the directory for Hive


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
      ],
      child: GalaGatheringsApp(),
    ),
  );
}

class GalaGatheringsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gala Gatherings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfilePage(),
        '/main': (context) => MainLayout(),
      },
    );
  }
}