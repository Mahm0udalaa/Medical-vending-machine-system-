part of 'verify_code_cubit.dart';

abstract class VerifyCodeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VerifyCodeInitial extends VerifyCodeState {}

class VerifyCodeLoading extends VerifyCodeState {}

class VerifyCodeResending extends VerifyCodeState {}

class VerifyCodeSuccess extends VerifyCodeState {
  final String message;
  final String email;
  final String code;

  VerifyCodeSuccess({
    required this.message,
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [message, email, code];
}

class VerifyCodeResendSuccess extends VerifyCodeState {
  final String message;

  VerifyCodeResendSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class VerifyCodeFailure extends VerifyCodeState {
  final String error;

  VerifyCodeFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class VerifyCodeFailureWithMessage extends VerifyCodeState {
  final String message;

  VerifyCodeFailureWithMessage({required this.message});

  @override
  List<Object?> get props => [message];
}

class VerifyCodeInvalidOrExpired extends VerifyCodeState {
  final String message;

  VerifyCodeInvalidOrExpired({required this.message});

  @override
  List<Object?> get props => [message];
}
