import 'package:flutter/material.dart';
import 'package:recipe_book/css/app_theme.dart';
import 'package:lottie/lottie.dart'; // Import lottie package

import '../pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Scale animation for text
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Opacity animation for the animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBeige, 
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive dimensions based on screen size
          double animationWidth = constraints.maxWidth * 0.6; // 60% of screen width
          double animationHeight = animationWidth * 0.8; // Maintain aspect ratio
          
          if (animationWidth > 200) animationWidth = 200; // Max width
          if (animationHeight > 160) animationHeight = 160; // Max height
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie Animation
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Container(
                    width: animationWidth,
                    height: animationHeight,
                    child: Lottie.asset(
                      'assets/images/Animation/SplashScreen.json',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if animation fails to load
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.animation,
                            size: animationWidth * 0.4,
                            color: const Color.fromARGB(255, 200, 0, 0),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // "Yalla Cook!" text with scale animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    'Yalla Cook!',
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.08, // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lightBeige, // Light beige text
                      fontFamily: 'Arial', // Or your preferred font
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Swipe button (responsive)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.1),
                  child: SwipeButton(
                    onSwipeComplete: () {
                      // Navigate to your specific HomePage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardPage()), // This is your HomePage
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Swipe Button Widget (similar to the image you provided)
class SwipeButton extends StatefulWidget {
  final VoidCallback onSwipeComplete;

  const SwipeButton({
    super.key,
    required this.onSwipeComplete,
  });

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  double _dragPosition = 0.0;
  bool _isDragging = false;
  bool _isComplete = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        if (!_isComplete) {
          setState(() {
            _isDragging = true;
          });
        }
      },
      onHorizontalDragUpdate: (details) {
        if (_isDragging && !_isComplete) {
          setState(() {
            _dragPosition += details.delta.dx;
            if (_dragPosition > 100) {
              _dragPosition = 100;
            } else if (_dragPosition < 0) {
              _dragPosition = 0;
            }
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (_isDragging && !_isComplete) {
          setState(() {
            _isDragging = false;
            if (_dragPosition > 80) {
              _isComplete = true;
              widget.onSwipeComplete();
            } else {
              _dragPosition = 0.0;
            }
          });
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          double buttonWidth = constraints.maxWidth * 0.8;
          if (buttonWidth > 300) buttonWidth = 300;
          if (buttonWidth < 200) buttonWidth = 200;
          
          return Container(
            width: buttonWidth,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Track
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                // Knob
                Positioned(
                  left: 10 + _dragPosition,
                  top: 10,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Text
                Positioned.fill(
                  child: Center(
                    child: _isComplete
                        ? Text(
                            'Done!',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 8, 86, 12),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : Text(
                            'Swipe to continue',
                            style: TextStyle(
                              color: AppTheme.darkText,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}