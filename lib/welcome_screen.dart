import 'dart:convert';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:gala_gatherings/api_service.dart';
import 'package:gala_gatherings/prefrence_helper.dart';
import 'package:geocoding/geocoding.dart';  // Keeping it for address conversion
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart'; // Optional if you want to stick with this for other permissions
import 'package:provider/provider.dart';
import 'package:gala_gatherings/screens/Tabs/tabs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;  // Alias location package

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/welcome-screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  loc.Location location = loc.Location();  // Use alias for location package
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();
    // Start the update check asynchronously
    Future.microtask(() => _checkForUpdates());
    requestLocationPermission();  // Call location permission function
  }

  Future<void> requestLocationPermission() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionStatus;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Request to enable location services
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Location services are not enabled, exit.
        return;
      }
    }

    // Check if permission is granted
    permissionStatus = await location.hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      // Request location permission
      permissionStatus = await location.requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted) {
        // Permission not granted, exit.
        return;
      }
    }

    if (permissionStatus == loc.PermissionStatus.granted) {
      _locationFetched = true;
      await _getCurrentLocation(); // Fetch the location if permission granted
    } 
    // else if (permissionStatus == loc.PermissionStatus.permanentlyDenied) {
    //   // Handle permanently denied case
    //   bool opened = await openAppSettings(); // Open app settings for the user to grant permission
    //   if (opened) {
    //     await requestLocationPermission(); // After returning from settings, check again
    //   }
    // }
     else {
      print("Unhandled permission status: $permissionStatus");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Get current location using the location package
      loc.LocationData position = await location.getLocation();  // Fetch location using alias
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude!, position.longitude!);  // Convert coordinates to address

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address =
            '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}, ${placemark.postalCode}';
        String area = placemark.administrativeArea ?? 'Unknown Area';
        print("Location: $address");

        // Update the location in the provider
        await Provider.of<Auth>(context, listen: false).updateCustomerLocation(
            position.latitude, position.longitude, area);
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      _checkLoginStatus();  // Checking login status after update check
    } catch (e) {
      print('Error checking for updates: $e');
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    final userData = await UserPreferences.getUser();

    if (userData != null) {
// Navigator.of(context).pushReplacementNamed('/login');
// Navigator.of(context).pushReplacementNamed('/login');
      Navigator.of(context).pushReplacementNamed(Tabs.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1D1D1D),
      body: Center(
        child: Container(
          child: Image.asset('assets/images/gg.png', width: 500, height: 500),
        ),
      ),
    );
  }
}
