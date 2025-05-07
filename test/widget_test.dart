// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bloc_test/bloc_test.dart';
import 'ecg_observer.dart';
import 'package:ecg_buffer/ecg_sensor/ecg_sensor.dart';
import 'package:ecg_buffer/ecg_simulator/ecg_simulator.dart';
import 'exchange_bloc.dart';
import 'package:ecg_buffer/data_exchanger.dart';
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

    test('Exchanger I', () {
      DataExchanger exchanger = DataExchanger(8, null);
      List<double> rowData = exchanger.read(4);
      expect(rowData,[]);
      exchanger.write([1,2,3,4]);
      exchanger.write([5,6,7,8]);
      rowData = exchanger.read(4);
      expect(rowData,[1,2,3,4]);
      rowData = exchanger.read(4);
      expect(rowData,[5,6,7,8]);
      rowData = exchanger.read(4);
      expect(rowData,[]);
    });

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


  });

}
