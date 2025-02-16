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
  final List<ChatMessage> _messages = [ChatMessage(text: 'I am an AI assistant specializing in information about over-the-counter (OTC) stocks.  I can help you find information on various OTC-listed companies, but please remember that I cannot give financial advice.  Any information I provide should not be considered a recommendation to buy or sell any security. Ask me anything!', isUser: false)];
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

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta2/models/gemini-pro:generateText'); // Correct URL

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $glb_gem_key',
      };

      // Construct the request body with message history
      // final requestBody = {
      //   "prompt": {
      //     "messages": _messages.map((message) => {
      //       "author": message.isUser ? "user" : "bot",
      //       "content": message.text,
      //     }).toList(),
      //   },
      //   "temperature": 0.7, // Adjust as needed
      //   "maxOutputTokens": 256, // Adjust as needed
      // };

      final response = await http.post(url, headers: headers, body: jsonEncode(requestBody));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final geminiResponse = jsonData['candidates'][0]['output']; // Extract Gemini's response

        debugPrint(geminiResponse);
      }

    try {
      //debugPrint(glb_gem_uri + glb_gem_key);
      final response = await http.post(Uri.parse(glb_gem_uri + glb_gem_key),
          headers: {
            'Content-Type': 'application/json'
          },
          body: requestBody);
      //
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Gemini API response structure might vary. Adapt this part.
        final candidates = data['candidates'] as List;
        //debugPrint(candidates.toString());
        if (candidates.isNotEmpty && candidates[0]['content'] != null && candidates[0]['content']['parts'] != null) {
          String strResponseParts = jsonDecode(candidates[0]['content']['parts']);
          List<dynamic> responseParts = jsonDecode(strResponseParts);
          if (responseParts.isNotEmpty){
            if (responseParts[0]['text'] != null){
              return responseParts[0]['text'];
            } else {
              debugPrint('content empty');
              return GEMINI_UNAVAILABLE;
            }
          } else {
            debugPrint('parts empty');
            return GEMINI_UNAVAILABLE;
          }
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
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate API delay
    final prompt = """
    You are an AI assistant specialized in providing information about Over-the-counter (OTC) stocks.  A user will ask you questions.  Provide helpful, informative, and accurate responses.  Be cautious and avoid giving financial advice.  Clearly state that you are an AI and cannot give financial advice.
    User: $message
    """;
    //call our backend to get content
    final headers = {'Content-Type': 'application/json'}; // Important for JSON requests
    
    final response = await http.Client().post(Uri.parse(glb_backend_uri + postGetChatboxContent), 
        headers: headers, body: jsonEncode({
          'text': prompt
        }));
    //debugPrint(response.body.toString());
    if (response.statusCode != 200){
      debugPrint('Cannot get content from cloud');
      return GEMINI_UNAVAILABLE;
    } else {
      Map<String, dynamic> objFromCloud = jsonDecode(response.body);
      //debugPrint(objFromCloud.toString());
      if (objFromCloud['result'] == 'OK'){
        //get text ok
        return objFromCloud['text'];
      } else {
        debugPrint(objFromCloud.toString());
        return GEMINI_UNAVAILABLE;
      }
    }
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