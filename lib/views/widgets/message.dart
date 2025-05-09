import 'package:flutter/material.dart';
import 'package:worklyn_task_app/models/chat_message.dart';
import 'package:worklyn_task_app/models/task_data.dart';
import 'package:worklyn_task_app/views/chat.dart';
import 'package:worklyn_task_app/views/widgets/task_list.dart';
import 'package:worklyn_task_app/views/widgets/text_message.dart';
import 'package:worklyn_task_app/views/widgets/typing_dots';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final List<TaskData> tasks;
  final void Function(TaskData) onTaskTap;
  final void Function(TaskData, bool?) onTaskToggle;

  const ChatMessageWidget({
    Key? key,
    required this.message,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TypingDotsWidget(),
        ),
      );
    }

    if (message.type == ChatMessageType.task) {
      return TaskListWidget(
        tasks: tasks,
        onTaskTap: onTaskTap,
        onTaskToggle: onTaskToggle,
      );
    }

    return TextMessageWidget(message: message);
  }
}
