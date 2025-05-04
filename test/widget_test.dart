// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bloc_test/bloc_test.dart';
import 'package:ecg_buffer/exchange_bloc.dart';
import 'package:ecg_buffer/exchange_buffer.dart';
import 'package:ecg_buffer/message_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecg_buffer/main.dart';


void put() {
  print ('Put Data');
}

void get() {
  print ('Get Data');
}

void outFun(List<double> list) {
  print ('Get Data II->$list');
}

void main() {

  group('ExchangeBloc', () {
    late ExchangeBloc exchangeBloc;

    setUp(() {
      exchangeBloc = ExchangeBloc();
    });

    tearDown(() {
      exchangeBloc.close();
    });

    test('initial state is ExchangeState with null data', () {
      expect(exchangeBloc.state, const ExchangeState(data: null));
    });

    test('put/get', () async {
      exchangeBloc.add(PutEvent('test_data'));
      await Future.delayed(Duration(milliseconds: 1));
      expect(exchangeBloc.state, const ExchangeState(data: 'test_data'));
      final data = await exchangeBloc.getData();
      expect(data, 'test_data');

    });

    test('MessageHandler sends message correctly', () async {
      final handler = MessageHandler();
      // Subscribe and get message
      expect(handler.messages, emits('Hello'));

      // Send message
      handler.sendMessage('Hello');

      handler.dispose();
    });


    test('MessageHandler sends and receive string message correctly', () async {
      final handler = MessageHandler<String>();

      // Subscribing and get message
      handler.messages.listen((message) {
        print('Receive message: $message');
        //handler.dispose();
      });

      // Send message
      handler.sendMessage('Hello from Dart!');

      handler.dispose();

    });

    test('MessageHandler sends and receive array message correctly', () async {
      final handler = MessageHandler<List<double>>();

      // Subscribing and get message
      handler.messages.listen((message) {
        print('Receive message: $message');
       });

      // Send message
      handler.sendMessage([1.1,1.2,1.3,1.4]);

      handler.dispose();

    });

    test('MessageHandler with callbacks', () async {
      final handler = MessageHandler<VoidCallback?>();

      // Subscribing and get message
      handler.messages.listen((callback) {
        callback?.call();
      });

      // Send message
      handler.sendMessage(put);
      handler.sendMessage(put);
      handler.sendMessage(get);
      handler.dispose();

    });

    test('Exchange buffer I', () {
      ExchangeBuffer buffer = ExchangeBuffer(8, null);
      List<double> rowData = buffer.read(4);
      expect(rowData,[]);
      buffer.write([1,2,3,4]);
      buffer.write([5,6,7,8]);
      rowData = buffer.read(4);
      expect(rowData,[1,2,3,4]);
      rowData = buffer.read(4);
      expect(rowData,[5,6,7,8]);
      rowData = buffer.read(4);
      expect(rowData,[]);
    });

    test('Exchange buffer II', () {
      ExchangeBuffer buffer = ExchangeBuffer(8, outFun);
      buffer.get(4);
      buffer.put([1,2,3,4]);
      buffer.put([5,6,7,8]);
      buffer.get(4);
      buffer.get(4);
      buffer.get(4);
      buffer.dispose();
    });

  });

}
