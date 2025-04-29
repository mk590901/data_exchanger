// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bloc_test/bloc_test.dart';
import 'package:ecg_buffer/exchange_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecg_buffer/main.dart';

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
  });

}
