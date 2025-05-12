import 'package:flutter/material.dart';
import 'home_page.dart';
import 'booking_page.dart';
import 'profile_page.dart';

class HomeNavigation extends StatefulWidget {
  final String username;
  
  const HomeNavigation({super.key, required this.username});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> with SingleTickerProviderStateMixin {
  int _currentIndex = 1; // Default to home (center) tab
  late List<Widget> _pages;
  late PageController _pageController;
  late AnimationController _animationController;
  late List<Animation<double>> _tabAnimations;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Create animations for each tab
    _tabAnimations = List.generate(3, (index) => 
      Tween<double>(
        begin: index == 1 ? 1.0 : 0.7, // Start with home tab active
        end: index == 1 ? 1.0 : 0.7,
      ).animate(_animationController)
    );
    
    // Initialize pages and page controller
    _pages = [
      BookingPage(username: widget.username),
      HomePage(username: widget.username),
      ProfilePage(username: widget.username),
    ];
    
    _pageController = PageController(
      initialPage: 1,
      keepPage: true,
    );
  }
  
  void _updateTabAnimations(int selectedIndex) {
    for (int i = 0; i < _tabAnimations.length; i++) {
      _tabAnimations[i] = Tween<double>(
        begin: _tabAnimations[i].value,
        end: i == selectedIndex ? 1.0 : 0.7,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ));
    }
    _animationController.reset();
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FF52), // Yellow background
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      
      // Floating navigation bar
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 8),
                blurRadius: 0,
              ),
            ],
            border: Border.all(color: Colors.black, width: 2.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabItem(0, Icons.calendar_today, 'Bookings'),
              _buildCenterTabItem(1, Icons.home, 'Home'),
              _buildTabItem(2, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return AnimatedBuilder(
      animation: _tabAnimations[index],
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentIndex = index;
              _updateTabAnimations(index);
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Transform.scale(
              scale: _tabAnimations[index].value,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF6FF52) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                ),
                child: Icon(
                  icon, 
                  size: 28,
                  color: isSelected ? Colors.black : Colors.black54,
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildCenterTabItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return AnimatedBuilder(
      animation: _tabAnimations[index],
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentIndex = index;
              _updateTabAnimations(index);
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Transform.scale(
              scale: _tabAnimations[index].value,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: isSelected ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF5CA8) : Colors.black,
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
                    child: Center(
                      child: Icon(
                        icon,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }
    );
  }
}
