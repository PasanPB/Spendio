import 'package:flutter/material.dart';

class LoginSignupPage extends StatefulWidget {
  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF405DE6), // Instagram blue
              Color(0xFF5851DB), // Instagram purple
              Color(0xFF833AB4), // Instagram violet
              Color(0xFFC13584), // Instagram pink
              Color(0xFFE1306C), // Instagram red
              Color(0xFFFD1D1D), // Instagram orange
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/assets/logo.png', // Replace with your logo path
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  Text(
                    isLogin ? 'Welcome Back!' : 'Create Account',
                    style: TextStyle(
                      fontSize: 26,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 25),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.white.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        children: [
                          _buildTextField(Icons.email, 'Email'),
                          SizedBox(height: 15),
                          _buildTextField(Icons.lock, 'Password', isPassword: true),
                          if (!isLogin) ...[
                            SizedBox(height: 15),
                            _buildTextField(Icons.lock, 'Confirm Password', isPassword: true),
                          ],
                          SizedBox(height: 25),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF405DE6), // Instagram blue
                              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadowColor: Colors.black26,
                              elevation: 5,
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                isLogin ? '/dashboard' : '/createAccount',
                              );
                            },
                            child: Text(
                              isLogin ? 'Login' : 'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Inter',
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                            child: Text(
                              isLogin ? 'Create an account' : 'Already have an account? Login',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Or continue with',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton('assets/assets/google.png', 'Google Login'), // Replace with your asset path
                      SizedBox(width: 20),
                      _buildSocialButton('assets/assets/facebook.png', 'Facebook Login'), // Replace with your asset path
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black54),
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Inter', color: Colors.black45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSocialButton(String assetPath, String tooltip) {
    return GestureDetector(
      onTap: () => print("$tooltip tapped"),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(
          assetPath,
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}