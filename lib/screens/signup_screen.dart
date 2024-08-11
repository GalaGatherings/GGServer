import 'package:flutter/material.dart';
import 'package:gala_gatherings/screens/login_screen.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color(0xffD9D0E3), // Background color of the main container
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 70,
            ),
            Container(
              child: Center(
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
            ),
            SizedBox(
              height: 25,
            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    
                    // Full Name Field
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        "Full Name",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    TextField(
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Color(0xff0E3E3E)),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'example',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.only(left: 40.0),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Email Field
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        "Email",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    TextField(
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Color(0xff0E3E3E)),
                        
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'example@example.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.only(left: 40.0),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Mobile Number Field
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        "Mobile Number",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    TextField(
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Color(0xff0E3E3E)),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '+123 456 789',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.only(left: 40.0),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Date Of Birth Field
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        "Date Of Birth",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    TextField(
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Color(0xff0E3E3E)),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'DD / MM / YYYY',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.only(left: 40.0),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Password Field
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        "Password",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Color(0xff0E3E3E)),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '●●●●●●●',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.only(left: 40.0),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Confirm Password Field
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        "Confirm Password",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Color(0xff0E3E3E)),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '●●●●●●●',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.only(left: 40.0),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Sign Up Button
                    
                    // Terms and Conditions
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'By continuing, you agree to',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                             Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Text(
                                  'Terms of Use ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 14,fontWeight: FontWeight.bold),
                                                             ),
                                                              Text(
                                  'and   ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                                             ),
                                                              Text(
                                  'Privacy Policy.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 14,fontWeight:FontWeight.bold),
                                                             ),
                               ],
                             ),
                          ],
                        ),
                      ),
                    ),
                     SizedBox(height: 5),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 60, vertical: 10),
                        ),
                        child: Text('Sign Up',style: TextStyle(fontSize: 16,fontFamily: "Poppins",fontWeight: FontWeight.w600,color: Color(0xff0E3E3E))),
                      ),
                    ),
                   

                    // SizedBox(height: 10),

                    // Already have an account
                    Center(
                      child: TextButton(
                        onPressed: () { Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );},
                        child: 
                        Row(
                          mainAxisAlignment:MainAxisAlignment.center ,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(color: Colors.white,fontSize: 13),
                            ),
                            Text(
                              'Log In',
                              style: TextStyle(color: Color(0xffD9D0E3),fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}
