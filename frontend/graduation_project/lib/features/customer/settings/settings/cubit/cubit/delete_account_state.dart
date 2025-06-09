import 'package:equatable/equatable.dart';

abstract class DeleteAccountState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeleteAccountInitial extends DeleteAccountState {}
class DeleteAccountLoading extends DeleteAccountState {}
class DeleteAccountSuccess extends DeleteAccountState {}
class DeleteAccountError extends DeleteAccountState {
  final String message;
  DeleteAccountError(this.message);
  @override
  List<Object?> get props => [message];
} 