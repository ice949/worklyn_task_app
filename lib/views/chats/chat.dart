import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: "I have to pick up the kids from school",
      isMe: true,
    ));
    _messages.add(ChatMessage(
      text: "I'm good! Just working on a Flutter project.",
      isMe: false,
    ));
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;
    
    _textController.clear();
    setState(() {
      _isComposing = false;
      _messages.add(ChatMessage(
        text: text,
        isMe: true,
      ));
    });

    // Auto-scroll to the bottom
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Simulate a reply after a short delay
    Future.delayed(Duration(seconds: 1), () {
      final responses = [
      ];
      
      setState(() {
        _messages.add(ChatMessage(
          text: responses[Random().nextInt(responses.length)],
          isMe: false,
        ));
      });

      // Auto-scroll to the bottom again
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final date = now.day;
    String hour = now.hour > 12 ? (now.hour - 12).toString() : now.hour.toString();
    if (hour == '0') hour = '12';
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    print(date);
    return '$hour:$minute $period';
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              const Text("Chat", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
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
          
            // Input area
            _buildMessageComposer(),
            ],
          ),
        ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isMe = message.isMe;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: 
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe 
                    ? Color(0xFFE7F5F9) // Theme color for sent messages
                    : Colors.white, // White for received messages
                  borderRadius: BorderRadius.circular(20),
                ),
                child: 
                    Text(
                      message.text,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
              ),
            ],
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
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Message',
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
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF1397C1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                : Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 167, 219, 235),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
          ],
        );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;

  ChatMessage({
    required this.text,
    required this.isMe,
  });
}