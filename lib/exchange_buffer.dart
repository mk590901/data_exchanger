import 'circular_buffer.dart';

class ExchangeBuffer {
  late  CircularBuffer<double> buffer_;
  final int _bufferLength;

  ExchangeBuffer(this._bufferLength) {
    buffer_ = CircularBuffer<double>(_bufferLength + 1);
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

  List<double>  read(int orderedSize) {
    if (orderedSize <= 0) {
      return [];
    }
    return buffer_.readRow(orderedSize);
  }

}
