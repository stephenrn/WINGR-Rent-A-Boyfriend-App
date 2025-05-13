import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wingr/payment_page.dart';

class ToBookPage extends StatefulWidget {
  final String wingmanName;
  final String wingmanCardImage;

  const ToBookPage({
    super.key, 
    required this.wingmanName, 
    required this.wingmanCardImage,
  });

  @override
  State<ToBookPage> createState() => _ToBookPageState();
}

class _ToBookPageState extends State<ToBookPage> {
  // Form controller
  final _formKey = GlobalKey<FormState>();
  
  // Form field controllers
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Selected values - Remove defaults
  DateTime? _selectedDate; // Changed to nullable
  TimeOfDay? _selectedTime; // Changed to nullable
  String? _selectedDuration; // Changed to nullable
  
  // Replace selected purpose with a map where all values are false (no defaults)
  Map<String, bool> _selectedPurposes = {
    "Movie Date\n₱500": false,
    "Family/Event Companion\n₱1,000": false,
    "Shopping Buddy\n₱400": false,
    "Study Buddy / Tutor\n₱300": false,
    "Emotional Support\n₱400": false,
    "Virtual Date\n₱200": false,
    "Travel Companion (Day Tour)\n₱2,000": false,
    "Gym Partner\n₱350": false,
    "Photoshoot Partner\n₱500": false,
    "Café or Chill Talk\n₱300": false,
    "Nightlife Companion\n₱1,000": false,
    "Pet Date\n₱400": false
  };
  
  // Duration options with pricing
  final List<String> _durationOptions = [
    "30 Minutes\n₱150",
    "1 Hour\n₱250",
    "2 Hours\n₱400",
    "Half-Day (4 Hours)\n₱700",
    "Full Day (8 Hours)\n₱1,200",
    "Overnight (12 Hours)\n₱2,000"
  ];

  // Remove purpose options as we now use the map keys

