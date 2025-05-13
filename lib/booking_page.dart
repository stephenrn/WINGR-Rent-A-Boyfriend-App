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
            color: Color(0xFFFF529B), // Pink color for user pages
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
            title: Text(
              "${widget.username}'s Bookings",
              style: const TextStyle(
                fontFamily: 'Futura',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
            leading: IconButton(
              icon: Image.asset(
                'images/closeButton.png',
                width: 40,
                height: 40,
              ),
              onPressed: () => Navigator.of(context).pop(),
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
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF529B),
        onPressed: _loadBookings,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.grey[200] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Colors.grey : Colors.black,
          width: 2,
        ),
        boxShadow: [
          if (!isCompleted)
            const BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wingman card image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: Image.asset(
              booking['wingmanCardImage'] ?? 'images/stephen_card.png',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wingman name
                Text(
                  booking['wingmanName'] ?? 'Unknown Wingman',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Date and Time
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      formattedTime,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Location
                Row(
                  children: [
                    const Icon(Icons.place, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking['location'] ?? 'No location specified',
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Status indicator for completed bookings
                if (isCompleted)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'COMPLETED',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // View Receipt button
                    TextButton.icon(
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label: const Text('View Receipt'),
                      onPressed: () => _viewReceipt(booking),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF529B),
                      ),
                    ),
                    
                    const SizedBox(width: 8),

                    // Finished button (for past bookings that are not completed)
                    if (isPastBooking && !isCompleted)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Finished'),
                        onPressed: () => _completeBooking(index),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    
                    // Show space only if there are two buttons
                    if (isPastBooking && !isCompleted)
                      const SizedBox(width: 8),
                    
                    // Cancel button (only for upcoming and not completed bookings)
                    if (!isCompleted && !isPastBooking)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Cancel'),
                        onPressed: () => _cancelBooking(index),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
