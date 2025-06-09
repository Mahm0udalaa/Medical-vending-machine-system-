import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:graduation_project/features/auth/forget_password/data/repos/forgot_password_repo.dart';

part 'verify_code_state.dart';

class VerifyCodeCubit extends Cubit<VerifyCodeState> {
  final ForgotPasswordRepo repo;

  VerifyCodeCubit(this.repo) : super(VerifyCodeInitial());

  Future<void> verifyCode(String email, String code) async {
    emit(VerifyCodeLoading());
    final result = await repo.verifyCode(email, code);

    if (result['success'] == true) {
      emit(VerifyCodeSuccess(
        message: result['message'],
        email: email,
        code: code,
      ));
    } else if (result.containsKey('data') && result['data']?['isValid'] == false) {
      emit(VerifyCodeInvalidOrExpired(message: result['message']));
    } else {
      emit(VerifyCodeFailureWithMessage(message: result['message']));
    }
  }

  Future<void> resendCode(String email) async {
    emit(VerifyCodeResending());
    final result = await repo.sendResetCode(email);
    if (result['success'] == true) {
      emit(VerifyCodeResendSuccess(message: result['message']));
    } else {
      emit(VerifyCodeFailure(error: result['message']));
    }
  }
}
