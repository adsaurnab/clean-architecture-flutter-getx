import 'package:flutter/foundation.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();

  ChatService._internal() {
    _init();
  }

  factory ChatService() {
    return _instance;
  }

  void _init() {
    // Initialize services here (e.g., WebSockets, Database)
  }

  void sendMessage(String message) {
    debugPrint('Sending message: $message');
  }
}