  // Update date picker to handle nullable date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Use current date if none selected
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF529B),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Update time picker to handle nullable time
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(), // Use current time if none selected
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF529B),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF52FF68),
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
            
            // Fix logo size issue
            leading: Container(
              padding: EdgeInsets.only(left: 20), // Remove padding
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  'images/logo.png',
                ),
              ),
            ),
            leadingWidth: 80, // Give more width to the leading widget
            
            // Make close button bigger
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                width: 60, // Fixed width container
                height: 60, // Fixed height container
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
              "Booking",
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
          padding: const EdgeInsets.all(16.0), // Reduced padding to allow wider content
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wingman card image - made bigger
                Center(
                  child: Image.asset(
                    widget.wingmanCardImage,
                    width: MediaQuery.of(context).size.width * 0.95, // 95% of screen width
                    fit: BoxFit.fitWidth,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Booking form in a wider container
                Container(
                  width: MediaQuery.of(context).size.width, // Full width
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
                      // Booking form title
                      const Text(
                        "Booking Details",
                        style: TextStyle(
                          fontFamily: 'Futura',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Location - remove box shadow
                      _buildFormField(
                        title: "Location",
                        hintText: "Enter meeting place",
                        controller: _locationController,
                        prefixIcon: Icons.place,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a location";
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Date field - Updated to handle nullable value
                      _buildDateField(
                        title: "Date",
                        value: _selectedDate != null
                            ? DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!)
                            : "Select date",
                        onTap: _selectDate,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Time field - Updated to handle nullable value
                      _buildDateField(
                        title: "Time",
                        value: _selectedTime != null
                            ? _selectedTime!.format(context)
                            : "Select time",
                        onTap: _selectTime,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Duration dropdown - Updated to handle nullable value
                      _buildDropdownField(
                        title: "Duration",
                        value: _selectedDuration,
                        items: _durationOptions,
                        hint: "Select duration",
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedDuration = value;
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Purpose of booking as checkboxes
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Purpose of Booking",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: _buildPurposeCheckboxes(),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Special notes
                      _buildFormField(
                        title: "Special Notes",
                        hintText: "Any additional information",
                        controller: _notesController,
                        prefixIcon: Icons.note,
                        maxLines: 3,
                        validator: null, // Optional field
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Next button with green color
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
                      if (_formKey.currentState!.validate()) {
                        // Check if date, time, and duration are selected
                        if (_selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a date'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        if (_selectedTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a time'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        if (_selectedDuration == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select duration'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        // Get the list of selected purposes
                        final selectedPurposesList = _selectedPurposes.entries
                            .where((entry) => entry.value)
                            .map((entry) => entry.key) // Keep the full string with price
                            .toList();
                        
                        if (selectedPurposesList.isEmpty) {
                          // Show error if no purpose is selected
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least one purpose for booking'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          // Calculate total price
                          int totalPrice = 0;
                          
                          // Add duration price
                          final durationPrice = int.parse(_selectedDuration!.split('\n')[1]
                              .replaceAll('₱', '')
                              .replaceAll(',', ''));
                          totalPrice += durationPrice;
                          
                          // Add purpose prices
                          for (String purpose in selectedPurposesList) {
                            final purposePrice = int.parse(purpose.split('\n')[1]
                                .replaceAll('₱', '')
                                .replaceAll(',', ''));
                            totalPrice += purposePrice;
                          }
                          
                          // For payment page display purposes, get purpose names without prices
                          final purposeNames = selectedPurposesList
                              .map((purpose) => purpose.split('\n')[0])
                              .toList();
                          
                          // Navigate to payment page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                wingmanName: widget.wingmanName,
                                wingmanCardImage: widget.wingmanCardImage,
                                location: _locationController.text,
                                date: _selectedDate!,
                                time: _selectedTime!,
                                duration: _selectedDuration!,
                                purposes: selectedPurposesList, // Pass full strings with prices
                                notes: _notesController.text,
                                totalPrice: totalPrice,
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52FF68), // Changed to green
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
                          "NEXT",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
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
      ),
    );
  }

  // Update form field to remove shadow
  Widget _buildFormField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required IconData prefixIcon,
    required String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black, width: 2),
            // Box shadow removed
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(prefixIcon, color: const Color(0xFF52FF68)), // Changed to green
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
  
  // Update date field to remove shadow
  Widget _buildDateField({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black, width: 2),
              // Box shadow removed
            ),
            child: Row(
              children: [
                Icon(
                  title == "Date" ? Icons.calendar_today : Icons.access_time,
                  color: const Color(0xFF52FF68), // Changed to green
                ),
                const SizedBox(width: 12),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Update dropdown field to display prices clearly
  Widget _buildDropdownField({
    required String title,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black, width: 2),
            // Box shadow removed as requested
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: TextStyle(color: Colors.grey[400]),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF52FF68)),
              isExpanded: true,
              // Explicitly set a higher item height
              itemHeight: kMinInteractiveDimension + 20,
              items: items.map<DropdownMenuItem<String>>((String value) {
                // Split the option and price
                final parts = value.split('\n');
                final option = parts[0];
                final price = parts.length > 1 ? parts[1] : "";
                
                return DropdownMenuItem<String>(
                  value: value,
                  // Use a Row to place option and price side by side
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Price in bold green
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF52FF68),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              // Show the selected value with proper formatting
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((String value) {
                  final parts = value.split('\n');
                  final option = parts[0];
                  final price = parts.length > 1 ? parts[1] : "";
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(option),
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF52FF68),
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Add a method to build the purpose checkboxes
  List<Widget> _buildPurposeCheckboxes() {
    List<Widget> checkboxes = [];
    
    _selectedPurposes.forEach((purpose, isSelected) {
      // Split purpose text and price
      final parts = purpose.split('\n');
      final option = parts[0];
      final price = parts.length > 1 ? parts[1] : "";
      
      checkboxes.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFF52FF68),
                  side: const BorderSide(color: Colors.black, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedPurposes[purpose] = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF52FF68),
                ),
              ),
            ],
          ),
        ),
      );
      
      // Add divider between items (except after the last item)
      if (purpose != _selectedPurposes.keys.last) {
        checkboxes.add(const Divider(height: 1, thickness: 1));
      }
    });
    
    return checkboxes;
  }
}
