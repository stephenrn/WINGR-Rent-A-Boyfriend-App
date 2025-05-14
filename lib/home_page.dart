import 'package:flutter/material.dart';
import 'package:wingr/to_book_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Main wingman selection page - Core part of the user journey
// Allows users to browse available wingmen and select one for booking
class HomePage extends StatefulWidget {
  final String username;
  
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Wingman profiles collection - Contains all available wingmen data
  // Each profile has name and visual assets (card and details)
  final List<Map<String, String>> _profiles = [
    {
      'name': 'Stephen',
      'card': 'images/stephen_card.png',
      'about': 'images/stephen_about.png',
    },
    {
      'name': 'Jeff',
      'card': 'images/jeff_card.png',
      'about': 'images/jeff_about.png',
    },
    {
      'name': 'Dave',
      'card': 'images/dave_card.png',
      'about': 'images/dave_about.png',
    },
  ];
  
  // Navigation state management
  int _currentIndex = 0;
  bool _isNavigatingForward = true;
  
  // Profile browsing functionality - Forward navigation
  // Shows the next wingman profile with right-to-left animation
  void _nextProfile() {
    setState(() {
      _isNavigatingForward = true;
      if (_currentIndex < _profiles.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0; // Loop back to first profile
      }
    });
  }
  
  // Profile browsing functionality - Backward navigation
  // Shows the previous wingman profile with left-to-right animation
  void _previousProfile() {
    setState(() {
      _isNavigatingForward = false;  // Set direction for animation
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _profiles.length - 1; // Loop to last profile
      }
    });
  }

  // Business logic - Active booking verification
  // Prevents multiple concurrent bookings by the same user
  Future<bool> _hasActiveBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? bookingsJson = prefs.getString('bookings');
    
    if (bookingsJson != null) {
      try {
        final List<dynamic> allBookings = json.decode(bookingsJson);
        
        // Query for any non-completed, non-cancelled bookings for the current user
        final activeBookings = allBookings.where((booking) => 
          booking['username'] == widget.username && 
          booking['cancelled'] != true &&
          booking['completed'] != true
        ).toList();
        
        return activeBookings.isNotEmpty;
      } catch (e) {
        debugPrint('Error checking active bookings: $e');
      }
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Current profile being displayed
    final currentProfile = _profiles[_currentIndex];
    
    return Scaffold(
      // Brand-specific visual styling
      backgroundColor: const Color(0xFFF9F5F2),
      
      // Custom AppBar with consistent brand elements
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFF529B),
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 8.0, // Thick black border at the bottom
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // Transparent so the container decoration shows
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left - Logo and title
                    Row(
                      children: [
                        Image.asset(
                          'images/logo.png',
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "WINGR",
                          style: TextStyle(
                            fontFamily: 'Futura',
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    
                    // Right - Status circles
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32, // Increased from 24 to 32
                          height: 32, // Increased from 24 to 32
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5C5C),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2.5), // Slightly thicker border
                          ),
                        ),
                        const SizedBox(width: 12), // Increased spacing
                        Container(
                          width: 32, // Increased from 24 to 32
                          height: 32, // Increased from 24 to 32
                          decoration: BoxDecoration(
                            color: const Color(0xFF7EFF68),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2.5), // Slightly thicker border
                          ),
                        ),
                        const SizedBox(width: 12), // Increased spacing
                        Container(
                          width: 32, // Increased from 24 to 32
                          height: 32, // Increased from 24 to 32
                          decoration: BoxDecoration(
                            color: const Color(0xFF5A6EFF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2.5), // Slightly thicker border
                          ),
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
      
      // Main content area with layered design pattern
      body: Stack(
        children: [
          // Base layer - Background with adaptable image loading
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9F5F2),
              image: _tryLoadBackgroundImage(),
            ),
          ),

          // Middle layer - Scrollable profile content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header text
                  const Text(
                    "Pick Your Wingman",
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Profile card with animated transitions
                  // Uses direction-aware animations based on navigation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      // Custom slide animation based on navigation direction
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: _isNavigatingForward 
                              ? const Offset(1.0, 0.0)  // Right to left
                              : const Offset(-1.0, 0.0), // Left to right
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      );
                    },
                    child: Container(
                      key: ValueKey<String>(currentProfile['card']!),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45,
                      ),
                      child: Image.asset(
                        currentProfile['card']!,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Profile details with matching animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      // Slide animation based on navigation direction
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: _isNavigatingForward 
                              ? const Offset(1.0, 0.0)  // Right to left
                              : const Offset(-1.0, 0.0), // Left to right
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      );
                    },
                    child: Container(
                      key: ValueKey<String>(currentProfile['about']!),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: Image.asset(
                        currentProfile['about']!,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  // Bottom spacing for navigation controls
                  const SizedBox(height: 160),
                ],
              ),
            ),
          ),
          
          // Top layer - Interactive navigation controls
          // Fixed positioning to ensure visibility regardless of scroll position
          Positioned(
            left: 0,
            right: 0,
            bottom: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left navigation - Previous profile
                  GestureDetector(
                    onTap: _previousProfile,
                    child: Image.asset(
                      'images/left_button.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPixelatedButton(
                          icon: Icons.chevron_left,
                          onPressed: _previousProfile,
                        );
                      },
                    ),
                  ),
                  
                  // Center - Primary action button with booking flow
                  // Contains business logic validation for concurrent bookings
                  GestureDetector(
                    onTap: () async {
                      // Business rule: Users can only have one active booking
                      bool hasActive = await _hasActiveBookings();
                      
                      if (hasActive) {
                        // Warning feedback for business rule violation
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.white),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'You already have an active booking. Please complete or cancel it before booking again.',
                                      style: TextStyle(fontFamily: 'Futura'),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 4),
                              // Removed the SnackBarAction with VIEW button here
                            ),
                          );
                        }
                      } else {
                        // Happy path - Proceed to booking flow
                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) => ToBookPage(
                              wingmanName: _profiles[_currentIndex]['name']!,
                              wingmanCardImage: _profiles[_currentIndex]['card']!,
                              username: widget.username,
                            ),
                          ),
                        );
                      }
                    },
                    child: Image.asset(
                      'images/pixel_heart.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.favorite,
                          size: 100,
                          color: Color(0xFFFF529B),
                        );
                      },
                    ),
                  ),
                  
                  // Right navigation - Next profile
                  GestureDetector(
                    onTap: _nextProfile,
                    child: Image.asset(
                      'images/right_button.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPixelatedButton(
                          icon: Icons.chevron_right,
                          onPressed: _nextProfile,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method - Resilient asset loading strategy
  // Graceful degradation when background image is unavailable
  DecorationImage? _tryLoadBackgroundImage() {
    try {
      return const DecorationImage(
        image: AssetImage('images/picker_background.png'),
        fit: BoxFit.cover,
      );
    } catch (e) {
      // Return null if the image can't be loaded
      return null;
    }
  }
  
  // UI Component - Custom button with pixel art aesthetic
  // Provides fallback for when image assets aren't available
  Widget _buildPixelatedButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFFF529B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 36,
          color: Colors.white,
        ),
      ),
    );
  }
}
