import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptPage extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isWingman;
  final VoidCallback? onClose; // Add callback for custom navigation

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
      backgroundColor: const Color(0xFFF9F5F2),
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
            leading: IconButton(
              icon: Image.asset(
                'images/closeButton.png',
                width: 40,
                height: 40,
              ),
              onPressed: () {
                if (onClose != null) {
                  onClose!();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receipt header with booking ID
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Receipt",
                      style: TextStyle(
                        fontFamily: 'Futura',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Booking ID: ${booking['id'] ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Date Issued: ${DateFormat('MMM d, yyyy').format(DateTime.now())}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Booking details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Booking Details",
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Username
                  _buildDetailRow(
                    title: isWingman ? "Client" : "Username",
                    value: booking['username'] ?? 'Guest User',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Wingman name
                  _buildDetailRow(
                    title: isWingman ? "You" : "Wingman",
                    value: booking['wingmanName'] ?? 'N/A',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Date and Time
                  _buildDetailRow(
                    title: "Date",
                    value: formattedDate,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildDetailRow(
                    title: "Time",
                    value: booking['time'] ?? 'N/A',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Duration
                  _buildDetailRow(
                    title: "Duration",
                    value: (booking['duration'] ?? 'N/A').split('\n')[0],
                    price: (booking['duration'] ?? '').contains('\n') 
                        ? (booking['duration'] ?? '').split('\n')[1]
                        : null,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Location
                  _buildDetailRow(
                    title: "Location",
                    value: booking['location'] ?? 'N/A',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Purpose of booking
                  const Text(
                    "Purpose of Booking",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // List purposes with prices
                  ...List.generate(
                    purposes.length,
                    (index) {
                      final purpose = purposes[index];
                      final parts = purpose.split('\n');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("• ${parts[0]}"),
                            if (parts.length > 1)
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
                    },
                  ),
                  
                  if (purposes.isEmpty)
                    const Text("No specific purposes selected"),
                    
                  const SizedBox(height: 12),
                  
                  // Special notes
                  const Text(
                    "Special Notes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      booking['notes'] != null && booking['notes'].isNotEmpty
                          ? booking['notes']
                          : "No special notes",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payment Summary",
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Payment method
                  _buildDetailRow(
                    title: "Payment Method",
                    value: booking['paymentMethod'] ?? 'N/A',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Payment date
                  _buildDetailRow(
                    title: "Payment Date",
                    value: booking['paymentDate'] != null
                        ? DateFormat('MMM d, yyyy').format(DateTime.parse(booking['paymentDate']))
                        : 'N/A',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Divider(height: 1, thickness: 1, color: Colors.black12),
                  
                  const SizedBox(height: 16),
                  
                  // Total amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TOTAL",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "₱${NumberFormat('#,###').format(booking['totalPrice'] ?? 0)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF52EAFF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Status banner
            if (booking['cancelled'] == true)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red),
                ),
                child: const Text(
                  "CANCELLED",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            
            if (booking['completed'] == true && booking['cancelled'] != true)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text(
                  "COMPLETED",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
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
