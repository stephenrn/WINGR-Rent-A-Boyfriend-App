import 'package:flutter/material.dart';
import 'landing_page.dart'; // Import landing page for logout functionality

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
            // Profile header
            const Text(
              "Profile",
              style: TextStyle(
                fontFamily: 'Futura',
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // User info card - CENTERED
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
                  // Profile pic placeholder - centered
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
                  
                  // Username - centered
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
                  
                  // User type - centered
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
            
            // Settings options
            Expanded(
              child: Container(
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
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildProfileOption(context, Icons.settings, "Settings"),
                      const Divider(height: 1, thickness: 1),
                      _buildProfileOption(context, Icons.help_outline, "Help"),
                      const Divider(height: 1, thickness: 1),
                      _buildProfileOption(
                        context, 
                        Icons.logout, 
                        "Log Out", 
                        isLogout: true,
                        onTap: () {
                          // Log out functionality - navigate to landing page
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LandingPage()),
                            (route) => false, // Remove all routes from stack
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileOption(
    BuildContext context,
    IconData icon, 
    String title, 
    {bool isLogout = false, VoidCallback? onTap}
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.black,
        size: 28,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: isLogout ? null : const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      onTap: onTap ?? () {
        // Default handler for options without specific handlers
      },
    );
  }
}
