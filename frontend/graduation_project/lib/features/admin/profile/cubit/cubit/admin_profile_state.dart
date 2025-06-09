import 'package:equatable/equatable.dart';

// Remove 'part of 'admin_profile_cubit.dart';'
// This file defines the states independently.

abstract class AdminProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminProfileInitial extends AdminProfileState {}

class AdminProfileLoading extends AdminProfileState {}

class AdminProfileSuccess extends AdminProfileState {
  final String message;
  AdminProfileSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminProfileError extends AdminProfileState {
  final String message;
  AdminProfileError(this.message);
  @override
  List<Object?> get props => [message];
}