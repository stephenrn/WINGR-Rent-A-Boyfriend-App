import 'package:flutter/material.dart';
import 'landing_page.dart';

// User profile management screen - Handles user identity and app settings
// Provides account management and authentication controls
class ProfilePage extends StatelessWidget {
  final String username;
  
  const ProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header - Profile identifier
            // Maintains consistent typographic hierarchy with other screens
            const Text(
              "Profile",
              style: TextStyle(
                fontFamily: 'Futura',
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // User identity component - Visual representation of the user
            // Presents user's information in a centralized card format
            Container(
              width: double.infinity, // Take full width for proper centering
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 6),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center the column contents
                children: [
                  // Avatar placeholder - Uses brand accent color scheme
                  // Circular format maintains consistency with user profile patterns
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: const Color(0xFFFF5CA8).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2.5),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 70,
                      color: Color(0xFFFF5CA8),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Dynamic username display - Shows current user identity
                  // Fetched from authentication system
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Futura',
                    ),
                    textAlign: TextAlign.center, // Center the text
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Account type indicator - Shows user classification
                  // Distinguishes between different user roles in the system
                  const Text(
                    "Wingr User",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center, // Center the text
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Account management option - Authentication control
            // Simplified to contain just the logout functionality
            Container(
              height: 80, // Reduced height since we only have one option now
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 6),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17.5), // Account for border width
                child: ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 28,
                  ),
                  title: const Text(
                    "Log Out",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  onTap: () {
                    // Session termination and navigation reset
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LandingPage()),
                      (route) => false, // Remove all routes from stack
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
