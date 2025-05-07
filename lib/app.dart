import 'package:flutter/material.dart';
import 'package:worklyn_task_app/container.dart';

class WorklynApp extends StatelessWidget {
  const WorklynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worklyn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF1397C1), // Theme primary color from hex #1397C1
        primarySwatch:
            Colors.blue, // Fallback for components that need a MaterialColor
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1397C1), // Use our custom color as seed
          primary: Color(0xFF1397C1),
        ),
      ),
      home: const AppContainer(),
    );
  }
}
