import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/internet_connectivity_service.dart';

class InternetCubit extends Cubit<bool> {
  final InternetConnectivityService _service;

  InternetCubit(this._service) : super(true) {
    _service.onStatusChange.listen((isConnected) {
      emit(isConnected);
    });
  }
}
