import 'package:flutter/material.dart';
import 'package:worklyn_task_app/models/task_data.dart';

class TaskDetailsApiView extends StatelessWidget {
  final TaskDataApi task;
  final VoidCallback onCalendarTap;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const TaskDetailsApiView({
    Key? key,
    required this.task,
    required this.onCalendarTap,
    required this.onDelete,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Edit Task',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task deleted')),
                  );
                  onDelete();
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
        ),
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: task.completed,
                    onChanged: (val) {
                      task.completed = val ?? false;
                    },
                    shape: CircleBorder(),
                  ),
                  Text(task.title),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: Color(0xFFEAEDED),
                  ),
                  width: 140,
                  padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                  child: InkWell(
                    onTap: onCalendarTap,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: Colors.green),
                        SizedBox(width: 8),
                        Text("Today", style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 1,
          color: Color.fromARGB(255, 210, 213, 213),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Icon(Icons.add),
              SizedBox(width: 10),
              Text("Add subtask"),
            ],
          ),
        ),
        Spacer(),
        ElevatedButton(
          onPressed: onClose,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 48),
          ),
          child: Text('Close'),
        ),
      ],
    );
  }
}
