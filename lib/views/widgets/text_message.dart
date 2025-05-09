import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worklyn_task_app/models/chat_message.dart';

class TextMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const TextMessageWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFE7F5F9) : Colors.white,
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
              style: const TextStyle(color: Colors.black, fontSize: 16),
              linkStyle: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              options: const LinkifyOptions(humanize: false),
            ),
          ),
        ],
      ),
    );
  }
}
