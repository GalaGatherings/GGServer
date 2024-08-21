import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthNotifier extends ChangeNotifier {
  static const String authBox = 'authBox';
  static const String baseUrl = 'https://galagatherings.com';

  bool _isAuthenticated = false;
  String user_type = 'customer';
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;

  // Public method to load authentication state from SharedPreferences

  // Save authentication state to SharedPreferences

  AuthNotifier() {
    initializeAuth();
  }

  // Initialize authentication state
  Future<void> initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    print("_userId $_userId");
    _userId = prefs.getString('userId');

    notifyListeners();
  }

  // Save authentication state to SharedPreferences
  Future<void> _saveAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', _isAuthenticated);

    await prefs.setString('user_type', 'customer');
  }

  // Clear authentication state from SharedPreferences
  Future<void> _clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Login method
  Future<dynamic> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if(responseData['code'] == 200){

        _userId = responseData['data']['user_id'];
        _isAuthenticated = true;
        await _saveAuthState();

        // Save auth state

        notifyListeners();
        return responseData;
        }
        else{
           return responseData;
        }
      } else {
        throw Exception('Failed to login');
      }
    } catch (error) {
      _isAuthenticated = false;
      notifyListeners();
      throw error;
    }
  }

  // Sign up method
  Future<void> signUp(String email, String name, String password,
      String userType, String mobileNo, String dob) async {
    final url = Uri.parse('$baseUrl/sign-up');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': name,
          'password': password,
          'user_type': userType,
          'mobile_no': mobileNo,
          'dob': dob,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 200) {
          _isAuthenticated = true;
          _userId =
              responseData['data']['user_id']; // Simulating user ID from API
          await _saveAuthState();
          // Save auth state

          notifyListeners();
        } else {
          throw Exception('Failed to sign up');
        }
      } else {
        throw Exception('Failed to sign up');
      }
    } catch (error) {
      _isAuthenticated = false;
      notifyListeners();
      throw error;
    }
  }

  Future<String> user_update(userData) async {
    final url = Uri.parse('$baseUrl/update-user');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, ...userData}),
      );
      final responseData = jsonDecode(response.body);
      print("responseData  ${responseData['message']}");
      return responseData['message'];
    } catch (error) {
      return 'error';
    }
  }


Future<String> updateTask(taskData) async {
  final url = Uri.parse('$baseUrl/update-task');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"user_id":userId,...taskData}), // Send individual task data
    );
    final responseData = jsonDecode(response.body);
    print("responseData  ${responseData['message']}");
    return responseData['message'];
  } catch (error) {
    print("Error updating task: $error");
    return 'Error updating task';
  }
}

  Future<dynamic> getUserData() async {
    final url = Uri.parse('$baseUrl/get-user-details');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      final responseData = jsonDecode(response.body);
     
      return responseData['data'];
    } catch (error) {
      return {};
    }
  }
Future<dynamic> getTaskData() async {
  final url = Uri.parse('$baseUrl/get-tasks');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}), // Only fetch tasks by user_id
    );
    final responseData = jsonDecode(response.body);
    print("responseData  $responseData");
    
    if (responseData['code'] == 200) {
      return responseData['tasks']; // Return tasks array from the API
    } else {
      return [];
    }
  } catch (error) {
    print("Error fetching task data: $error");
    return [];
  }
}
  // Logout method
  Future<void> logout() async {
    print("Loging out");
    _isAuthenticated = false;
    _userId = null;

    // Clear auth state
    await _clearAuthState();

    notifyListeners();
  }
}
