import 'package:flutter/material.dart';

// Convert to StatefulWidget to manage page state
class HomePage extends StatefulWidget {
  final String username;
  
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List of profiles with their images
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
  
  // Current profile index
  int _currentIndex = 0;
  
  // Navigate to the next profile
  void _nextProfile() {
    setState(() {
      if (_currentIndex < _profiles.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0; // Loop back to first profile
      }
    });
  }
  
  // Navigate to the previous profile
  void _previousProfile() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _profiles.length - 1; // Loop to last profile
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current profile
    final currentProfile = _profiles[_currentIndex];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
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
      
      body: Stack(
        children: [
          // Main content area with profile cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title text "Pick Your Wingman"
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
                  
                  // Profile card image - with animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
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
                  
                  // Profile about image - with animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
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
                  
                  // Add extra space at bottom
                  const SizedBox(height: 160),
                ],
              ),
            ),
          ),
          
          // Heart and arrows positioned above bottom nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left arrow button - Now with previous functionality
                  GestureDetector(
                    onTap: _previousProfile, // Navigate to previous profile
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
                  
                  // Center - Heart image without container
                  Image.asset(
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
                  
                  // Right arrow button - Now with next functionality
                  GestureDetector(
                    onTap: _nextProfile, // Navigate to next profile
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
  
  // Custom pixelated button
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
