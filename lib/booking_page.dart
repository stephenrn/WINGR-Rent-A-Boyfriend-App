import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'receipt_page.dart';

class BookingPage extends StatefulWidget {
  final String username;

  const BookingPage({
    super.key,
    required this.username,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });
    
    final prefs = await SharedPreferences.getInstance();
    final String? bookingsJson = prefs.getString('bookings');
    
    if (bookingsJson != null) {
      try {
        final List<dynamic> allBookings = json.decode(bookingsJson);
        
        // Filter bookings for current user and don't show cancelled OR completed bookings
        _bookings = allBookings
            .where((booking) => 
                booking['username'] == widget.username && 
                booking['cancelled'] != true &&
                booking['completed'] != true) // Filter out cancelled AND completed bookings
            .map((booking) => Map<String, dynamic>.from(booking))
            .toList();
        
        _bookings.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['date']);
          final DateTime dateB = DateTime.parse(b['date']);
          return dateB.compareTo(dateA); // Sort by date descending
        });
      } catch (e) {
        debugPrint('Error loading bookings: $e');
        _bookings = [];
      }
    } else {
      _bookings = [];
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelBooking(int index) async {
    final booking = _bookings[index];
    booking['cancelled'] = true;
    
    final prefs = await SharedPreferences.getInstance();
    final String? bookingsJson = prefs.getString('bookings');
    
    if (bookingsJson != null) {
      try {
        final List<dynamic> allBookings = json.decode(bookingsJson);
        
        // Find and update the booking in the all bookings list
        for (int i = 0; i < allBookings.length; i++) {
          if (allBookings[i]['id'] == booking['id']) {
            allBookings[i] = booking;
            break;
          }
        }
        
        await prefs.setString('bookings', json.encode(allBookings));
        _loadBookings(); // Reload bookings
      } catch (e) {
        debugPrint('Error updating booking: $e');
      }
    }
  }

  // Add method to mark booking as completed
  Future<void> _completeBooking(int index) async {
    final booking = _bookings[index];
    booking['completed'] = true;
    
    final prefs = await SharedPreferences.getInstance();
    final String? bookingsJson = prefs.getString('bookings');
    
    if (bookingsJson != null) {
      try {
        final List<dynamic> allBookings = json.decode(bookingsJson);
        
        // Find and update the booking in the all bookings list
        for (int i = 0; i < allBookings.length; i++) {
          if (allBookings[i]['id'] == booking['id']) {
            allBookings[i] = booking;
            break;
          }
        }
        
        await prefs.setString('bookings', json.encode(allBookings));
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking marked as completed'),
              backgroundColor: Color(0xFF52FF68),
            ),
          );
        }
        
        _loadBookings(); // Reload bookings
      } catch (e) {
        debugPrint('Error updating booking: $e');
      }
    }
  }

  void _viewReceipt(Map<String, dynamic> booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptPage(booking: booking),
      ),
    ).then((_) => _loadBookings()); // Refresh after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF6FF52), // Yellow color for booking page
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
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5C5C),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2.5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7EFF68),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2.5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5A6EFF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2.5),
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
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    return _buildBookingCard(_bookings[index], index);
                  },
                ),
      
      // Removed FloatingActionButton (refresh button)
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No bookings found",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Book a wingman now!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
    final DateTime bookingDate = DateTime.parse(booking['date']);
    final String formattedDate = DateFormat('EEE, MMM d, yyyy').format(bookingDate);
    final String formattedTime = booking['time'] ?? '';
    final bool isCompleted = booking['completed'] == true;
    
    // Check if booking date is in the past
    final bool isPastBooking = DateTime.now().isAfter(bookingDate);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wingman card image (now outside container)
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            color: Colors.white, // Add white background to prevent transparency issues
            child: Image.asset(
              booking['wingmanCardImage'] ?? 'images/stephen_card.png',
              fit: BoxFit.contain, // Changed from cover to contain to show entire image
              height: null, // Remove fixed height to adapt to image aspect ratio
            ),
          ),
        ),
        
        const SizedBox(height: 16), // Increased spacing
        
        // New separate card for booking details
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              // Changed from Wingman name to User's Booking
              Text(
                "${widget.username}'s Booking",
                style: const TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Location field with outline
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Location",
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking['location'] ?? 'No location specified',
                            style: const TextStyle(
                              fontFamily: 'Futura',
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Date field - Now in its own row
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Date",
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontFamily: 'Futura',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Time field - Now in its own row
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Time",
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            fontFamily: 'Futura',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons with new styling
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // View Receipt button in light blue (#59ffff)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _viewReceipt(booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF59FFFF), // Light blue
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "View Receipt",
                          style: TextStyle(
                            fontFamily: 'Futura',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Show Finished button for past bookings in yellow (#f6ff52)
                  if (isPastBooking && !isCompleted)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _completeBooking(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF6FF52), // Yellow
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Finished",
                            style: TextStyle(
                              fontFamily: 'Futura',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Show Cancel button for upcoming bookings
                  if (!isCompleted && !isPastBooking)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _cancelBooking(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontFamily: 'Futura',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16), // Space between cards
      ],
    );
  }
}
