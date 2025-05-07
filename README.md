# A realistic ECG waveform generator on flutter II

The presented application is a development of the https://github.com/mk590901/list_cards_bloc_2 project with the aim of giving it more realism.

## Introduction

The process of generating an ECG signal and the process of displaying it are in this app version logically separated and isolated from each other. There is a cyclic buffer through which data is exchanged. The ECG generator writes data to this buffer, and the display system reads them and displays them in the widget.

Despite the fact that the cyclic buffer allows you to correctly overlap read/write operations without restrictions, I decided to use the mechanism of sending and processing messages for synchronization, widely used, for example, in Java. The only problem is that there is no direct analogue of message handling in dart. However, there is __StreamController__, which can be used for this purpose. An example of implementation is given below.

## MessageHandler class

```dart
mport 'dart:async';

// Analog of Handler in Dart
class MessageHandler {
  final _controller = StreamController.broadcast();

  // Sending a message
  void sendMessage(String message) {
    _controller.add(message);
  }

  // Receiving messages
  Stream get messages => _controller.stream;

  void dispose() {
    _controller.close();
  }
}

// Usage
void main() {
  final handler = MessageHandler();

  // Subscribing to messages (analog of Handler processing)
  handler.messages.listen((message) {
    print(''Received message: $message');
  });

  // Sending a message
  handler.sendMessage('Hello from Dart!');
}

```

## Synchronization of writing and reading data in a circular buffer.

For this purpose, the __DataExchanger__ class was created, which is accessible to the object writing the data, as well as the object reading this data.

The put and get operations of the __DataExchanger__ class use the previously created MessageHandler class.

## Movie

As can be seen from the movie, the behavior of the application practically does not change. The only thing that distinguishes it from the previous version is that the display of the ECG signal begins with a straight line: this is the effect of a second delay when the circular buffer is filled with the ECG signal.

https://github.com/user-attachments/assets/32f6726a-8148-4901-aaa9-7a6f08d3c996

