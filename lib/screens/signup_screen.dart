import 'package:flutter/material.dart';
import 'package:gala_gatherings/auth_notifier.dart';
import 'package:gala_gatherings/main_layout.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();
  String userType = 'customer'; // Default user type

  void _setUserType(String type) {
    setState(() {
      userType = type; // Update user type based on selection
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color(0xffD9D0E3), // Background color of the main container
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 70),
                Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        color: Color(0xff093030),
                        fontFamily: "Poppins"),
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  height: MediaQuery.of(context).size.height - 100,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          _buildTextField(
                            label: "Full Name",
                            controller: _fullNameController,
                            hintText: "Full Name",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your full name";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          _buildTextField(
                            label: "Email",
                            controller: _emailController,
                            hintText: "example@example.com",
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          _buildTextField(
                            label: "Mobile Number",
                            controller: _mobileController,
                            hintText: "+123 456 789",
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return "Please enter a valid mobile number";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          _buildDateField(
                            label: "Date Of Birth",
                            controller: _dobController,
                            onTap: () => _selectDate(context),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please select your date of birth";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          _buildPasswordField(
                            label: "Password",
                            controller: _passwordController,
                            isPasswordVisible: _isPasswordVisible,
                            onToggleVisibility: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              }
                              if (value.length < 6) {
                                return "Password must be at least 6 characters long";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          _buildPasswordField(
                            label: "Confirm Password",
                            controller: _confirmPasswordController,
                            isPasswordVisible: _isConfirmPasswordVisible,
                            onToggleVisibility: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please confirm your password";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Sign Up As',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff0E3E3E),
                                    ),
                                  ),
                                  SizedBox(height: 10),

                                  // Buttons for selecting user type
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Customer Button
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            try {
                                              await Provider.of<AuthNotifier>(
                                                      context,
                                                      listen: false)
                                                  .signUp(
                                                _emailController.text,
                                                _fullNameController.text,
                                                _passwordController.text,
                                                'customer', // Pass the selected user type ('customer' or 'vendor')
                                                _mobileController.text,
                                                _dobController.text,
                                              );
                                              Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            MainLayout(initialIndex: 0), // Navigates to ProfilePage
      ));
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content:
                                                    Text('Sign Up Failed: $e'),
                                              ));
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              userType == 'customer'
                                                  ? Color(0xff3E065F)
                                                  : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                        ),
                                        child: Text(
                                          'Customer',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: userType == 'customer'
                                                ? Colors.white
                                                : Color(0xff3E065F),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      // Business Button
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            try {
                                              await Provider.of<AuthNotifier>(
                                                      context,
                                                      listen: false)
                                                  .signUp(
                                                _emailController.text,
                                                _fullNameController.text,
                                                _passwordController.text,
                                                'vendor', // Pass the selected user type ('customer' or 'vendor')
                                                _mobileController.text,
                                                _dobController.text,
                                              );
                                              Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            MainLayout(initialIndex: 3), // Navigates to ProfilePage
      ));
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content:
                                                    Text('Sign Up Failed: $e'),
                                              ));
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: userType == 'vendor'
                                              ? Color(0xff3E065F)
                                              : Colors.grey[200],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                        ),
                                        child: Text(
                                          'Business',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: userType == 'vendor'
                                                ? Colors.white
                                                : Color(0xff3E065F),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'By continuing, you agree to',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Terms of Use ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'and ',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    Text(
                                      'Privacy Policy.',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushReplacementNamed('/login');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                  Text(
                                    'Log In',
                                    style: TextStyle(
                                        color: Color(0xffD9D0E3), fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: "Poppins",
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
        SizedBox(height: 2),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.only(left: 40.0),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: "Poppins",
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
        SizedBox(height: 2),
        TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '●●●●●●●',
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.only(left: 40.0),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: "Poppins",
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
        SizedBox(height: 2),
        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'DD / MM / YYYY',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.only(left: 40.0),
          ),
        ),
      ],
    );
  }
}
