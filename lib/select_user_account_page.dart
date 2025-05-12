import 'package:flutter/material.dart';

class SelectUserAccountPage extends StatelessWidget {
  const SelectUserAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample user data
    final List<Map<String, String>> users = [
      {'name': 'Gian'},
      {'name': 'Theo'},
      {'name': 'Alex'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6FF52),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar with logo, status dots, and close button - BIGGER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Increased padding
              child: SizedBox(
                height: 80, // Increased from 60
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Bigger Logo
                    SizedBox(
                      width: 140, // Increased from 100
                      child: Image.asset(
                        'images/logo.png',
                        height: 60, // Increased from 40
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    // Center: Bigger Status circles
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 30, // Increased from 20
                          height: 30, // Increased from 20
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5C5C), // Red
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2), // Thicker border
                          ),
                        ),
                        const SizedBox(width: 12), // Increased from 8
                        Container(
                          width: 30, // Increased from 20
                          height: 30, // Increased from 20
                          decoration: BoxDecoration(
                            color: const Color(0xFF7EFF68), // Green
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2), // Thicker border
                          ),
                        ),
                        const SizedBox(width: 12), // Increased from 8
                        Container(
                          width: 30, // Increased from 20
                          height: 30, // Increased from 20
                          decoration: BoxDecoration(
                            color: const Color(0xFF5A6EFF), // Blue
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2), // Thicker border
                          ),
                        ),
                      ],
                    ),
                    
                    // Bigger Close button
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(
                        'images/closeButton.png',
                        width: 60, // Increased from 40
                        height: 60, // Increased from 40
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60, // Increased from 40
                            height: 60, // Increased from 40
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 3), // Thicker border
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 36), // Bigger icon
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Title section - BIGGER
            Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 32.0, bottom: 24.0), // Increased padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Select User",
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 48, // Increased from 32
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    "Account",
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 48, // Increased from 32
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            
            // Create New User button - BIGGER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0), // Increased padding
              child: Container(
                width: double.infinity,
                height: 65, // Increased from 50
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 6), // Increased shadow offset
                      blurRadius: 0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(32), // Increased radius
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32), // Increased radius
                      side: const BorderSide(color: Colors.black, width: 2.5), // Thicker border
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Create New User",
                    style: TextStyle(
                      fontSize: 22, // Increased from 16
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            
            // User list - BIGGER
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0), // Increased padding
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0), // Increased padding
                      child: GestureDetector(
                        onTap: () {
                          // Handle user selection
                        },
                        child: Container(
                          height: 80, // Increased from 60
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20), // Increased radius
                            border: Border.all(color: Colors.black, width: 2.5), // Thicker border
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(0, 6), // Increased shadow offset
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Increased padding
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_circle, 
                                size: 45, // Increased from 32
                                color: Colors.black,
                              ),
                              const SizedBox(width: 24), // Increased spacing
                              Expanded(
                                child: Text(
                                  users[index]['name']!,
                                  style: const TextStyle(
                                    fontSize: 24, // Increased from 18
                                    fontWeight: FontWeight.w500, // Added more weight
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 28, // Increased from 20
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
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
