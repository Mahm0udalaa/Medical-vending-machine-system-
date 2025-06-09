import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:graduation_project/features/auth/forget_password/data/repos/forgot_password_repo.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordRepo forgotPasswordRepo;

  ForgotPasswordCubit(this.forgotPasswordRepo) : super(ForgotPasswordInitial());

  Future<void> sendResetCode(String email) async {
    emit(ForgotPasswordLoading());
    final result = await forgotPasswordRepo.sendResetCode(email);
    if (result['success'] == true) {
      emit(ForgotPasswordSuccess(email, result['message']));
    } else {
      final errorMessage = result['message'] ?? 'An unexpected error occurred.';
      emit(ForgotPasswordFailure(errorMessage));
      // You can handle showing the snackbar in your UI layer when state is ForgotPasswordFailure
      // For example, in your BlocListener, show a snackbar with errorMessage
    }
  }
}
