import 'dart:async';

import '../ecg_simulator/ecg_simulator.dart';
import '../exchange_buffer.dart';

class ECGObserver {
  static int PERIOD = 1000;
  final ExchangeBuffer exchangeBuffer;
  final int seriesLength;
  final Duration _period = Duration(milliseconds: PERIOD);
  late Timer? _timer;

  ECGObserver (this.seriesLength, this.exchangeBuffer);

  void start() {
    print ('------- ECGObserver.start -------');
    _timer = Timer.periodic(_period, (Timer t) {
      _callbackFunction();
    });
  }

  void stop() {
    if (isActive()) {
      _timer?.cancel();
    }
    _timer = null;
    print ('------- ECGObserver.stop -------');
  }

  void _callbackFunction() {
    exchangeBuffer.get(seriesLength);
  }

  bool isActive() {
    return _timer != null && _timer!.isActive;
  }

}