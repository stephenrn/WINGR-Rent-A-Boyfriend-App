import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class ReceiptPage extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isWingman;
  final VoidCallback? onClose;

  const ReceiptPage({
    super.key, 
    required this.booking,
    this.isWingman = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bookingDate = DateTime.parse(booking['date']);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(bookingDate);
    final purposes = booking['purposes'] ?? [];
    
    return Scaffold(
      backgroundColor: Colors.grey[200], // Background color change
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF52EAFF), // Blue color like payment page
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
            title: const Text(
              "Receipt",
              style: TextStyle(
                fontFamily: 'Futura',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
            automaticallyImplyLeading: false,
            actions: [
              // Close button
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                width: 60,
                height: 60,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: GestureDetector(
                    onTap: () {
                      if (onClose != null) {
                        onClose!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Image.asset(
                      'images/closeButton.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Paper receipt style body
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Paper receipt container
              Container(
                constraints: BoxConstraints(
                  maxWidth: 450, // Increased receipt width from 400 to 450
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top zigzag edge for receipt
                    ClipPath(
                      clipper: ReceiptTopClipper(),
                      child: Container(
                        height: 20, // Increased from 15 to make zigzag more visible
                        color: Colors.white,
                        width: double.infinity,
                      ),
                    ),
                    
                    // Receipt content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 35), // Increased padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Added logo - BIGGER
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
                            child: Image.asset(
                              'images/logo.png',
                              height: 80, // Increased from 60 to 80
                              fit: BoxFit.contain,
                            ),
                          ),
                          
                          // Receipt header with normal font
                          const Center(
                            child: Text(
                              "WINGR",
                              style: TextStyle(
                                // Removed fontFamily: 'Courier'
                                fontWeight: FontWeight.bold,
                                fontSize: 40, 
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          
                          const Text(
                            "BOOKING RECEIPT",
                            style: TextStyle(
                              // Removed fontFamily: 'Courier'
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Receipt ID and date
                          Text(
                            "Receipt #: ${booking['id']?.substring(1, 9) ?? 'N/A'}",
                            style: const TextStyle(
                              // Removed fontFamily: 'Courier'
                              fontSize: 14,
                            ),
                          ),
                          
                          Text(
                            "Date: ${DateFormat('MM/dd/yyyy').format(DateTime.now())}",
                            style: const TextStyle(
                              // Removed fontFamily: 'Courier'
                              fontSize: 14,
                            ),
                          ),
                          
                          Text(
                            "Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}",
                            style: const TextStyle(
                              // Removed fontFamily: 'Courier'
                              fontSize: 14,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          _buildDashedLine(),
                          const SizedBox(height: 12),
                          
                          // Customer info - BIGGER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "CUSTOMER:",
                                style: TextStyle(
                                  fontSize: 16, // Increased from 12
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                booking['username'] ?? 'Guest User',
                                style: const TextStyle(
                                  fontSize: 16, // Increased from 12
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 6), // Added spacing between rows
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "WINGMAN:",
                                style: TextStyle(
                                  fontSize: 16, // Increased from 12
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                booking['wingmanName'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 16, // Increased from 12
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12), // Increased spacing after these sections
                          
                          // Booking details - simplified format
                          _buildReceiptRow("DATE", formattedDate),
                          _buildReceiptRow("TIME", booking['time'] ?? 'N/A'),
                          _buildReceiptRow("LOCATION", booking['location'] ?? 'N/A'),
                          _buildReceiptRow(
                            "DURATION", 
                            (booking['duration'] ?? 'N/A').split('\n')[0]
                          ),
                          
                          const SizedBox(height: 10),
                          _buildDashedLine(),
                          const SizedBox(height: 10),
                          
                          // Add Special Notes section
                          if (booking['notes'] != null && booking['notes'].toString().isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                
                                const Text(
                                  "SPECIAL NOTES:",
                                  style: TextStyle(
                                    // Removed fontFamily: 'Courier'
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    booking['notes'].toString(),
                                    style: const TextStyle(
                                      // Removed fontFamily: 'Courier'
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          
                          const SizedBox(height: 12),
                          _buildDashedLine(),
                          const SizedBox(height: 12),
                          
                          // Items section
                          const Text(
                            "ITEMS",
                            style: TextStyle(
                              // Removed fontFamily: 'Courier'
                              fontSize: 16, // Increased from 14
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // First item: Duration
                          _buildItemRow(
                            (booking['duration'] ?? 'N/A').split('\n')[0],
                            _extractPrice(booking['duration'] ?? '₱0')
                          ),
                          
                          // Purpose items
                          ...List.generate(
                            purposes.length,
                            (index) {
                              final purpose = purposes[index];
                              final parts = purpose.split('\n');
                              final name = parts[0];
                              final price = parts.length > 1 ? parts[1] : '₱0';
                              return _buildItemRow(name, price);
                            },
                          ),
                          
                          const SizedBox(height: 12),
                          _buildDashedLine(),
                          const SizedBox(height: 12),
                          
                          // Total section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "TOTAL",
                                style: TextStyle(
                                  // Removed fontFamily: 'Courier'
                                  fontSize: 18, // Increased from 16
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "₱${NumberFormat('#,###').format(booking['totalPrice'] ?? 0)}",
                                style: const TextStyle(
                                  // Removed fontFamily: 'Courier'
                                  fontSize: 18, // Increased from 16
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // Payment method
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "PAYMENT METHOD:",
                                style: TextStyle(
                                  // Removed fontFamily: 'Courier'
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                booking['paymentMethod'] ?? 'N/A',
                                style: const TextStyle(
                                  // Removed fontFamily: 'Courier'
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 15),
                          _buildDashedLine(),
                          const SizedBox(height: 15),
                          
                          // Status info with normal font
                          if (booking['cancelled'] == true)
                            const Center(
                              child: Text(
                                "*** CANCELLED ***",
                                style: TextStyle(
                                  // Removed fontFamily: 'Courier'
                                  fontSize: 20, // Increased from 16 to 20
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            
                          if (booking['completed'] == true && booking['cancelled'] != true)
                            const Center(
                              child: Text(
                                "*** COMPLETED ***",
                                style: TextStyle(
                                  // Removed fontFamily: 'Courier'
                                  fontSize: 20, // Increased from 16 to 20
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 20), // Increased from 15
                          
                          // Thank you notes with normal font
                          const Center(
                            child: Text(
                              "Thank you for using Wingr!",
                              style: TextStyle(
                                // Removed fontFamily: 'Courier'
                                fontSize: 14, // Increased from 12
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          const Center(
                            child: Text(
                              "See you next time!",
                              style: TextStyle(
                                // Removed fontFamily: 'Courier'
                                fontSize: 14, // Increased from 12
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20), // Increased from 15
                          
                          // Barcode - BIGGER
                          Container(
                            height: 50, // Increased from 40
                            width: 250, // Increased from 200
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('images/barcode.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                            child: const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40), // Increased bottom spacing
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to extract price
  String _extractPrice(String text) {
    if (text.contains('\n')) {
      return text.split('\n')[1];
    }
    return text;
  }
  
  // Helper method to create dashed lines
  Widget _buildDashedLine() {
    return Row(
      children: List.generate(
        40, // Number of dashes
        (index) => Expanded(
          child: Container(
            height: 1,
            color: index % 2 == 0 ? Colors.black : Colors.transparent,
          ),
        ),
      ),
    );
  }
  
  // Helper method to create receipt rows - BIGGER
  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label + ":",
            style: const TextStyle(
              // Removed fontFamily: 'Courier'
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              // Removed fontFamily: 'Courier'
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  // Helper method for item rows with prices - BIGGER
  Widget _buildItemRow(String name, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "- " + name,
              style: const TextStyle(
                // Removed fontFamily: 'Courier'
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            price,
            style: const TextStyle(
              // Removed fontFamily: 'Courier'
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper to create zigzag receipt top edge - MORE VISIBLE
class ReceiptTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Left edge
    path.lineTo(0, size.height);
    
    // Bottom edge with zigzag pattern - zigzags made deeper
    final zigzagWidth = size.width / 15; // Fewer, wider zigzags (was 20)
    final zigzagHeight = 10.0; // Increased from 5.0 to make zigzags deeper/more visible
    var currentX = 0.0;
    
    while (currentX < size.width) {
      path.lineTo(currentX + zigzagWidth / 2, size.height - zigzagHeight);
      path.lineTo(currentX + zigzagWidth, size.height);
      currentX += zigzagWidth;
    }
    
    // Right and top edges
    path.lineTo(size.width, 0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
