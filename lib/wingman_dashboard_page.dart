import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'receipt_page.dart';
import 'package:intl/intl.dart';

class WingmanDashboardPage extends StatefulWidget {
  final String wingmanName;
  final String wingmanImage;

  const WingmanDashboardPage({
    super.key, 
    required this.wingmanName, 
    required this.wingmanImage,
  });

  @override
  State<WingmanDashboardPage> createState() => _WingmanDashboardPageState();
}

class _WingmanDashboardPageState extends State<WingmanDashboardPage> with TickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Booking data
  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _pastBookings = [];
  
  // Events for calendar
  Map<DateTime, List<dynamic>> _events = {};
  
  // Storage key
  String get _storageKey => 'wingman_bookings_${widget.wingmanName.toLowerCase()}';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Load bookings from SharedPreferences
  Future<void> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? bookingsJson = prefs.getString('bookings');
    
    if (bookingsJson != null) {
      try {
        final List<dynamic> allBookings = json.decode(bookingsJson);
        
        // Filter bookings for this wingman
        final wingmanBookings = allBookings
            .where((booking) => 
                booking['wingmanName'] == widget.wingmanName)
            .map((booking) => Map<String, dynamic>.from(booking))
            .toList();
        
        final now = DateTime.now();
        // Create a date-only version of now (without time) for fair comparison
        final nowDateOnly = DateTime(now.year, now.month, now.day);
        
        _upcomingBookings = [];
        _pastBookings = [];
        _events = {};
        
        for (var booking in wingmanBookings) {
          final bookingDate = DateTime.parse(booking['date']);
          // Create a date-only version of booking date (without time)
          final bookingDateOnly = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
          
          final DateTime eventDate = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
          
          // Populate events for calendar
          if (_events[eventDate] == null) {
            _events[eventDate] = [];
          }
          _events[eventDate]!.add(booking);
          
          // Sort into upcoming or past based on date and completion status
          if (booking['cancelled'] != true) {
            if (booking['completed'] == true) {
              // Completed bookings go to past
              _pastBookings.add(booking);
            } else if (nowDateOnly.isAfter(bookingDateOnly)) {
              // Past date but not completed bookings still go to past
              // Compare date-only objects to ignore time component
              _pastBookings.add(booking);
            } else {
              // Future bookings (including today) go to upcoming
              _upcomingBookings.add(booking);
            }
          } else {
            // Add cancelled bookings to past
            _pastBookings.add(booking);
          }
        }
        
        // Sort bookings by date
        _upcomingBookings.sort((a, b) {
          final dateA = DateTime.parse(a['date']);
          final dateB = DateTime.parse(b['date']);
          return dateA.compareTo(dateB);
        });
        
        _pastBookings.sort((a, b) {
          final dateA = DateTime.parse(a['date']);
          final dateB = DateTime.parse(b['date']);
          return dateB.compareTo(dateA); // Most recent first
        });
        
        setState(() {});
      } catch (e) {
        debugPrint('Error loading bookings: $e');
      }
    }
  }
  
  // Mark booking as completed
  void _completeBooking(int index) async {
    final booking = _upcomingBookings[index];
    booking['completed'] = true;
    
    await _updateBookingInStorage(booking);
    _loadBookings();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking marked as completed'),
          backgroundColor: Color(0xFF52FF68),
        ),
      );
    }
  }
  
  // Cancel booking - updated with confirmation dialog and message
  void _cancelBooking(int index, bool isPast) async {
    // Show confirmation dialog with message text field
    final TextEditingController messageController = TextEditingController();
    
    final bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Cancel Booking?",
            style: TextStyle(fontFamily: 'Futura'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure you want to cancel this booking? Please provide a reason for cancellation:",
                style: TextStyle(fontFamily: 'Futura'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter cancellation reason...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: Colors.grey[600],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "Confirm Cancellation",
                  style: TextStyle(
                    fontFamily: 'Futura',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
    
    if (!confirmed) return;
    
    // Process cancellation
    final booking = isPast ? _pastBookings[index] : _upcomingBookings[index];
    booking['cancelled'] = true;
    booking['cancellationMessage'] = messageController.text;
    booking['cancelledBy'] = 'wingman';
    booking['cancellationDate'] = DateTime.now().toIso8601String();
    
    await _updateBookingInStorage(booking);
    
    // Also store the notification for the user
    await _storeNotificationForUser(
      username: booking['username'], 
      message: "Your booking with ${widget.wingmanName} on ${DateFormat('MMM d, yyyy').format(DateTime.parse(booking['date']))} was cancelled.",
      details: messageController.text,
      bookingId: booking['id'],
    );
    
    _loadBookings();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Method to store a notification for the user
  Future<void> _storeNotificationForUser({
    required String username, 
    required String message,
    required String details,
    required String bookingId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Create notification data structure
    final notification = {
      'id': 'N${DateTime.now().millisecondsSinceEpoch}',
      'username': username,
      'message': message,
      'details': details,
      'bookingId': bookingId,
      'date': DateTime.now().toIso8601String(),
      'read': false,
    };
    
    // Get existing notifications
    List<dynamic> notifications = [];
    final String? notificationsJson = prefs.getString('user_notifications');
    
    if (notificationsJson != null) {
      notifications = json.decode(notificationsJson);
    }
    
    // Add new notification
    notifications.add(notification);
    
    // Save updated notifications
    await prefs.setString('user_notifications', json.encode(notifications));
  }
  
  // Delete booking from history
  void _deleteBooking(int index) async {
    // We just mark it as deleted in this implementation
    final booking = _pastBookings[index];
    booking['deleted'] = true;
    
    await _updateBookingInStorage(booking);
    _loadBookings();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking deleted from history'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  // View booking receipt
  void _viewReceipt(Map<String, dynamic> booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptPage(
          booking: booking,
          isWingman: true,
        ),
      ),
    );
  }
  
  // Get events for a day
  List<dynamic> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  // Helper method to update a booking in storage
  Future<void> _updateBookingInStorage(Map<String, dynamic> booking) async {
    final prefs = await SharedPreferences.getInstance();
    final String? bookingsJson = prefs.getString('bookings');
    
    if (bookingsJson != null) {
      final List<dynamic> allBookings = json.decode(bookingsJson);
      
      // Find and update the booking
      for (int i = 0; i < allBookings.length; i++) {
        if (allBookings[i]['id'] == booking['id']) {
          // Preserve the original username if it exists
          booking['username'] = allBookings[i]['username'] ?? booking['username'];
          allBookings[i] = booking;
          break;
        }
      }
      
      // Save updated bookings
      await prefs.setString('bookings', json.encode(allBookings));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF52FF68), // Green background for wingman pages
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
              "${widget.wingmanName}'s Dashboard",
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
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              indicatorWeight: 4,
              labelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Futura',
              ),
              tabs: const [
                Tab(text: "To Go"),
                Tab(text: "History"),
              ],
            ),
          ),
        ),
      ),
      
      body: TabBarView(
        controller: _tabController,
        children: [
          // To Go Tab
          _buildToGoTab(),
          
          // History Tab
          _buildHistoryTab(),
        ],
      ),
      
      // Floating action button to view local storage data
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF52FF68),
        child: const Icon(Icons.storage, color: Colors.black),
        onPressed: () {
          _showLocalStorageViewer();
        },
      ),
    );
  }
  
  // Build the To Go tab with calendar and upcoming bookings
  Widget _buildToGoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wingman profile card
          Container(
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      widget.wingmanImage,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Wingman info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.wingmanName,
                          style: const TextStyle(
                            fontFamily: 'Futura',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.event, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              '${_upcomingBookings.length} Upcoming Bookings',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.history, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              '${_pastBookings.length} Past Bookings',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Calendar with bookings
          Container(
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
            padding: const EdgeInsets.all(12),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Color(0xFF52FF68),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0x5552FF68),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF52FF68),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Upcoming bookings
          const Text(
            "Upcoming Bookings",
            style: TextStyle(
              fontFamily: 'Futura',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // List of upcoming bookings
          _upcomingBookings.isEmpty
              ? _buildEmptyState("No upcoming bookings")
              : Column(
                  children: List.generate(
                    _upcomingBookings.length,
                    (index) => _buildBookingCard(
                      _upcomingBookings[index],
                      index,
                      false,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
  
  // Build the History tab with past bookings
  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Booking History",
            style: TextStyle(
              fontFamily: 'Futura',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // List of past bookings
          _pastBookings.isEmpty
              ? _buildEmptyState("No booking history")
              : Column(
                  children: List.generate(
                    _pastBookings.length,
                    (index) => _buildBookingCard(
                      _pastBookings[index],
                      index,
                      true,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
  
  // Build a booking card
  Widget _buildBookingCard(Map<String, dynamic> booking, int index, bool isPast) {
    final DateTime bookingDate = DateTime.parse(booking['date']);
    final String formattedDate = DateFormat('EEE, MMM d, yyyy').format(bookingDate);
    final String formattedTime = booking['time'];
    final bool isCancelled = booking['cancelled'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCancelled ? Colors.grey[200] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCancelled ? Colors.grey : Colors.black,
          width: 2,
        ),
        boxShadow: [
          if (!isCancelled)
            const BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client info
            Row(
              children: [
                const Icon(Icons.person, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking['username'] ?? 'Unknown Client',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
            
            const SizedBox(height: 8),
            
            // Status tag
            if (isCancelled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red),
                ),
                child: const Text(
                  'CANCELLED',
                  style: TextStyle(
                    color: Colors.red,
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
                    foregroundColor: const Color(0xFF52FF68),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Cancel button (only for upcoming bookings)
                if (!isPast && !isCancelled)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Cancel'),
                    onPressed: () => _cancelBooking(index, isPast),
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
    );
  }
  
  // Build empty state message
  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  // Show local storage viewer dialog
  void _showLocalStorageViewer() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getKeys().map((key) {
      var value = prefs.get(key);
      if (value is String && (key.contains('booking') || key.contains('wingman'))) {
        try {
          value = const JsonDecoder().convert(value);
        } catch (_) {
          // Not valid JSON, keep as is
        }
      }
      return MapEntry(key, value);
    }).toList();
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Local Storage Data'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final entry = data[index];
                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (entry.key == 'user_bookings')
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteStorage('user_bookings', context),
                            tooltip: 'Delete user bookings',
                          ),
                      ],
                    ),
                    subtitle: Text(
                      entry.value.toString(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Show full data in another dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(entry.key),
                            content: SingleChildScrollView(
                              child: Text(
                                const JsonEncoder.withIndent('  ').convert(entry.value),
                              ),
                            ),
                            actions: <Widget>[
                              if (entry.key == 'user_bookings')
                                TextButton(
                                  child: const Text('Delete This Data', style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _confirmDeleteStorage('user_bookings', context);
                                  },
                                ),
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              // Add a dedicated button to delete user bookings
              TextButton(
                child: const Text('Delete User Bookings', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  _confirmDeleteStorage('user_bookings', context);
                },
              ),
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              // Add a button to delete all local storage
              TextButton(
                child: const Text('Delete All Local Storage', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  _confirmDeleteAllStorage(context);
                },
              ),
            ],
          );
        },
      );
    }
  }
  
  // Confirm and delete storage
  void _confirmDeleteStorage(String key, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete all $key data?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(key);
                
                // Close the confirmation dialog
                Navigator.of(dialogContext).pop();
                
                // Close the storage viewer dialog to refresh
                if (context.mounted) {
                  Navigator.of(context).pop();
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$key data deleted successfully'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  
                  // Reload bookings data if on dashboard
                  _loadBookings();
                }
              },
            ),
          ],
        );
      },
    );
  }
  
  // Confirm and delete all storage
  void _confirmDeleteAllStorage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Complete Deletion'),
          content: const Text('Are you sure you want to delete ALL local storage data? This cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete Everything'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clear all local storage
                
                // Close the confirmation dialog
                Navigator.of(dialogContext).pop();
                
                // Close the storage viewer dialog
                if (context.mounted) {
                  Navigator.of(context).pop();
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All local storage data deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  
                  // Reload bookings data to reflect changes
                  _loadBookings();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
