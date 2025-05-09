// widgets/message_composer_widget.dart

import 'package:flutter/material.dart';

class MessageComposerWidget extends StatefulWidget {
  final TextEditingController textController;
  final bool isComposing;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const MessageComposerWidget({
    Key? key,
    required this.textController,
    required this.isComposing,
    required this.onChanged,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  State<MessageComposerWidget> createState() => _MessageComposerWidgetState();
}

class _MessageComposerWidgetState extends State<MessageComposerWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Color(0xFFEAEDED),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: widget.textController,
              decoration: InputDecoration(
                hintText: 'What can I do for you?',
                hintStyle: TextStyle(color: Color(0xFFA2A2A6)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
            ),
          ),
        ),
        SizedBox(width: 10),
        widget.isComposing
            ? GestureDetector(
                onTap: () => widget.onSubmitted(widget.textController.text),
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
