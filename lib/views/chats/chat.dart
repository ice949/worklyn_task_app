import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

enum ChatMessageType { text, task }

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;
  bool _isResponding = false;
  String? _userId;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    if (text.isEmpty || _isResponding) return;

    _textController.clear();

    setState(() {
      _isComposing = false;
      _isResponding = true;
      _messages.add(
        ChatMessage(text: text, isMe: true, type: ChatMessageType.text),
      );
      _messages.add(
        ChatMessage(
          text: '...',
          isMe: false,
          isLoading: true,
          type: ChatMessageType.text,
        ),
      );
    });

    _scrollToBottom();

    try {
      final headers = {
        'X-Environment': 'development',
        'Content-Type': 'application/json',
        if (_userId != null)
          'cookie': 'id=$_userId', // 👈 add cookie header if _userId is set
      };

      final response = await http.put(
        Uri.parse('https://api.worklyn.com/konsul/assistant.chat'),
        headers: headers,
        body: jsonEncode({
          "message": text,
          "source": {"id": "1", "deviceId": 1},
        }),
      );

      final responseData = jsonDecode(response.body);
      if (responseData['userId'] != null) {
        setState(() {
          _userId = responseData['userId'].toString();
        });
      }
      print(responseData);

      setState(() {
        _messages.removeLast(); // remove loading dots
        _isResponding = false;

        if (responseData['task'] != null) {
          final taskData = responseData['task'];
          _messages.add(
            ChatMessage(
              text: responseData['message'] ?? '',
              isMe: false,
              type: ChatMessageType.task,
              task: TaskData(
                id: taskData['id'],
                title: taskData['title'],
                dueDate:
                    taskData['dueDate'] != null
                        ? DateTime.parse(taskData['dueDate'])
                        : null,
                completed: taskData['completed'] ?? false,
              ),
            ),
          );
        } else {
          _messages.add(
            ChatMessage(
              text: responseData['message'] ?? 'No response',
              isMe: false,
              type: ChatMessageType.text,
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _isResponding = false;
        _messages.add(
          ChatMessage(
            text: 'Error: $e',
            isMe: false,
            type: ChatMessageType.text,
          ),
        );
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: const Text(
                  "Chat",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(8.0),
                  itemCount: _messages.length,
                  itemBuilder: (_, index) {
                    final message = _messages[index];
                    return _buildMessage(message);
                  },
                ),
              ),
              _buildMessageComposer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    if (message.isLoading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildTypingDots(),
        ),
      );
    }

    if (message.type == ChatMessageType.task && message.task != null) {
      return _buildTaskMessage(message.task!);
    }

    return _buildTextMessage(message);
  }

  Widget _buildTextMessage(ChatMessage message) {
    final isMe = message.isMe;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? Color(0xFFE7F5F9) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Linkify(
              onOpen: (link) async {
                final url = Uri.parse(link.url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not launch ${link.url}')),
                  );
                }
              },
              text: message.text,
              style: TextStyle(color: Colors.black, fontSize: 16),
              linkStyle: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              options: LinkifyOptions(humanize: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskMessage(TaskData task) {
    return InkWell(
      onTap: () => _showTaskDetails(task),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
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
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      decoration:
                          task.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        task.dueDate != null
                            ? _formatDate(task.dueDate!)
                            : "Today",
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
  }

  Widget _buildTypingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(),
        SizedBox(width: 4),
        _dot(),
        SizedBox(width: 4),
        _dot(),
      ],
    );
  }

  Widget _dot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
    );
  }

  void _showTaskDetails(TaskData task) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18),
                    SizedBox(width: 8),
                    Text(
                      task.dueDate != null
                          ? _formatDate(task.dueDate!)
                          : "Today",
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text("Task ID: ${task.id}"),
                SizedBox(height: 8),
                Text("Completed: ${task.completed ? 'Yes' : 'No'}"),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildMessageComposer() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Color(0xFFEAEDED),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'What can I do for you?',
                hintStyle: TextStyle(color: Color(0xFFA2A2A6)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: _handleSubmitted,
            ),
          ),
        ),
        SizedBox(width: 10),
        _isComposing
            ? GestureDetector(
              onTap: () => _handleSubmitted(_textController.text),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF1397C1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_upward, color: Colors.white, size: 20),
              ),
            )
            : Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 167, 219, 235),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_upward, color: Colors.white, size: 20),
            ),
      ],
    );
  }
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
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

class ChatMessage {
  final String text;
  final bool isMe;
  final bool isLoading;
  final ChatMessageType type;
  final TaskData? task;

  ChatMessage({
    required this.text,
    required this.isMe,
    this.isLoading = false,
    this.type = ChatMessageType.text,
    this.task,
  });
}

class TaskData {
  final int id;
  final String title;
  final DateTime? dueDate;
  bool completed;

  TaskData({
    required this.id,
    required this.title,
    this.dueDate,
    this.completed = false,
  });
}
