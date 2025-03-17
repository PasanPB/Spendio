import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signup.dart'; // Ensure this file exists
import 'add_expenses.dart'; // Ensure this file exists
import 'colors.dart'; // Ensure this file contains your color definitions

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Define the API endpoint
      final url = Uri.parse("http://10.0.2.2:5000/login"); // Use 10.0.2.2 for Android emulator localhost
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // Successful login
        final responseData = jsonDecode(response.body);
        print("Login successful: ${responseData["message"]}");

        // Navigate to the dashboard or to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } else {
        // Handle login failure
        final errorMessage = jsonDecode(response.body)["message"] ?? "Login Failed!";
        _showMessage(errorMessage, AppColors.error);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage("An error occurred. Please try again.", AppColors.error);
    }
  }

  void _googleLogin() async {
    // Placeholder for Google login logic
    print("Google Login Pressed");
    // Replace with actual Google Sign-In logic
  }

  void _facebookLogin() async {
    // Placeholder for Facebook login logic
    print("Facebook Login Pressed");
    // Replace with actual Facebook Sign-In logic
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          color: AppColors.background,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/assets/logo.png',
                      width: 200,
                      height: 200,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Login to manage your finances',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 40),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: AppColors.accent, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            _buildTextField(
                              icon: Icons.email,
                              hint: 'Email',
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty || !value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              icon: Icons.lock,
                              hint: 'Password',
                              isPassword: true,
                              controller: passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty || value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24),
                            _isLoading
                                ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent))
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _login,
                                    child: Text(
                                      'Login',
                                      style: TextStyle(fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                            SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignupPage()),
                                );
                              },
                              child: Text(
                                "Don't have an account? Sign Up",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Or continue with',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          icon: Icons.g_mobiledata,
                          color: Colors.red,
                          onPressed: _googleLogin,
                        ),
                        SizedBox(width: 20),
                        _buildSocialButton(
                          icon: Icons.facebook,
                          color: Colors.blue,
                          onPressed: _facebookLogin,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hint,
    bool isPassword = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      style: TextStyle(color: AppColors.textPrimary),
      validator: validator,
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.accent, width: 2),
        ),
        padding: EdgeInsets.all(12),
      ),
      onPressed: onPressed,
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }
}