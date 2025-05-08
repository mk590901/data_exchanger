# A realistic ECG waveform generator on flutter II

The presented application is a development of the https://github.com/mk590901/list_cards_bloc_2 project with the aim of giving it more realism.

## Introduction

The process of generating an __ECG__ signal and the process of displaying it are in this app version logically separated and isolated from each other. There is a cyclic buffer through which data is exchanged. The __ECG__ generator writes data to this buffer, and the display system reads them and displays them in the widget.

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

```dart
import 'dart:collection';
import 'callback_fun_type.dart';
import 'circular_buffer.dart';
import 'message_handler.dart';

class DataExchanger {
  late  CircularBuffer<double> buffer_;
  final int _bufferLength;
  final Queue<List<double>>	_dataQueue	= Queue<List<double>>();
  final Queue<int>	_sizeQueue	= Queue<int>();
  final MessageHandler handler = MessageHandler<VoidCallback?>();
  final ListCallback? callback;

  DataExchanger(this._bufferLength, this.callback) {
    buffer_ = CircularBuffer<double>(_bufferLength + 1);
    handler.messages.listen((callback) {
      callback?.call();
    });

  }

  CircularBuffer<double> buffer() {
    return buffer_;
  }

  void write(List<double> rowData) {
    if (rowData.isEmpty) {
      return;
    }
    buffer_.writeRow(rowData);
  }

  void put(List<double> rowData) {
    _dataQueue.add(rowData);
    handler.sendMessage(putData);
  }

  void get(int orderedSize) {
    _sizeQueue.add(orderedSize);
    handler.sendMessage(getData);
  }

  List<double>  read(int orderedSize) {
    if (orderedSize <= 0) {
      return [];
    }
    return buffer_.readRow(orderedSize);
  }

  void dispose() {
    handler.dispose();
  }

  void putData() {
    if (_dataQueue.isEmpty) {
      return;
    }
    List<double> data = _dataQueue.removeFirst();
    write(data);
  }

  void getData() {
    if (_sizeQueue.isEmpty) {
      return;
    }
    int orderedSize = _sizeQueue.removeFirst();
    List<double>  out = read(orderedSize);
    callback?.call(out);

  }
}

```

The __put__ and __get__ operations of the __DataExchanger__ class use the previously created __MessageHandler__ class.


## __DataExchanger__ class usage

```dart
test('Exchanger II', () {
      DataExchanger exchanger = DataExchanger(8, outFun);
      exchanger.get(4);
      exchanger.put([1,2,3,4]);
      exchanger.put([5,6,7,8]);
      exchanger.get(4);
      exchanger.get(4);
      exchanger.get(4);
      exchanger.dispose();
    });
```

Output

```
Get Data II->[]
Get Data II->[1.0, 2.0, 3.0, 4.0]
Get Data II->[5.0, 6.0, 7.0, 8.0]
Get Data II->[]
```

and

```dart
    test('Exchanger III', () async {
      DataExchanger exchanger = DataExchanger(8, outFun);
      EcgSimulator simulator = EcgSimulator(4);
      ECGSensor sensor = ECGSensor(simulator, exchanger);
      ECGObserver observer = ECGObserver(4,exchanger);
      observer.start();
      sensor.start();
      await Future.delayed(Duration(milliseconds:4000));
      sensor.stop();
      await Future.delayed(Duration(milliseconds:1000));
      observer.stop();
      exchanger.dispose();
    });
```

Output

```
ECG Generator Parameters:
Approximate number of heart beats: 1000
ECG sampling frequency: 4.0 Hertz
Internal sampling frequency: 8.0 Hertz
Amplitude of additive noise: 0.04 mV
Heart rate mean: 60.0 beats per minute
Heart rate std: 1.0 beats per minute
Low frequency: 0.1 Hertz
High frequency: 0.25 Hertz
Low frequency std: 0.01 Hertz
High frequency std: 0.01 Hertz
LF/HF ratio: 0.5
Order of Extrema (P, Q, R, S, T):
theta(radians): [-1.2217304763960306, -0.2617993877991494, 0.0, 0.2617993877991494, 1.7453292519943295]
a(mV): [1.2, -5.0, 30.0, -7.5, 0.75]
b(radians): [0.25, 0.1, 0.1, 0.1, 0.4]
------- ECGObserver.start -------
------- ECGSensor.start -------
Get Data II->[]
Get Data II->[-0.2825161062209391, 1.1892126448215978, -0.2312720545623088, -0.4224471483670395]
Get Data II->[-0.40814850474155906, 0.06169642583115337, -0.37650870745111775, -0.26725277553813254]
Get Data II->[-0.376418414980368, -0.14018028298825697, -0.328227369154548, -0.15141213060063455]
------- ECGSensor.stop -------
Get Data II->[]
------- ECGObserver.stop -------

```

## Movie

As can be seen from the movie, the behavior of the application practically does not change. The only thing that distinguishes it from the previous version is that the display of the __ECG signal__ begins with a straight line: this is the effect of a second delay when the circular buffer is filled with the __ECG__ signal.

https://github.com/user-attachments/assets/32f6726a-8148-4901-aaa9-7a6f08d3c996

