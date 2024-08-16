import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;


class AuthNotifier extends ChangeNotifier {
   static const String authBox = 'authBox';
  static const String baseUrl = 'https://galagatherings.com';

  bool _isAuthenticated = false;
  String user_type = 'user';
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
    final box = await Hive.openBox(authBox);
    _isAuthenticated = box.get('isAuthenticated', defaultValue: false);
    _userId = box.get('userId');
    notifyListeners();
  }

  // Save authentication state to Hive
  Future<void> _saveAuthState() async {
    final box = await Hive.openBox(authBox);
    await box.put('isAuthenticated', _isAuthenticated);
    await box.put('userId', _userId ?? '');
  }

  // Clear authentication state from Hive
  Future<void> _clearAuthState() async {
    final box = await Hive.openBox(authBox);
    await box.clear();
  }

  // Login method
  Future<void> login(String email, String password) async {
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
        _userId = responseData['data']['user_id'];
        _isAuthenticated = true;
        await _saveAuthState();

        // Save auth state
       

        notifyListeners();
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
  Future<void> signUp(String email, String name, String password, String userType, String mobileNo, String dob) async {
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
      _userId = responseData['data']['user_id']; // Simulating user ID from API
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

  // Logout method
  Future<void> logout() async {
    _isAuthenticated = false;
    _userId = null;

    // Clear auth state
    await _clearAuthState();

    notifyListeners();
  }
}