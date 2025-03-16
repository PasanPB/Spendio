import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'colors.dart'; // Ensure this file contains your color definitions

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage("Passwords do not match!", AppColors.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("http://10.0.2.2:5000/register"); // Replace with your API
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        _showMessage("Registration Successful!", AppColors.success);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        final errorMessage = jsonDecode(response.body)["message"] ?? "Registration Failed!";
        _showMessage(errorMessage, AppColors.error);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage("An error occurred. Please try again.", AppColors.error);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          color: AppColors.background, // Use the same background color as LoginPage
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/assets/logo.png',
                      width: MediaQuery.of(context).size.width * 0.6, // Responsive sizing
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error, size: 100, color: AppColors.primary);
                      },
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage your finances effortlessly',
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
                            _buildTextField(Icons.email, 'Email', _emailController, validator: (value) {
                              if (value == null || value.isEmpty || !value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            }),
                            SizedBox(height: 16),
                            _buildTextField(Icons.lock, 'Password', _passwordController, isPassword: true, validator: (value) {
                              if (value == null || value.isEmpty || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            }),
                            SizedBox(height: 16),
                            _buildTextField(Icons.lock, 'Confirm Password', _confirmPasswordController, isPassword: true),
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
                                    onPressed: _signUp,
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                            SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                              },
                              child: Text(
                                "Already have an account? Login",
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
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
}