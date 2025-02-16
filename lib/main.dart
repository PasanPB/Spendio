import 'package:flutter/material.dart';
import 'signup.dart';
import 'create_account.dart'; // Ensure this file exists and has the LoginSignupPage class

void main() {
  runApp(FinanceApp());
}

class FinanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      title: 'Finance App',
      theme: ThemeData(
        primaryColor: Color(0xFF405DE6),
        hintColor: Color(0xFF833AB4),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(), // Set HomePage as the initial route
      routes: {
        '/loginSignup': (context) => LoginSignupPage(), // Ensure this route works
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
            Icon(Icons.monetization_on, size: 100, color: Colors.blue), // Finance icon
            SizedBox(height: 20),
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
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
