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
  CalendarFormat _calendarFormat = CalendarFormat.week; // Changed from CalendarFormat.month to week
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
            color: Color(0xFFF6FF52), // Yellow background
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: SafeArea(
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              // Leading section with logo
              leading: Container(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset(
                  'images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              leadingWidth: 60, // Width for logo
              // WINGR title instead of wingman's dashboard 
              title: const Text(
                "WINGR",
                style: TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
              titleSpacing: 0,
              actions: [
                // Storage button - moved to actions area with icon only
                Container(
                  margin: const EdgeInsets.only(right: 10.0),
                  width: 50,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          offset: Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.storage, color: Colors.black, size: 24),
                      onPressed: () => _showLocalStorageViewer(),
                    ),
                  ),
                ),
                // Close button using closeButton.png
                Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      'images/closeButton.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
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
              ],
            ),
          ),
        ),
      ),
      
      // Body now contains both TabBar and TabBarView
      body: Column(
        children: [
          // TabBar with more modern styling
          Container(
            color: const Color(0xFFF6FF52), // Yellow background to match AppBar
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black54,
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
                Container(
                  height: 3.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          
          // TabBarView takes remaining space
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // To Go Tab
                _buildToGoTab(),
                
                // History Tab
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
      
      // Remove FloatingActionButton as storage button is now in AppBar
      // floatingActionButton: ... (removed)
    );
  }
  
  // Build the To Go tab with calendar and upcoming bookings
  Widget _buildToGoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Wingman profile card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFF0), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Profile picture with enhanced styling
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          offset: Offset(0, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        widget.wingmanImage,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.wingmanName,
                          style: const TextStyle(
                            fontFamily: 'Futura',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Stats in attractive containers
                        Row(
                          children: [
                            // Upcoming bookings stat - Text now above icon and number
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6FF52).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black, width: 1.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Title now at the top
                                    const Text(
                                      "Upcoming",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Icon and number in a row below
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.event, color: Colors.black),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${_upcomingBookings.length}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 10),
                            
                            // Past bookings stat - Text now above icon and number
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5CA8).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black, width: 1.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Title now at the top
                                    const Text(
                                      "History",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Icon and number in a row below
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.history, color: Colors.black),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${_pastBookings.length}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
          
          // Enhanced Calendar container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar header - remove date display from black container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6FF52),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(17.5),
                      topRight: Radius.circular(17.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        "BOOKING CALENDAR",
                        style: TextStyle(
                          fontFamily: 'Futura',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Format toggle button - removing the date display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              // Cycle through calendar formats when clicked
                              if (_calendarFormat == CalendarFormat.month) {
                                _calendarFormat = CalendarFormat.twoWeeks;
                              } else if (_calendarFormat == CalendarFormat.twoWeeks) {
                                _calendarFormat = CalendarFormat.week;
                              } else {
                                _calendarFormat = CalendarFormat.month;
                              }
                            });
                          },
                          child: const Icon(
                            Icons.expand_more,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Calendar
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat, // This now works with the toggle button above
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                      CalendarFormat.twoWeeks: '2 Weeks',
                      CalendarFormat.week: 'Week',
                    },
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
                    calendarStyle: CalendarStyle(
                      markerDecoration: BoxDecoration(
                        color: const Color(0xFFFF5CA8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      markerSize: 8,
                      markersMaxCount: 3,
                      todayDecoration: BoxDecoration(
                        color: const Color(0x55F6FF52),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFFF6FF52),
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(color: Color(0xFF616161)),
                      outsideTextStyle: const TextStyle(color: Color(0xFFAEAEAE)),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontFamily: 'Futura',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      headerPadding: EdgeInsets.symmetric(vertical: 4),
                      leftChevronIcon: Icon(Icons.chevron_left, size: 28),
                      rightChevronIcon: Icon(Icons.chevron_right, size: 28),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                      weekendStyle: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF616161)),
                    ),
                  ),
                ),
                
                // Booking Legend
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCalendarLegendItem('Today', const Color(0x55F6FF52)),
                      const SizedBox(width: 16),
                      _buildCalendarLegendItem('Selected', const Color(0xFFF6FF52)),
                      const SizedBox(width: 16),
                      _buildCalendarLegendItem('Has Bookings', const Color(0xFFFF5CA8)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Upcoming bookings section header
          Row(
            children: [
              const Icon(Icons.upcoming, size: 24),
              const SizedBox(width: 8),
              const Text(
                "Upcoming Bookings",
                style: TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                "${_upcomingBookings.length} bookings",
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // List of upcoming bookings with enhanced styling
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

  // Legend item for calendar
  Widget _buildCalendarLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
  
  // Build the History tab with past bookings in table format
  Widget _buildHistoryTab() {
    // Calculate total earnings (excluding cancelled bookings)
    int totalEarnings = 0;
    int totalCompletedBookings = 0;
    
    for (var booking in _pastBookings) {
      if (booking['cancelled'] != true) {
        if (booking['totalPrice'] != null) {
          totalEarnings += (booking['totalPrice'] as num).toInt();
        }
        totalCompletedBookings++;
      }
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header with stats summary
          Row(
            children: [
              const Icon(Icons.history, size: 24),
              const SizedBox(width: 8),
              const Text(
                "Booking History",
                style: TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Stats boxes at the top - Changed from Row to Column to make each container wider
          Column(
            children: [
              // Total bookings stat - Now takes full width
              Container(
                width: double.infinity,
                height: 85,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 3),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TOTAL BOOKINGS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "${_pastBookings.length}",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Completed bookings stat - Now takes full width
              Container(
                width: double.infinity,
                height: 85,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 3),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "COMPLETED",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "$totalCompletedBookings",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Total earnings stat - Now takes full width
              Container(
                width: double.infinity,
                height: 85,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDAF8DA), Color(0xFFC7F5C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 3),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TOTAL EARNINGS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      "₱${NumberFormat('#,###').format(totalEarnings)}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D8C0D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _pastBookings.isEmpty
              ? _buildEmptyState("No booking history")
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // Modified borderRadius to only round the top corners
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      // Bottom corners are now square (not rounded)
                    ),
                    border: Border.all(color: Colors.black, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Table header with enhanced styling
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF6FF52),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(13.5),
                            topRight: Radius.circular(13.5),
                            // Bottom corners match the parent container (square)
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "USERNAME",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'Futura',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "DATE",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'Futura',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "EARNINGS",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'Futura',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Improved table rows
                      Column(
                        children: List.generate(
                          _pastBookings.length,
                          (index) => _buildHistoryTableRow(_pastBookings[index], index),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  // Enhanced booking card with modern styling
  Widget _buildBookingCard(Map<String, dynamic> booking, int index, bool isPast) {
    final DateTime bookingDate = DateTime.parse(booking['date']);
    final String formattedDate = DateFormat('EEE, MMM d, yyyy').format(bookingDate);
    final String formattedTime = booking['time'];
    final bool isCancelled = booking['cancelled'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isCancelled
            ? LinearGradient(
                colors: [Colors.grey[100]!, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFFFFF0), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCancelled ? Colors.grey : Colors.black,
          width: 2,
        ),
        boxShadow: [
          if (!isCancelled)
            const BoxShadow(
              color: Colors.black38,
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
            // Status indicator for cancelled bookings
            if (isCancelled)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'CANCELLED',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Top section with client info and metadata
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Client name
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6FF52).withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              booking['username'] ?? 'Unknown Client',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCancelled ? Colors.grey : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Date and time with icons
                      Row(
                        children: [
                          Icon(Icons.calendar_today, 
                            size: 16,
                            color: isCancelled ? Colors.grey : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: isCancelled ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(Icons.access_time, 
                            size: 16,
                            color: isCancelled ? Colors.grey : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: isCancelled ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Price tag
                if (!isCancelled)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF52FF68).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF52FF68)),
                    ),
                    child: Text(
                      "₱${NumberFormat('#,###').format(booking['totalPrice'] ?? 0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D8C0D),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Location
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCancelled ? Colors.grey.shade300 : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.place, 
                    size: 16,
                    color: isCancelled ? Colors.grey : Colors.redAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking['location'] ?? 'No location specified',
                      style: TextStyle(
                        color: isCancelled ? Colors.grey : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
              
            const SizedBox(height: 16),
            
            // Action buttons in a row at the bottom
            Row(
              children: [
                // View Receipt button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('View Receipt'),
                    onPressed: () => _viewReceipt(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52EAFF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Cancel button (only for upcoming bookings)
                if (!isPast && !isCancelled)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Cancel'),
                      onPressed: () => _cancelBooking(index, isPast),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.red, width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced history table row with better styling
  Widget _buildHistoryTableRow(Map<String, dynamic> booking, int index) {
    final DateTime bookingDate = DateTime.parse(booking['date']);
    final String formattedDate = DateFormat('MMM d, yyyy').format(bookingDate);
    final bool isCancelled = booking['cancelled'] == true;
    final bool isLastRow = index == _pastBookings.length - 1;
    
    return InkWell(
      onTap: () => _viewReceipt(booking),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: index % 2 == 0 ? Colors.white : const Color(0xFFF9F9F9),
          border: Border(
            bottom: isLastRow ? BorderSide.none : BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCancelled 
                          ? Colors.grey[300] 
                          : const Color(0xFFF6FF52).withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 18,
                        color: isCancelled ? Colors.grey[600] : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      booking['username'] ?? 'Unknown User',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isCancelled ? Colors.grey : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 14,
                  color: isCancelled ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: isCancelled
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: const Text(
                          "CANCELLED",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      )
                    : Text(
                        "₱${NumberFormat('#,###').format(booking['totalPrice'] ?? 0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0D8C0D),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Improved empty state with illustration
  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF6FF52).withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              message.contains("upcoming") ? Icons.event_busy : Icons.history_toggle_off,
              size: 60,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message.contains("upcoming") 
                ? "Bookings will appear here when clients book you"
                : "Your booking history will appear here",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
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
