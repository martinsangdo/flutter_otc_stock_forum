import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:otc_stock_forum/constants.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    final userMessage = _textController.text;
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _textController.clear(); // Clear input field
    });

    try {
      final aiResponse = await _getAiResponse(userMessage);
      setState(() {
        _messages.add(ChatMessage(text: aiResponse, isUser: false));
      });
      // Scroll to the bottom after the build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), // Adjust duration as needed
          curve: Curves.easeOut, // Adjust curve as needed
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: 'Error: Could not get AI response.', isUser: false));
      });
      debugPrint('Error getting AI response: $e');
    }
  }

  Future<String> _getAiResponseFromGemini(String message) async {
    final prompt = """
    You are an AI assistant specialized in providing information about Over-the-counter (OTC) stocks.  A user will ask you questions.  Provide helpful, informative, and accurate responses.  Be cautious and avoid giving financial advice.  Clearly state that you are an AI and cannot give financial advice.
    User: $message
    """;

    final requestBody = jsonEncode({
      "contents": {
        "parts": [ {
          'text': prompt
        }]
      }
    });
    try {
      final response = await http.post(Uri.parse(glb_gem_uri + glb_gem_key),
          headers: {
            'Content-Type': 'application/json'
          },
          body: requestBody);
      debugPrint(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Gemini API response structure might vary. Adapt this part.
        final candidates = data['candidates'] as List;
        debugPrint(candidates.toString());
        if (candidates.isNotEmpty) {
          return candidates[0]['output'] ?? GEMINI_UNAVAILABLE;
        } else {
          debugPrint('Candidate empty');
          return GEMINI_UNAVAILABLE;
        }
      } else {
        debugPrint('Response not 200');
        return GEMINI_UNAVAILABLE;
      }
    } catch (e) {
      debugPrint('Unknow exception');
      debugPrint(e.toString());
      return GEMINI_UNAVAILABLE;
    }
  }

  Future<String> _getAiResponse(String message) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay

    return _getAiResponseFromGemini(message);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Assign the ScrollController
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Ask me about OTC stocks...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: message.isUser ? Colors.blue[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(message.text),
        ),
      ),
    );
  }
}