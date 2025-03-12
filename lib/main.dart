import 'package:flutter/material.dart';
import 'package:flutter_finance_management/profile.dart';
import 'login.dart';
import 'signup.dart';
import 'add_expenses.dart';
import 'welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spendio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: WelcomePage(),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      routes: {
  '/login': (context) => LoginPage(),
  '/signup': (context) => SignupPage(),
  '/addExpenses': (context) => DashboardPage(),
  '/profile': (context) => ProfilePage(), // Add this line
},
    );
  }
}