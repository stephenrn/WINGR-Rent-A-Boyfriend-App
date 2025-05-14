import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wingr/home_navigation.dart';
import 'dart:convert';

import 'package:wingr/receipt_page.dart';
// Import BookingPage

class PaymentPage extends StatefulWidget {
  final String wingmanName;
  final String wingmanCardImage;
  final String location;
  final DateTime date;
  final TimeOfDay time;
  final String duration;
  final List<String> purposes;
  final String notes;
  final int totalPrice;
  final String username; // Add username parameter

  const PaymentPage({
    super.key,
    required this.wingmanName,
    required this.wingmanCardImage,
    required this.location,
    required this.date,
    required this.time,
    required this.duration,
    required this.purposes,
    required this.notes,
    required this.totalPrice,
    this.username = 'Guest User', // Default to Guest User
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Payment method options with corresponding images
  final Map<String, String> _paymentMethods = {
    'Credit/Debit Card': 'images/creditDebit.png',
    'PayPal': 'images/paypal.png',
    'Google Pay': 'images/googlePay.png',
    'Apple Pay': 'images/applePay.png',
    'Bank Transfer': 'images/bankTransfer.png',
  };
  
  // Selected payment method
  String? _selectedPaymentMethod;

  // Process payment
  void _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Show processing message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing payment of ₱${NumberFormat('#,###').format(widget.totalPrice)}...'),
        backgroundColor: const Color(0xFF52EAFF),
      ),
    );
    
    // Create booking object
    final booking = {
      'id': 'B${DateTime.now().millisecondsSinceEpoch}',
      'wingmanName': widget.wingmanName,
      'wingmanCardImage': widget.wingmanCardImage,
      'username': widget.username, // Use the username from widget
      'location': widget.location,
      'date': widget.date.toIso8601String(),
      'time': widget.time.format(context),
      'duration': widget.duration,
      'purposes': widget.purposes,
      'notes': widget.notes,
      'totalPrice': widget.totalPrice,
      'paymentMethod': _selectedPaymentMethod,
      'paymentDate': DateTime.now().toIso8601String(),
      'completed': false,
      'cancelled': false,
    };
    
    // Save booking data
    await _saveBookingData(booking);
    
    // Navigate to receipt page
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptPage(
            booking: booking,
            onClose: () {
              // Navigate to HomeNavigation when receipt is closed instead of BookingPage
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(
                  builder: (context) => HomeNavigation(
                    username: widget.username,
                  ),
                ),
                (route) => false, // This clears the navigation stack
              );
            },
          ),
        ),
      );
    }
  }
  
  // Save booking data to shared preferences
  Future<void> _saveBookingData(Map<String, dynamic> booking) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save to a single bookings storage key that both users and wingmen can access
    final String bookingsKey = 'bookings';
    List<dynamic> bookings = [];
    
    final String? existingBookings = prefs.getString(bookingsKey);
    if (existingBookings != null) {
      bookings = json.decode(existingBookings);
    }
    
    bookings.add(booking);
    await prefs.setString(bookingsKey, json.encode(bookings));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF52EAFF), // Blue color for payment page
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 8.0,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            
            // Logo on the left
            leading: Container(
              padding: const EdgeInsets.only(left: 20),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  'images/logo.png',
                ),
              ),
            ),
            leadingWidth: 80,
            
            // Close button on the right
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                width: 60,
                height: 60,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      'images/closeButton.png',
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: const Icon(Icons.close, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
            
            title: const Text(
              "Payment",
              style: TextStyle(
                fontFamily: 'Futura',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wingman card image
              Center(
                child: Image.asset(
                  widget.wingmanCardImage,
                  width: MediaQuery.of(context).size.width * 0.95,
                  fit: BoxFit.fitWidth,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Payment Details Card
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      "Payment Details",
                      style: TextStyle(
                        fontFamily: 'Futura',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Booking summary section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Duration with price
                        _buildDetailRow(
                          title: "Duration",
                          value: widget.duration.split('\n')[0],
                          price: widget.duration.split('\n')[1],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Purpose(s) of booking with prices
                        const Text(
                          "Purpose of Booking:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // List all selected purposes
                        ...widget.purposes.map((purpose) {
                          final parts = purpose.split('\n');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("• ${parts[0]}"),
                                Text(
                                  parts[1],
                                  style: const TextStyle(
                                    color: Color(0xFF52EAFF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    const Divider(
                      height: 24,
                      thickness: 1,
                      color: Colors.black26,
                    ),
                    
                    // Total price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TOTAL PRICE",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "₱${NumberFormat('#,###').format(widget.totalPrice)}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF52EAFF),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Payment method selection
                    const Text(
                      "Select Payment Method",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Payment options with images - redesigned
                    ..._paymentMethods.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: _selectedPaymentMethod == entry.key
                              ? const Color(0xFFE6FCFF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedPaymentMethod == entry.key
                                ? const Color(0xFF52EAFF)
                                : Colors.black26,
                            width: 2,
                          ),
                        ),
                        child: RadioListTile<String>(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Payment method name on left
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              
                              // Payment method icon on right - bigger with no border
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Image.asset(
                                  entry.value, // Image path
                                  width: 60, // Increased size
                                  height: 45, // Increased size
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.payment, 
                                      color: Color(0xFF52EAFF),
                                      size: 40,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          value: entry.key,
                          groupValue: _selectedPaymentMethod,
                          activeColor: const Color(0xFF52EAFF),
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          },
                          // Align radio button to the left edge
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Pay button
              Container(
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 6),
                      blurRadius: 0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(32),
                ),
                child: ElevatedButton(
                  onPressed: _processPayment, // Connect to our new function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF52EAFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                      side: const BorderSide(color: Colors.black, width: 2.5),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "PAY NOW",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.payments_rounded,
                        color: Colors.black,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper widget to display a detail row with title and value
  Widget _buildDetailRow({required String title, required String value, String? price}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$title:",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Text(value),
            if (price != null) ...[
              const SizedBox(width: 8),
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFF52EAFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
