// widgets/task_details_view_widget.dart

import 'package:flutter/material.dart';
import 'package:worklyn_task_app/models/task_data.dart';

class TaskDetailsViewWidget extends StatelessWidget {
  final TaskData task;
  final VoidCallback switchToCalendar;
  final VoidCallback onDelete;

  const TaskDetailsViewWidget({
    Key? key,
    required this.task,
    required this.switchToCalendar,
    required this.onDelete,
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
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Task deleted')));
                  onDelete(); // delegate delete logic to parent
                  Navigator.pop(context);
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
                  Expanded(child: Text(task.title)),
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
                    onTap: switchToCalendar,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.green,
                        ),
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
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 48),
          ),
          child: Text('Close'),
        ),
      ],
    );
  }
}
