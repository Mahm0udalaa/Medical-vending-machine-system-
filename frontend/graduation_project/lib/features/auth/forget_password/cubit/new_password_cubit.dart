import 'package:bloc/bloc.dart';
import '../data/repos/new_password_repo.dart';
import 'new_password_state.dart';

class NewPasswordCubit extends Cubit<NewPasswordState> {
  final NewPasswordRepo newPasswordRepo;

  NewPasswordCubit({required this.newPasswordRepo}) : super(NewPasswordInitial());

  Future<void> resetPassword({required String email, required String code, required String newPassword}) async {
    emit(NewPasswordLoading());
    final response = await newPasswordRepo.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
    if (response["success"] == true) {
      emit(NewPasswordSuccess(message: response["message"]));
    } else {
      emit(NewPasswordError(message: response["message"]));
    }
  }
}
