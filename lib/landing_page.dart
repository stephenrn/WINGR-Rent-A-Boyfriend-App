import 'package:flutter/material.dart';
import 'select_user_account_page.dart';
import 'wingman_sign_in_page.dart'; // Import the wingman sign-in page

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FF52), // Yellow background
      body: SafeArea(
        child: Stack(
          children: [
            // Base background color 
            Container(
              color: const Color(0xFFF6FF52),
              width: double.infinity,
              height: double.infinity,
            ),
            
            // Logo in upper left
            Positioned(
              top: 24,
              left: 24,
              child: Image.asset(
                'images/logo.png',
                height: 80,  // Adjust size as needed based on your logo
                fit: BoxFit.contain,
              ),
            ),
            
            // Status circles - BIGGER with borders
            Positioned(
              top: 32,
              right: 32,
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5C5C), // Red
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2), // Added black border
                    ),
                  ),
                  const SizedBox(width: 18),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7EFF68), // Green
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2), // Added black border
                    ),
                  ),
                  const SizedBox(width: 18),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A6EFF), // Blue
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2), // Added black border
                    ),
                  ),
                ],
              ),
            ),
            
            // Landing characters image
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.45, // Position above the card
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'images/landing-characters.png',
                  width: 500, // Set width based on image size
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            // White card with content - BIGGER
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40), // Increased from 30
                    topRight: Radius.circular(40), // Increased from 30
                  ),
                  border: Border.all(color: Colors.black, width: 3), // Added black border
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15, // Increased from 10
                      offset: Offset(0, -3), // Increased from -2
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 50), // Increased from 24, 40, 24, 40
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title - BIGGER
                    const Text(
                      "WINGR",
                      style: TextStyle(
                        fontFamily: 'Futura',
                        fontSize: 120, // Increased from 100
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0, // Increased from 2.0
                        color: Colors.black,
                        height: 0.9,
                      ),
                    ),
                    const SizedBox(height: 16), // Increased from 8
                    // Subtitle - BIGGER
                    const Text(
                      "Welcome! Rent A Wingman Now.",
                      style: TextStyle(
                        fontSize: 18, // Increased from 14
                        color: Colors.black54,
                        fontWeight: FontWeight.w500, // Added weight
                      ),
                    ),
                    const SizedBox(height: 40), // Increased from 40
                    // Buttons - EVEN BIGGER
                    Center(
                      child: Container(
                        width: 360, // Increased from 320
                        height: 70, // Increased from 65
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 8), // Increased shadow offset
                              blurRadius: 0, // Solid shadow (no blur)
                            ),
                          ],
                          borderRadius: BorderRadius.circular(25), // Increased from 20
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to wingman sign-in page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WingmanSignInPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5CA8), // Hot pink
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25), // Increased from 20
                              side: const BorderSide(color: Colors.black, width: 3), // Increased from 2.5
                            ),
                            elevation: 0, // No built-in elevation
                          ),
                          child: const Text(
                            "I AM A WINGMAN",
                            style: TextStyle(
                              fontSize: 20, // Increased from 20
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30), // Increased from 24
                    Center(
                      child: Container(
                        width: 360, // Increased from 320
                        height: 70, // Increased from 65
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 8), // Increased shadow offset
                              blurRadius: 0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(25), // Increased from 20
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SelectUserAccountPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25), // Increased from 20
                              side: const BorderSide(color: Colors.black, width: 3), // Increased from 2.5
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "SIGN IN USER",
                            style: TextStyle(
                              fontSize: 20, // Increased from 20
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
