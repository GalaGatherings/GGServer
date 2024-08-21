import 'package:flutter/material.dart';
import 'package:gala_gatherings/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:gala_gatherings/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose of controllers to free memory
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey, // Assign form key
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Let's sign in",
                style: TextStyle(
                  fontSize: 60,
                  fontFamily: 'Damion', // Use your custom font here
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label for Username/Email
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Username Or Email",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600, // Label color
                        fontSize: 16, // Label font size
                      ),
                    ),
                  ),
                  SizedBox(height: 8), // Space between label and TextField
                  TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'example@example.com',
                      prefixStyle: TextStyle(fontFamily: 'Poppins'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 40.0),
                    ),
                  ),
                  SizedBox(height: 20), // Space between fields

                  // Label for Password
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600, // Label color
                        fontSize: 16, // Label font size
                      ),
                    ),
                  ),
                  SizedBox(height: 8), // Space between label and TextField
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixStyle: TextStyle(fontFamily: 'Poppins'),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '●●●●●●●',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 40.0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 60),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Call the login method from AuthNotifier
                    try {
                      var res = await Provider.of<AuthNotifier>(context,
                              listen: false)
                          .login(
                        _emailController.text,
                        _passwordController.text,
                      );
                      if (res['code'] != 200) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Login Failed: ${res['message']}'),
                        ));
                      }
                      // Check authentication status and navigate
                      if (Provider.of<AuthNotifier>(context, listen: false)
                          .isAuthenticated) {
                        Navigator.of(context).pushReplacementNamed(
                            '/home'); // Navigate to home screen
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Login Failed: $e'),
                      ));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                ),
                child: Text(
                  'Log in',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      color: Color(0xff0E3E3E)),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                ),
                child: Text(
                  'Sign up',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      color: Color(0xff0E3E3E)),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Use Fingerprint To Access',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/images/Facebook.png',
                      width: 30,
                    ), // Ensure you have the icons in assets
                    iconSize: 20,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/images/google.png',
                      width: 30,
                    ),
                    iconSize: 20,
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/sign-up');
                },
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
