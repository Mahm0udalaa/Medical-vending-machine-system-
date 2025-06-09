import 'package:equatable/equatable.dart';

abstract class NewPasswordState extends Equatable {
  const NewPasswordState();

  @override
  List<Object?> get props => [];
}

class NewPasswordInitial extends NewPasswordState {}

class NewPasswordLoading extends NewPasswordState {}

class NewPasswordSuccess extends NewPasswordState {
  final String message;
  const NewPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class NewPasswordError extends NewPasswordState {
  final String message;
  const NewPasswordError({required this.message});

  @override
  List<Object?> get props => [message];
}
