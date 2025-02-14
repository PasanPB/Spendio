import 'package:flutter/material.dart';
import 'signup.dart'; // Import the signup.dart file

void main() {
  runApp(FinanceApp());
}

class FinanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      theme: ThemeData(
        primaryColor: Color(0xFF405DE6),
        hintColor: Color(0xFF833AB4),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(), // Set HomePage as the initial route
      routes: {
        '/loginSignup': (context) => LoginSignupPage(), // Add route for LoginSignupPage
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance App Home'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Finance App!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: () {
                // Navigate to the Login/Signup Page
                Navigator.pushNamed(context, '/loginSignup');
              },
              child: Text(
                'Go to Login/Signup',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}