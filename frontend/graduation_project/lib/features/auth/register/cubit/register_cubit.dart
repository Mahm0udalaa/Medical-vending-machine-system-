import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/auth/register/data/models/register_request.dart';
import 'package:graduation_project/features/auth/register/data/repos/register_repo.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepo registerRepo;

  RegisterCubit(this.registerRepo) : super(RegisterInitial());

  Future<void> registerUser(RegisterRequestModel model) async {
    emit(RegisterLoading());
    try {
      final message = await registerRepo.register(model);
      emit(RegisterSuccess(message));
    } catch (e) {
      // إزالة كلمة Exception: من الرسالة
      final cleanError = e.toString().replaceFirst('Exception: ', '');
      emit(RegisterFailure(cleanError));
    }
  }
}
