import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


abstract class ExchangeEvent extends Equatable {
  const ExchangeEvent();

  @override
  List<Object> get props => [];
}

class PutEvent extends ExchangeEvent {
  final dynamic data;

  const PutEvent(this.data);

  @override
  List<Object> get props => [data];
}

class GetEvent extends ExchangeEvent {}

// State
class ExchangeState extends Equatable {
  final dynamic data;

  const ExchangeState({this.data});

  @override
  List<Object?> get props => [data];
}

// BLoC
class ExchangeBloc extends Bloc<ExchangeEvent, ExchangeState> {
  ExchangeBloc() : super(const ExchangeState()) {
    on<PutEvent>(_onPutEvent);
    on<GetEvent>(_onGetEvent);
  }

  void _onPutEvent(PutEvent event, Emitter<ExchangeState> emit) {
    emit(ExchangeState(data: event.data));
  }

  void _onGetEvent(GetEvent event, Emitter<ExchangeState> emit) {
    emit(ExchangeState(data: state.data));
  }

  Future<dynamic> getData() async {
    add(GetEvent());
    return state.data;
  }
}

// Events
// abstract class ExchangeEvent extends Equatable {
//   const ExchangeEvent();
//
//   @override
//   List<Object> get props => [];
// }
//
// class PutEvent extends ExchangeEvent {
//   final dynamic data;
//
//   const PutEvent(this.data);
//
//   @override
//   List<Object> get props => [data];
// }
//
// class GetEvent extends ExchangeEvent {}
//
// // State
// class ExchangeState extends Equatable {
//   final dynamic data;
//
//   const ExchangeState({this.data});
//
//   @override
//   List<Object?> get props => [data];
// }
//
// // BLoC
// class ExchangeBloc extends Bloc<ExchangeEvent, ExchangeState> {
//   ExchangeBloc() : super(const ExchangeState()) {
//     on<PutEvent>(_onPutEvent);
//     on<GetEvent>(_onGetEvent);
//   }
//
//   void _onPutEvent(PutEvent event, Emitter<ExchangeState> emit) {
//     emit(ExchangeState(data: event.data));
//   }
//
//   void _onGetEvent(GetEvent event, Emitter<ExchangeState> emit) {
//     emit(ExchangeState(data: state.data));
//   }
// }