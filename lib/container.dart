import 'package:flutter/material.dart';
import 'package:worklyn_task_app/views/chat.dart';
import 'package:worklyn_task_app/views/settings.dart';
import 'package:worklyn_task_app/views/tasks.dart';

class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

  @override
  State<AppContainer> createState() => _MyAppContainerState();
}

class _MyAppContainerState extends State<AppContainer> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    ChatView(),
    TasksView(),
    SettingsView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:  _pages.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_sharp),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Color(0xFFF9F9F9),
          selectedItemColor: Color(0xFF1397C1), // Using our theme color #1397C1
          unselectedItemColor: Colors.grey,
          iconSize: 23,
        ),
      ),
    );
  }
}
