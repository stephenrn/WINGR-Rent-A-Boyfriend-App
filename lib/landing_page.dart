import 'package:flutter/material.dart';
import 'select_user_account_page.dart';
import 'wingman_sign_in_page.dart'; 

// Landing page that serves as the entry point to the application
// Provides options to enter as a wingman or as a user
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main theme color of the app
      backgroundColor: const Color(0xFFF6FF52), 
      body: SafeArea(
        child: Stack(
          children: [
            // Main background layer - primary brand color
            Container(
              color: const Color(0xFFF6FF52),
              width: double.infinity,
              height: double.infinity,
            ),
            
            // App branding element - logo placement
            Positioned(
              top: 24,
              left: 24,
              child: Image.asset(
                'images/logo.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            
            // Visual indicators - brand accent elements
            // These circular elements provide visual consistency across all screens
            Positioned(
              top: 32,
              right: 32,
              child: Row(
                children: [
                  // Red indicator
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5C5C),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Green indicator
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7EFF68),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Blue indicator
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A6EFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main visual illustration - represents the app's purpose
            // Shows wingman characters to immediately convey the app's function
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.45,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'images/landing-characters.png',
                  width: 500,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            // Content card - contains app title and navigation options
            // Overlays on top of the background with a distinctive rounded shape
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App name - primary branding element with large, bold display
                    const Text(
                      "WINGR",
                      style: TextStyle(
                        fontFamily: 'Futura',
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                        color: Colors.black,
                        height: 0.9,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle - briefly explains the app's purpose
                    const Text(
                      "Welcome! Rent A Wingman Now.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Main navigation options - two distinct user paths
                    // Button 1: Wingman path - for those offering services
                    Center(
                      child: Container(
                        width: 360,
                        height: 70,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 8),
                              blurRadius: 0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to wingman flow
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WingmanSignInPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5CA8), // Pink accent color for wingman path
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(color: Colors.black, width: 3),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "I AM A WINGMAN",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Button 2: User path - for those seeking wingman services
                    Center(
                      child: Container(
                        width: 360,
                        height: 70,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 8),
                              blurRadius: 0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to user flow
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SelectUserAccountPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Neutral color for user path
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(color: Colors.black, width: 3),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "SIGN IN USER",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
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
    );
  }
}
