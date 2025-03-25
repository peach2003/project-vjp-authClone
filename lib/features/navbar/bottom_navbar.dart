import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../chat/friend_list/screens/friend_list_screen.dart';
import '../contact/screens/test_upload.dart';
import '../home/screens/home_screen.dart';
import '../person/person_screen.dart';

class BottomNavbar extends StatefulWidget {
  final int currentUserId; // Truyền ID user đăng nhập
  const BottomNavbar({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions(int currentUserId) => <Widget>[
    HomeScreen(),
    Text('Search Screen'),
    FriendListScreen(currentUserId: currentUserId), // ✅ Thêm danh sách bạn bè
    TestUploadScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions(widget.currentUserId).elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Color.fromARGB(255, 249, 213, 63),
        buttonBackgroundColor: Color.fromARGB(255, 249, 213, 63),
        height: 65,
        items: <Widget>[
          _buildIcon(Icons.home_outlined, 0),
          _buildIcon(Icons.search_outlined, 1),
          _buildIcon(Icons.chat_outlined, 2),
          _buildIcon(Icons.feed_outlined, 3),
          _buildIcon(Icons.person_outlined, 4),
        ],
        onTap: _onItemTapped,
        index: _selectedIndex,
        animationDuration: Duration(milliseconds: 500),
        animationCurve: Curves.fastOutSlowIn,
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: _selectedIndex == index ? 40 : 30,
      height: _selectedIndex == index ? 40 : 30,
      child: Icon(icon, color: Color.fromARGB(255, 242, 66, 54)),
    );
  }
}
