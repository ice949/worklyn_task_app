// task_list_widget.dart
import 'package:flutter/material.dart';
import 'package:worklyn_task_app/models/task_data.dart';

class TaskListWidget extends StatelessWidget {
  final List<TaskData> tasks;
  final void Function(TaskData task) onTaskTap;
  final void Function(TaskData task, bool? completed) onTaskToggle;

  const TaskListWidget({
    Key? key,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (_, index) {
        final task = tasks[index];
        return InkWell(
          onTap: () => onTaskTap(task),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Checkbox(
                  value: task.completed,
                  onChanged: (val) => onTaskToggle(task, val),
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
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text("Date", style: TextStyle(color: Colors.green)),
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
    );
  }
}
