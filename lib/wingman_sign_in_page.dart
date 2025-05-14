import 'package:flutter/material.dart';
import 'package:wingr/wingman_dashboard_page.dart';

// Professional entry point - Authentication flow for service providers
// Allows wingmen to identify themselves and access their dashboards
class WingmanSignInPage extends StatefulWidget {
  const WingmanSignInPage({super.key});

  @override
  State<WingmanSignInPage> createState() => _WingmanSignInPageState();
}

class _WingmanSignInPageState extends State<WingmanSignInPage> {
  // Available wingman profiles - Service provider database
  // Contains identity information and profile images
  final List<Map<String, String>> _wingmen = [
    {
      'name': 'Stephen',
      'image': 'images/stephen_picture.jpg',
    },
    {
      'name': 'Jeff',
      'image': 'images/jeff_picture.jpg',
    },
    {
      'name': 'Dave',
      'image': 'images/dave_picture.jpg',
    },
  ];
  
  // Visual navigation state management
  // Tracks which profile is currently being viewed
  int _currentIndex = 0;
  
  // Card carousel controller - Manages horizontal profile browsing
  // Enhanced with partial visibility of adjacent cards
  final PageController _pageController = PageController(
    viewportFraction: 0.8, // Show a bit of the next/previous card
  );

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentIndex != next) {
        setState(() {
          _currentIndex = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Brand-consistent styling - Maintains visual identity
      backgroundColor: const Color(0xFFF6FF52),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header component - App branding and navigation controls
            // Consistent with other screens for visual cohesion
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left - Logo (bigger)
                  Image.asset(
                    'images/logo.png',
                    height: 70, // Increased size
                    fit: BoxFit.contain,
                  ),
                  
                  // Center - Status circles
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40, // Bigger circles
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5C5C), // Red
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 3), // Thicker border
                        ),
                      ),
                      const SizedBox(width: 16), // More spacing
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7EFF68), // Green
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5A6EFF), // Blue
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                      ),
                    ],
                  ),
                  
                  // Right - Close button (bigger)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      'images/closeButton.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 3),
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 36),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection prompt - Clear user instruction
            // Large text creates visual emphasis on the task
            Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 24.0, 32.0, 16.0),
              child: Text(
                "Who is this?",
                style: TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 42, // Bigger font
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            
            // Interactive carousel - Visual profile selection
            // Dynamic card scaling provides affordance for selection
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _wingmen.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    // Determine if this is the active card
                    final isActive = index == _currentIndex;
                    
                    return GestureDetector(
                      onTap: () {
                        // Only navigate when tapping the active card
                        if (isActive) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WingmanDashboardPage(
                                wingmanName: _wingmen[index]['name']!,
                                wingmanImage: _wingmen[index]['image']!,
                              ),
                            ),
                          );
                        } else {
                          // If not active, make it active
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(
                          horizontal: 12.0, 
                          vertical: isActive ? 0 : 30.0, // Active card is bigger
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.3),
                              blurRadius: isActive ? 20 : 10,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: AspectRatio(
                            aspectRatio: 3/4, // Portrait orientation
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 4, // Thicker border
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  _wingmen[index]['image']!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Identity confirmation - Dynamic profile name display
            // Updates with smooth animation when selection changes
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  _wingmen[_currentIndex]['name']!,
                  key: ValueKey<String>(_wingmen[_currentIndex]['name']!),
                  style: const TextStyle(
                    fontFamily: 'Futura',
                    fontSize: 48, // Much bigger font
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            
            // Pagination indicator - Visual feedback on browsing position
            // Shows available wingmen and highlights current selection
            Container(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _wingmen.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    width: index == _currentIndex ? 30.0 : 14.0, // Active dot is wider
                    height: 14.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.0),
                      color: index == _currentIndex 
                          ? const Color(0xFFFF5CA8) // Pink for active
                          : const Color.fromRGBO(0, 0, 0, 0.3), // Gray for inactive
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
