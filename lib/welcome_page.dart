import 'package:flutter/material.dart';
import 'login.dart';
import 'colors.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Animation setup
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.80).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Navigate to login
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Enhanced background elements
              Positioned(
                top: -60,
                left: -60,
                child: _buildFloatingShape(AppColors.accent.withOpacity(0.2), 180, true),
              ),
              Positioned(
                bottom: -50,
                right: -50,
                child: _buildFloatingShape(AppColors.primary.withOpacity(0.2), 140, false),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo with enhanced styling
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.accent, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/assets/logo.png',
                              width: MediaQuery.of(context).size.width * 0.45,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.account_balance_wallet,
                                  size: 90,
                                  color: AppColors.primary,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 48),
                    // Enhanced welcome text with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.accent, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'Spendio',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: Colors.white, // Base color for gradient
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Creative subtitle with animation
                    AnimatedOpacity(
                      opacity: _controller.value,
                      duration: Duration(milliseconds: 800),
                      child: Text(
                        'Your Money, Your Way',
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    // Enhanced loading dots with bounce effect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedDot(0),
                        SizedBox(width: 12),
                        _buildAnimatedDot(200),
                        SizedBox(width: 12),
                        _buildAnimatedDot(400),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingShape(Color color, double size, bool isCircle) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: !isCircle ? BorderRadius.circular(40) : null,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_controller.value * 8),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.4),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}