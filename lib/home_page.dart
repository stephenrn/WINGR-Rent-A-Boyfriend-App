import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String username;
  
  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
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
          // Main content area with Stephen's card and about images
          Padding(
            // Reduced padding to give more space for the images
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Stephen's card image - Made bigger
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45, // 45% of screen height
                      ),
                      child: Image.asset(
                        'images/stephen_card.png',
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Stephen's about image - Made bigger
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                      ),
                      child: Image.asset(
                        'images/stephen_about.png',
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    // Add extra space at bottom
                    const SizedBox(height: 160),
                  ],
                ),
              ),
            ),
          ),
          
          // Heart and arrows positioned above bottom nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 140, // Positioned above where the nav bar would be
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left arrow button - Now using image asset
                  GestureDetector(
                    onTap: () {
                      // Left arrow action (empty for now)
                    },
                    child: Image.asset(
                      'images/left_button.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to the original button if image fails to load
                        return _buildPixelatedButton(
                          icon: Icons.chevron_left,
                          onPressed: () {},
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
                  
                  // Right arrow button - Now using image asset
                  GestureDetector(
                    onTap: () {
                      // Right arrow action (empty for now)
                    },
                    child: Image.asset(
                      'images/right_button.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to the original button if image fails to load
                        return _buildPixelatedButton(
                          icon: Icons.chevron_right,
                          onPressed: () {},
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
