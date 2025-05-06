import 'package:flutter/material.dart';
import 'package:worklyn_task_app/views/task.dart';

class WorklynApp extends StatelessWidget {
  const WorklynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worklyn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TaskView(),
    );
  }
}