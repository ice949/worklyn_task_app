import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worklyn_task_app/models/chat_message.dart';
import 'package:worklyn_task_app/models/task_data.dart';
import 'package:worklyn_task_app/services/api/chat_api.dart';
import 'package:worklyn_task_app/services/storage/local_storage.dart';
import 'package:worklyn_task_app/utils/html_parser.dart';
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


  // Get use from local storage
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');
    if (savedUserId != null) {
      setState(() {
        _userId = savedUserId;
      });
    }
  }

// Open Bottom Sheet with task details
  void _showTaskDetails(TaskData task) {
    showEditTaskModal(
      context: context,
      task: task,
      selData: selData,
      onDateSelected: _onDateSelected,
    );
  }


  void _handleSubmitted(String text) async {
  if (text.isEmpty || _isResponding) return;

  _prepareUserMessage(text);
  _scrollToBottom();

  try {
    final responseData = await ChatApiService.sendMessage(text: text, userId: _userId);

    await _updateUserIdIfNeeded(responseData);

    final htmlMessage = responseData['html_message'] ?? '';
    final tasks = HtmlParserUtil.parseTasks(htmlMessage);

    _handleBotResponse(
      message: responseData['message'] ?? 'No response',
      htmlMessage: htmlMessage,
      tasks: tasks,
    );
  } catch (e) {
    _handleError(e);
  }

  _scrollToBottom();
}

void _prepareUserMessage(String text) {
  _textController.clear();
  setState(() {
    _isComposing = false;
    _isResponding = true;
    _messages.add(ChatMessage(text: text, isMe: true, type: ChatMessageType.text));
    _messages.add(ChatMessage(text: '...', isMe: false, isLoading: true, type: ChatMessageType.text));
  });
}

Future<void> _updateUserIdIfNeeded(Map<String, dynamic> responseData) async {
  final id = responseData['userId']?.toString();
  if (id != null && id != _userId) {
    setState(() => _userId = id);
    await LocalStorageService.saveUserId(id);
  }
}

void _handleBotResponse({required String message, required String htmlMessage, required List<TaskData> tasks}) {
  setState(() {
    _messages.removeLast();
    _isResponding = false;

    if (tasks.isNotEmpty) {
      _tasks.addAll(tasks);
      _messages.add(ChatMessage(text: message, isMe: false, type: ChatMessageType.task, taskList: tasks));
    } else if (htmlMessage.contains('<ol>')) {
      _messages.add(ChatMessage(text: 'Here are your tasks:', isMe: false, type: ChatMessageType.task));
    } else {
      _messages.add(ChatMessage(text: message, isMe: false, type: ChatMessageType.text));
    }
  });
}

void _handleError(Object error) {
  setState(() {
    _messages.removeLast();
    _isResponding = false;
    _messages.add(ChatMessage(text: 'Error: $error', isMe: false, type: ChatMessageType.text));
  });
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
