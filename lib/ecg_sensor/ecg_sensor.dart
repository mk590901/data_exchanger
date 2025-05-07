import 'dart:async';

import '../ecg_simulator/ecg_simulator.dart';
import '../data_exchanger.dart';

class ECGSensor {
  static int PERIOD = 1000;
  final EcgSimulator simulator;
  final DataExchanger exchanger;
  final Duration _period = Duration(milliseconds: PERIOD);

  late Timer? _timer;

  ECGSensor (this.simulator, this.exchanger);

  void start() {
    print ('------- ECGSensor.start -------');
    _timer = Timer.periodic(_period, (Timer t) {
      _callbackFunction();
    });
  }

  void stop() {
    if (isActive()) {
      _timer?.cancel();
    }
    _timer = null;
    print ('------- ECGSensor.stop -------');
  }

  void _callbackFunction() {
    List<double> rowData = simulator.generateECGData();
    //outFun(rowData);  // Only debug
    exchanger.put(rowData);
  }

  void outFun(List<double> list) {
    print ('Put Data ->$list');
  }

  bool isActive() {
    return _timer != null && _timer!.isActive;
  }

}