import 'package:worklyn_task_app/models/task_data.dart';
import 'package:worklyn_task_app/views/chat.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final bool isLoading;
  final ChatMessageType type;
  final TaskData? task;
  final List<TaskData>? taskList; 

  ChatMessage({
    required this.text,
    required this.isMe,
    this.isLoading = false,
    this.type = ChatMessageType.text,
    this.task,
    this.taskList, 
  });
}