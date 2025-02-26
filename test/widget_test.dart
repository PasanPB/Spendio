import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_finance_management/login.dart'; // Import the new login page
import 'package:flutter_finance_management/signup.dart'; // Import the new signup page

void main() {
  testWidgets('Login Page UI Test', (WidgetTester tester) async {
    // Load the login page
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Check if "Welcome Back!" text is present
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Check if email and password fields exist
    expect(find.byKey(Key('emailField')), findsOneWidget);
    expect(find.byKey(Key('passwordField')), findsOneWidget);

    // Check if login button is present
    expect(find.byKey(Key('loginButton')), findsOneWidget);

    // Check if navigation to sign-up is present
    expect(find.text("Don't have an account? Sign up"), findsOneWidget);
  });

  testWidgets('Signup Page UI Test', (WidgetTester tester) async {
    // Load the signup page
    await tester.pumpWidget(MaterialApp(home: SignupPage()));

    // Check if "Create Account" text is present
    expect(find.text('Create Account'), findsOneWidget);

    // Check if name, email, and password fields exist
    expect(find.byKey(Key('nameField')), findsOneWidget);
    expect(find.byKey(Key('emailField')), findsOneWidget);
    expect(find.byKey(Key('passwordField')), findsOneWidget);

    // Check if signup button is present
    expect(find.byKey(Key('signupButton')), findsOneWidget);

    // Check if navigation to login is present
    expect(find.text('Already have an account? Login'), findsOneWidget);
  });
}
