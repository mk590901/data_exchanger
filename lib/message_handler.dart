import 'dart:async';

class MessageHandler {
  final _controller = StreamController.broadcast();

  // Send message
  void sendMessage(String message) {
    _controller.add(message);
  }

  // Receive message
  Stream get messages => _controller.stream;

  void dispose() {
    _controller.close();
  }
}