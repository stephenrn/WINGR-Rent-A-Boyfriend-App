import 'package:flutter/material.dart';
import 'landing_page.dart';

// Application entry point
// This is where Flutter begins executing the application
void main() {
  runApp(const MyApp());
}

// Root application component
// Defines the application-wide configuration and styling
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application name shown in app switchers and settings
      title: 'Wingr',
      
      // First screen displayed when the app launches
      // LandingPage presents user/wingman role selection
      home: const LandingPage(),
      
      // Note: We're using Flutter's default theme settings
      // Our custom styling is applied at the widget level throughout the app
    );
  }
}
