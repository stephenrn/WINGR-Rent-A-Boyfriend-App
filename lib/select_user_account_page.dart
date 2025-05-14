import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_navigation.dart';
// Import ToBookPage here

class SelectUserAccountPage extends StatefulWidget {
  const SelectUserAccountPage({super.key});

  @override
  State<SelectUserAccountPage> createState() => _SelectUserAccountPageState();
}

class _SelectUserAccountPageState extends State<SelectUserAccountPage> {
  // Initialize with empty list, will load from storage
  List<Map<String, String>> users = [];
  
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load users from local storage when widget initializes
    _loadUsers();
  }

  // Load users from SharedPreferences
  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString('users');
    
    if (usersJson != null) {
      final List<dynamic> decodedUsers = jsonDecode(usersJson);
      setState(() {
        // Convert each item back to Map<String, String>
        users = decodedUsers.map((user) => 
          Map<String, String>.from(user as Map<String, dynamic>)
        ).toList();
      });
    } else {
      // Initialize with empty list instead of default users
      setState(() {
        users = []; // Empty list - no default users
      });
      // Save empty list
      _saveUsers();
    }
  }

  // Save users to SharedPreferences
  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String usersJson = jsonEncode(users);
    await prefs.setString('users', usersJson);
  }

  // Add a new user and save to storage
  void _addUser(String name) {
    if (name.trim().isNotEmpty) {
      setState(() {
        users.add({'name': name.trim()});
      });
      _saveUsers(); // Save to local storage
    }
  }

  // Add method to delete a user
  void _deleteUser(int index) {
    setState(() {
      users.removeAt(index);
    });
    _saveUsers(); // Update storage after deletion
  }

  // Method to show delete confirmation dialog
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "DELETE USER",
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Confirmation message
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  children: [
                    Text(
                      "Delete ${users[index]['name']}?",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "This action cannot be undone.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cancel button
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  side: const BorderSide(color: Colors.black, width: 2),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "CANCEL",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Delete button
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                _deleteUser(index);
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5C5C), // Red delete button
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  side: const BorderSide(color: Colors.black, width: 2),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "DELETE",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Method to show the create user dialog
  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: const Color(0xFFF6FF52), // Match main yellow background
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "NEW USER",
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              
              // Body
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter Username",
                      style: TextStyle(
                        fontFamily: 'Futura',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Custom styled text field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Username",
                          hintStyle: TextStyle(
                            color: Colors.black38,
                            fontSize: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Buttons row
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _nameController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  side: const BorderSide(color: Colors.black, width: 2),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "CANCEL",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Create button
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_nameController.text.trim().isNotEmpty) {
                                  // Update to use new method that handles storage
                                  _addUser(_nameController.text);
                                  Navigator.of(context).pop();
                                  _nameController.clear();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5CA8), // Hot pink
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  side: const BorderSide(color: Colors.black, width: 2),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "CREATE",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
      ),
    );
  }

  // Method to show local storage contents
  void _showLocalStorageDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString('users');
    
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "LOCAL STORAGE",
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Storage content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Raw JSON Data:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Text(
                          usersJson ?? 'No data found',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5CA8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: const BorderSide(color: Colors.black, width: 2),
                          ),
                        ),
                        child: const Text(
                          "CLOSE",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FF52),
      body: SafeArea(
        child: Stack(  // Changed to Stack to position the debug button
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with logo, status dots, and close button - BIGGER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Increased padding
                  child: SizedBox(
                    height: 80, // Increased from 60
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Bigger Logo
                        SizedBox(
                          width: 140, // Increased from 100
                          child: Image.asset(
                            'images/logo.png',
                            height: 60, // Increased from 40
                            fit: BoxFit.contain,
                          ),
                        ),
                        
                        // Center: Bigger Status circles
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30, // Increased from 20
                              height: 30, // Increased from 20
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5C5C), // Red
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2), // Thicker border
                              ),
                            ),
                            const SizedBox(width: 12), // Increased from 8
                            Container(
                              width: 30, // Increased from 20
                              height: 30, // Increased from 20
                              decoration: BoxDecoration(
                                color: const Color(0xFF7EFF68), // Green
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2), // Thicker border
                              ),
                            ),
                            const SizedBox(width: 12), // Increased from 8
                            Container(
                              width: 30, // Increased from 20
                              height: 30, // Increased from 20
                              decoration: BoxDecoration(
                                color: const Color(0xFF5A6EFF), // Blue
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2), // Thicker border
                              ),
                            ),
                          ],
                        ),
                        
                        // Bigger Close button
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Image.asset(
                            'images/closeButton.png',
                            width: 60, // Increased from 40
                            height: 60, // Increased from 40
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60, // Increased from 40
                                height: 60, // Increased from 40
                                decoration: BoxDecoration(
                                  color: Colors.red[600],
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: 3), // Thicker border
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 36), // Bigger icon
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Title section - BIGGER
                Padding(
                  padding: const EdgeInsets.only(left: 32.0, top: 32.0, bottom: 24.0), // Increased padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Select User",
                        style: TextStyle(
                          fontFamily: 'Futura',
                          fontSize: 48, // Increased from 32
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 0.9,
                        ),
                      ),
                      Text(
                        "Account",
                        style: TextStyle(
                          fontFamily: 'Futura',
                          fontSize: 48, // Increased from 32
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Create New User button - BIGGER - NOW WITH FUNCTIONALITY
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0), // Increased padding
                  child: Container(
                    width: double.infinity,
                    height: 65, // Increased from 50
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6), // Increased shadow offset
                          blurRadius: 0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(32), // Increased radius
                    ),
                    child: ElevatedButton(
                      onPressed: _showCreateUserDialog, // Added function call here
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32), // Increased radius
                          side: const BorderSide(color: Colors.black, width: 2.5), // Thicker border
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Create New User",
                        style: TextStyle(
                          fontSize: 22, // Increased from 16
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // User list or empty state
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: users.isEmpty 
                      // Show empty state when no users exist
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Empty state illustration
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: 2.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(0, 4),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_add_alt_1,
                                  size: 80,
                                  color: Color(0xFFFF5CA8), // Hot pink
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Empty state message
                              const Text(
                                "No Users Yet",
                                style: TextStyle(
                                  fontFamily: 'Futura',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  "Create your first user by tapping the button above",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Arrow pointing upward
                              Transform.rotate(
                                angle: -3.14/2, // 90 degrees counterclockwise
                                child: const Icon(
                                  Icons.arrow_forward,
                                  size: 48,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        )
                      // Show regular list if there are users
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            // Existing ListView.builder implementation
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Container(
                                height: 80, // Increased from 60
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20), // Increased radius
                                  border: Border.all(color: Colors.black, width: 2.5), // Thicker border
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(0, 6), // Increased shadow offset
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Account icon and user name (clickable area)
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          // Navigate to HomeNavigation when user is selected
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HomeNavigation(
                                                username: users[index]['name']!,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.account_circle, 
                                                size: 45,
                                                color: Colors.black,
                                              ),
                                              const SizedBox(width: 24),
                                              Expanded(
                                                child: Text(
                                                  users[index]['name']!,
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 28,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Vertical divider
                                    Container(
                                      height: 40,
                                      width: 1,
                                      color: Colors.black38,
                                    ),
                                    
                                    // Delete button
                                    InkWell(
                                      onTap: () => _showDeleteConfirmationDialog(index),
                                      child: Container(
                                        width: 70,
                                        height: double.infinity,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(18),
                                            bottomRight: Radius.circular(18),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline,
                                          size: 30,
                                          color: Color(0xFFFF5C5C), // Red delete icon
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                ),
              ],
            ),
            
            // Debug button to show local storage
            Positioned(
              bottom: 16,
              left: 16,
              child: FloatingActionButton(
                onPressed: _showLocalStorageDialog,
                backgroundColor: Colors.grey.shade800,
                mini: true,
                child: const Icon(Icons.storage, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
