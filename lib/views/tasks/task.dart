import 'package:flutter/material.dart';

class TaskView extends StatelessWidget {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Task Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}