import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;

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
  final List<TaskData> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  void _showTaskDetails(TaskData task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => FractionallySizedBox(
            heightFactor: 0.9,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Edit Task',
                              style: TextStyle(
                                fontSize: 23,
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
                      spacing: 5,
                      children: [
                        Row(
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
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Text(
                                          'Clicked date',
                                          style: TextStyle(fontSize: 8),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    "Today",
                                    // _formatDate(task.dueDate),
                                    style: TextStyle(color: Colors.green),
                                  ),
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
                      spacing: 10,
                      children: [Icon(Icons.add), Text("Add subtask")],
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
              ),
            ),
          ),
    );
  }


  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');
    if (savedUserId != null) {
      setState(() {
        _userId = savedUserId;
      });
    }
  }

  void _parseTasksFromHtml(String html) {
    final document = html_parser.parse(html);
    final ol = document.querySelector('ol');

    if (ol != null) {
      final taskElements = ol.querySelectorAll('li');
      _tasks.clear();

      print(taskElements);

      for (int i = 0; i < taskElements.length; i++) {
        final titleElement = taskElements[i].querySelector('p');
        final noteElement = taskElements[i].querySelector(
          'ul > li:nth-child(1)',
        );
        final dueElement = taskElements[i].querySelector(
          'ul > li:nth-child(2)',
        );

        final title = titleElement?.text.trim() ?? 'Untitled task';
        final note = noteElement?.text.trim();
        final dueDateText = dueElement?.text.trim();

        // extract date from "Due Date: ..."
        DateTime? dueDate;
        if (dueDateText != null &&
            dueDateText.toLowerCase().contains('due date')) {
          final dateStr = dueDateText.split('Due Date:').last.trim();
          try {
            dueDate = DateTime.parse(_convertToIsoDate(dateStr));
          } catch (_) {
            dueDate = null; // fallback if parsing fails
          }
        }


        _tasks.add(TaskData(id: i + 1, title: title, dueDate: dueDate));
        print(_tasks);
      }
      setState(() {}); // refresh UI
    }
  }

  String _convertToIsoDate(String input) {
    // Example input: "May 7, 2025, at 2:00pm"
    // We convert it to: "2025-05-07 14:00:00"
    try {
      final cleaned = input.replaceAll('at ', '');
      final date = DateTime.parse(DateTime.parse(cleaned).toIso8601String());
      return date.toIso8601String();
    } catch (_) {
      // fallback parsing
      return DateTime.now().toIso8601String();
    }
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
        if (_userId != null) 'cookie': 'id=$_userId',
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
        final id = responseData['userId'].toString();
        setState(() {
          _userId = id;
        });
        _saveUserId(id);
      }

      print(responseData);

      // 📝 parse html_message
      final htmlMessage = responseData['html_message'] ?? '';
      final document = htmlParser.parse(htmlMessage);
      final olElement = document.querySelector('ol');
      print(olElement);

      setState(() {
        _messages.removeLast();
        _isResponding = false;

        if (olElement != null) {
          final taskElements = olElement.querySelectorAll('li');
          print(taskElements);
          List<TaskData> tasks = [];

          for (int i = 0; i < taskElements.length; i++) {
            final li = taskElements[i];
            final p = li.querySelector('p');
            final title = p?.text.trim() ?? 'Untitled Task';

            if (title != "Untitled Task") {
            _tasks.add(TaskData(id: i + 1, title: title));
            }

          }

          _messages.add(
            ChatMessage(
              text: responseData['message'] ?? '',
              isMe: false,
              type: ChatMessageType.task,
              task: null, // we will pass tasks separately
              taskList: tasks, // 💥 new field to hold list of tasks
            ),
          );
        } else {
          // 🔸 no tasks; just normal message
          final htmlMessage = responseData['html_message'] ?? '';
          if (htmlMessage.contains('<ol>')) {
            _parseTasksFromHtml(htmlMessage);

            _messages.add(
              ChatMessage(
                text: 'Here are your tasks:',
                isMe: false,
                type: ChatMessageType.task,
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

  if (message.type == ChatMessageType.task) {
    return _buildTaskList();
  }

  return _buildTextMessage(message);
}


Widget _buildTaskList() {
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
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
            color: Colors.grey[100],
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
                        decoration:
                            task.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.dueDate != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            _formatDate(task.dueDate!),
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ],
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

  Widget _buildMessageComposer() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
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
                contentPadding: EdgeInsets.symmetric(vertical: 8),
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
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1397C1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_upward, color: Colors.white, size: 20),
              ),
            )
            : Container(
              padding: EdgeInsets.all(12),
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
  final List<TaskData>? taskList; // 💥 ADD THIS FIELD

  ChatMessage({
    required this.text,
    required this.isMe,
    this.isLoading = false,
    this.type = ChatMessageType.text,
    this.task,
    this.taskList, // 💥 ADD THIS
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
