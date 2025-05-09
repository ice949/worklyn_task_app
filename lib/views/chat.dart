import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:worklyn_task_app/models/chat_message.dart';
import 'package:worklyn_task_app/models/task_data.dart';
import 'package:worklyn_task_app/views/widgets/message_composer.dart';
import 'package:worklyn_task_app/views/widgets/show_edit_task_modal.dart';
import 'package:worklyn_task_app/views/widgets/task_list.dart';
import 'package:worklyn_task_app/views/widgets/text_message.dart';
import 'package:worklyn_task_app/views/widgets/typing_dots';

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
  DateTime selData = DateTime.now();
  bool showCalendar = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _onDateSelected(DateTime day, DateTime focusedDay) {
    setState(() {
      selData = day;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showTaskDetails(TaskData task) {
    showEditTaskModal(
      context: context,
      task: task,
      selData: selData,
      onDateSelected: _onDateSelected,
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

      // parse html_message
      final htmlMessage = responseData['html_message'] ?? '';
      final document = htmlParser.parse(htmlMessage);
      final olElement = document.querySelector('ol');

      setState(() {
        _messages.removeLast();
        _isResponding = false;

        if (olElement != null) {
          final taskElements = olElement.querySelectorAll('li');
          print(taskElements);
          List<TaskData> tasks = [];

          for (int i = 0; i < taskElements.length; i++) {
            final li = taskElements[i];
            final title = li?.text.trim() ?? 'Untitled Task';

            if (title != "Untitled Task") {
              _tasks.add(TaskData(id: i + 1, title: title));
            }
          }

          _messages.add(
            ChatMessage(
              text: responseData['message'] ?? '',
              isMe: false,
              type: ChatMessageType.task,
              task: null, 
              taskList: tasks, 
            ),
          );
        } else {
          final htmlMessage = responseData['html_message'] ?? '';
          if (htmlMessage.contains('<ol>')) {

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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
              MessageComposerWidget(
                textController: _textController,
                isComposing: _isComposing,
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  });
                },
                onSubmitted: _handleSubmitted,
              ),
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
          child: TypingDotsWidget(),
        ),
      );
    }

    if (message.type == ChatMessageType.task) {
      return TaskListWidget(
        tasks: _tasks,
        onTaskTap: _showTaskDetails,
        onTaskToggle: (task, val) {
          setState(() {
            task.completed = val ?? false;
          });
        },
      );
    }

    return TextMessageWidget(message: message);
  }



}
