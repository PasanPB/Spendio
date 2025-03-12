import 'package:flutter/material.dart';
import 'login.dart'; // Import the login page
import 'colors.dart'; // Ensure this file contains your color definitions

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    // Automatically navigate to login page after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.background, // Use the same background color as LoginPage
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset(
                    'assets/assets/logo.png', // Your app logo
                    width: MediaQuery.of(context).size.width * 0.6, // Responsive sizing
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, size: 100, color: AppColors.primary);
                    },
                  ),
                  SizedBox(height: 80),
                  // Welcome Text
                  Text(
                    'Welcome to Spendio',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Subtitle Text
                  Text(
                    'Manage your finances effortlessly',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Loading Indicator
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}