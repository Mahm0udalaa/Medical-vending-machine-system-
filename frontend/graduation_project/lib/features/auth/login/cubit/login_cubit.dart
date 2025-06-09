// 📦 cubit/login_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/auth/login/data/models/login_request_model.dart';
import 'package:graduation_project/features/auth/login/data/repos/login_repo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _repo;

  LoginCubit(this._repo) : super(LoginInitial());

  Future<void> login(LoginRequestModel request) async {
    emit(LoginLoading());
    try {
      final response = await _repo.login(request);
      emit(LoginSuccess(response));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    final storage = const FlutterSecureStorage();
    await storage.deleteAll();
    emit(LoginLoggedOut());
  }
}
