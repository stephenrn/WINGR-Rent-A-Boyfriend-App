import 'package:flutter/material.dart';

class BookingPage extends StatelessWidget {
  final String username;
  
  const BookingPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title - simplified without animation
            const Text(
              "Bookings",
              style: TextStyle(
                fontFamily: 'Futura',
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle - simplified without animation
            const Text(
              "Manage your appointments",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Empty state placeholder - simplified without animation
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        size: 60,
                        color: Color(0xFFFF5CA8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "No Bookings",
                      style: TextStyle(
                        fontFamily: 'Futura',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        "Your bookings will appear here when scheduled",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
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
