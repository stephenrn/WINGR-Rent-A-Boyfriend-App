import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                        }).toList(),
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
                    }).toList(),
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
                  onPressed: () {
                    if (_selectedPaymentMethod == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a payment method'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      // Handle payment processing
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Processing payment of ₱${NumberFormat('#,###').format(widget.totalPrice)}...'),
                          backgroundColor: const Color(0xFF52EAFF),
                        ),
                      );
                      
                      // In a real app, we would integrate payment gateway here
                      // For now, just show a success dialog
                      Future.delayed(const Duration(seconds: 2), () {
                        _showPaymentSuccessDialog(context);
                      });
                    }
                  },
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
  
  // Show payment success dialog
  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          title: const Text(
            "Booking Successful",
            style: TextStyle(fontFamily: 'Futura'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF52EAFF),
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                "You've successfully booked ${widget.wingmanName} for ${widget.date.day}/${widget.date.month}/${widget.date.year}!",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Check your booking details in the Bookings tab.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Return to home (close multiple screens)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: const Color(0xFF52EAFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Colors.black, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("DONE"),
            ),
          ],
        );
      },
    );
  }
}
