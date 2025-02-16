import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_finance_management/signup.dart'; // Update the path if needed

void main() {
  testWidgets('LoginSignupPage UI Test', (WidgetTester tester) async {
    // Load the login/signup page
    await tester.pumpWidget(MaterialApp(home: LoginSignupPage()));

    // Check if "Welcome Back!" or "Create Account" text is present
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Check if email and password fields exist
    expect(find.byType(TextField), findsNWidgets(2));

    // Check if login button is present
    expect(find.text('Login'), findsOneWidget);

    // Toggle between login and sign-up
    await tester.tap(find.text('Create an account'));
    await tester.pump();
    
    // Now the sign-up text should be visible
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Already have an account? Login'), findsOneWidget);
  });
}
