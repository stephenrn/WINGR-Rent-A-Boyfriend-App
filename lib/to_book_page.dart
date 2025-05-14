import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wingr/payment_page.dart';

// Booking details collection page - Middle step in the booking workflow
// Gathers all necessary information before proceeding to payment
class ToBookPage extends StatefulWidget {
  final String wingmanName;
  final String wingmanCardImage;
  final String username; // Add username parameter

  const ToBookPage({
    super.key, 
    required this.wingmanName, 
    required this.wingmanCardImage,
    this.username = 'Guest User', // Default value
  });

  @override
  State<ToBookPage> createState() => _ToBookPageState();
}

class _ToBookPageState extends State<ToBookPage> {
  // Form validation management
  final _formKey = GlobalKey<FormState>();
  
  // User input controllers for text-based fields
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Selection state management - All fields required for booking completion
  DateTime? _selectedDate; // Changed to nullable
  TimeOfDay? _selectedTime; // Changed to nullable
  String? _selectedDuration; // Changed to nullable
  
  // Multi-selection state handling - Purpose options with associated pricing
  // Each option includes both the service name and its price
  final Map<String, bool> _selectedPurposes = {
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
  
  // Service pricing data - Duration options with associated costs
  // Structured format: "{duration description}\n{price}"
  final List<String> _durationOptions = [
    "30 Minutes\n₱150",
    "1 Hour\n₱250",
    "2 Hours\n₱400",
    "Half-Day (4 Hours)\n₱700",
    "Full Day (8 Hours)\n₱1,200",
    "Overnight (12 Hours)\n₱2,000"
  ];

  // Date selection workflow - Calendar date picker with constraints
  // Limited to future dates within a reasonable booking window
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

  // Time selection workflow - Platform-specific time picker
  // Collects appointment time preferences from the user
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
      
      // Brand-consistent header with distinctive booking page color scheme
      // Uses green to indicate the "collecting information" stage
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container( // Fixed: replaced comma with parenthesis
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
      
      // Main form area - Multi-field data collection interface
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Reduced padding to allow wider content
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visual confirmation - Shows selected wingman to reinforce choice
                // Maintains context of who is being booked
                Center(
                  child: Image.asset(
                    widget.wingmanCardImage,
                    width: MediaQuery.of(context).size.width * 0.95, // 95% of screen width
                    fit: BoxFit.fitWidth,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Booking details container - Primary data collection area
                // Card-based UI creates a form-focused visual container
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
                      // Section title - Clear form purpose indicator
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
                      
                      // Location field - Text input with validation
                      // Required field for meeting location information
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
                      
                      // Date selection field - Calendar popup interface
                      // Restricts selection to valid booking dates
                      _buildDateField(
                        title: "Date",
                        value: _selectedDate != null
                            ? DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!)
                            : "Select date",
                        onTap: _selectDate,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Time selection field - Time picker interface
                      // Collects appointment time using platform-specific UI
                      _buildDateField(
                        title: "Time",
                        value: _selectedTime != null
                            ? _selectedTime!.format(context)
                            : "Select time",
                        onTap: _selectTime,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Duration selection - Dropdown with pricing options
                      // Shows time increments with associated costs
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
                      
                      // Purpose selection group - Multi-select checkboxes
                      // Each option represents a service with associated cost
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
                      
                      // Special instructions field - Optional text input
                      // Allows communication of specific needs or requests
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
                
                // Navigation control - Form submission button
                // Triggers validation and price calculation before proceeding
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
                      // Form validation workflow - Checks all required fields
                      if (_formKey.currentState!.validate()) {
                        // Selective validation - Date field required check
                        if (_selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a date'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        // Selective validation - Time field required check
                        if (_selectedTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a time'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        // Selective validation - Duration field required check
                        if (_selectedDuration == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select duration'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        // Multi-selection validation - At least one purpose required
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
                          // Price calculation logic - Dynamic total based on selections
                          // Combines duration cost with all selected purpose costs
                          int totalPrice = 0;
                          
                          // Base rate - Duration component
                          final durationPrice = int.parse(_selectedDuration!.split('\n')[1]
                              .replaceAll('₱', '')
                              .replaceAll(',', ''));
                          totalPrice += durationPrice;
                          
                          // Additional services - Purpose components
                          for (String purpose in selectedPurposesList) {
                            final purposePrice = int.parse(purpose.split('\n')[1]
                                .replaceAll('₱', '')
                                .replaceAll(',', ''));
                            totalPrice += purposePrice;
                          }
                          
                          // Workflow progression - Navigation to payment step
                          // All form data passed to maintain state consistency
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                username: widget.username,
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

  // Form field component - Standardized text input pattern
  // Creates consistent styling for all text entry fields
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
  
  // Interactive field component - Date and time selection pattern
  // Custom field styling with action triggers for picker dialogs
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
  
  // Selection component - Styled dropdown with pricing info
  // Enhanced dropdown that visually separates options and prices
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

  // Multi-selection component builder - Creates the purpose options
  // Dynamically generates checkbox rows with visual separation
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
