import 'dart:async';
import 'package:flutter/material.dart';

class TasksView extends StatefulWidget {
  const TasksView({Key? key}) : super(key: key);

  @override
  _TasksViewState createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  bool _isLoading = true;
  List<TaskData> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadDummyTasks();
  }

  void _loadDummyTasks() {
    // Simulate loading from API after 3 seconds
    Timer(Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
        _tasks = [
          TaskData(
            id: '1',
            title: 'Sample Task',
            note: 'Sample note for the task.',
            dueDate: DateTime.now().add(Duration(days: 1)),
            completed: false,
          ),
          TaskData(
            id: '2',
            title: 'Another Task',
            note: 'Another note.',
            dueDate: DateTime.now().add(Duration(days: 2)),
            completed: true,
          ),
        ];
      });
    });
  }

  void _showTaskDetails(TaskData task) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    barrierColor: Colors.black.withOpacity(0.4), // Overlay background
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.9, // 90% height
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Edit Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Add delete functionality here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Task deleted')),
                    );
                    Navigator.pop(context); // Close bottom sheet
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Row(
                        children: [
                          Text('Clicked date: ${_formatDate(task.dueDate)}'),
                        ],
                      )),
                    );
                  },
                  child: Text(
                    _formatDate(task.dueDate),
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text("Task ID: ${task.id}"),
            SizedBox(height: 8),
            Text("Completed: ${task.completed ? 'Yes' : 'No'}"),
            SizedBox(height: 8),
            Text("Note: ${task.note}"),
            Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



  String _formatDate(DateTime date) {
    return "${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)}";
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _tasks.length,
              itemBuilder: (_, index) {
                final task = _tasks[index];
                return InkWell(
                  onTap: () => _showTaskDetails(task),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: task.completed,
                          onChanged: (val) {
                            setState(() {
                              task.completed = val ?? false;
                            });
                          },
                          shape: CircleBorder(), 
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: task.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    _formatDate(task.dueDate),
                                    style: TextStyle(color: Colors.grey),
                                  ), 
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class TaskData {
  final String id;
  final String title;
  final String note;
  final DateTime dueDate;
  bool completed;

  TaskData({
    required this.id,
    required this.title,
    required this.note,
    required this.dueDate,
    this.completed = false,
  });
}
